import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/presentation/widgets/dialogs.dart';
import '../../../../core/result/result.dart';
import '../../../../core/utils/format.dart';
import '../../../category/presentation/state/category_providers.dart';
import '../../../category/presentation/widgets/category_dialog.dart';
import '../../domain/entities/bible_passage.dart';
import '../../domain/entities/reference_photo.dart';
import '../../domain/entities/sermon.dart';
import '../../domain/usecases/add_sermon.dart';
import '../state/sermon_providers.dart';
import '../widgets/photo_thumbnail.dart';

class _PassageFields {
  final TextEditingController reference;
  final TextEditingController text;
  _PassageFields({String reference = '', String text = ''})
      : reference = TextEditingController(text: reference),
        text = TextEditingController(text: text);

  void dispose() {
    reference.dispose();
    text.dispose();
  }
}

/// Création (sermonId == null) ou modification d'un sermon.
class SermonFormPage extends ConsumerStatefulWidget {
  final String? sermonId;
  const SermonFormPage({super.key, this.sermonId});

  @override
  ConsumerState<SermonFormPage> createState() => _SermonFormPageState();
}

class _SermonFormPageState extends ConsumerState<SermonFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _content = TextEditingController();
  final _tags = TextEditingController();
  final List<_PassageFields> _passages = [];
  List<ReferencePhoto> _photos = [];
  String? _categoryId;
  DateTime? _preachedAt;
  Sermon? _editing;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final id = widget.sermonId;
    if (id != null) {
      final s = ref.read(sermonByIdProvider(id));
      if (s != null) {
        _editing = s;
        _title.text = s.title;
        _content.text = s.content;
        _tags.text = s.tags.join(', ');
        _categoryId = s.categoryId;
        _preachedAt = s.preachedAt;
        _photos = [...s.photos];
        for (final p in s.passages) {
          _passages.add(_PassageFields(reference: p.reference, text: p.text));
        }
      }
    } else {
      // Pré-sélectionne la catégorie filtrée dans la liste.
      _categoryId = ref.read(selectedCategoryIdProvider);
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    _tags.dispose();
    for (final p in _passages) {
      p.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _preachedAt ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) setState(() => _preachedAt = picked);
  }

  Future<void> _addPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Galerie'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Appareil photo'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    try {
      final picked = await ImagePicker()
          .pickImage(source: source, imageQuality: 85, maxWidth: 2000);
      if (picked == null) return;
      final photo = await ref.read(photoStorageProvider).importPhoto(picked.path);
      if (mounted) setState(() => _photos = [..._photos, photo]);
    } catch (_) {
      if (mounted) showMessage(context, 'Impossible d\'ajouter la photo');
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final passages = _passages
        .where((p) => p.reference.text.trim().isNotEmpty)
        .map((p) => BiblePassage(
            reference: p.reference.text.trim(), text: p.text.text.trim()))
        .toList();
    final tags = _tags.text
        .split(',')
        .map((t) => t.trim().replaceFirst(RegExp(r'^#'), ''))
        .where((t) => t.isNotEmpty)
        .toList();

    final actions = ref.read(sermonActionsProvider);
    final Result<Sermon> result;
    if (_editing == null) {
      result = await actions.add(AddSermonParams(
        title: _title.text,
        categoryId: _categoryId ?? '',
        passages: passages,
        content: _content.text,
        photos: _photos,
        tags: tags,
        preachedAt: _preachedAt,
      ));
    } else {
      result = await actions.update(_editing!.copyWith(
        title: _title.text,
        categoryId: _categoryId,
        passages: passages,
        content: _content.text,
        photos: _photos,
        tags: tags,
        preachedAt: _preachedAt,
      ));
    }

    if (!mounted) return;
    setState(() => _saving = false);
    result.when<void>(
      success: (_) => Navigator.pop(context),
      failure: (f) => showMessage(context, f.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = ref.watch(categoriesStreamProvider).valueOrNull ?? const [];
    final validCategory =
        categories.any((c) => c.id == _categoryId) ? _categoryId : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(_editing == null ? 'Nouveau sermon' : 'Modifier le sermon'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Enregistrer'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _title,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Titre *'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Le titre est obligatoire' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: validCategory,
              decoration: const InputDecoration(labelText: 'Catégorie *'),
              items: [
                for (final c in categories)
                  DropdownMenuItem(value: c.id, child: Text(c.name)),
              ],
              onChanged: (v) => setState(() => _categoryId = v),
              validator: (v) => v == null ? 'Choisissez une catégorie' : null,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => showCategoryDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Nouvelle catégorie'),
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date de prédication',
                  suffixIcon: Icon(Icons.calendar_today_outlined),
                ),
                child: Text(
                    _preachedAt == null ? 'Non renseignée' : formatDate(_preachedAt!)),
              ),
            ),
            const SizedBox(height: 24),
            Text('Textes bibliques', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            for (var i = 0; i < _passages.length; i++)
              Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            TextField(
                              controller: _passages[i].reference,
                              decoration: const InputDecoration(
                                  labelText: 'Référence (ex. Jean 3:16)'),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _passages[i].text,
                              minLines: 2,
                              maxLines: 6,
                              decoration:
                                  const InputDecoration(labelText: 'Texte du verset'),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Retirer',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => setState(() => _passages.removeAt(i).dispose()),
                      ),
                    ],
                  ),
                ),
              ),
            OutlinedButton.icon(
              onPressed: () => setState(() => _passages.add(_PassageFields())),
              icon: const Icon(Icons.add),
              label: const Text('Ajouter un texte biblique'),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _content,
              minLines: 8,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Contenu du sermon',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tags,
              decoration: const InputDecoration(
                labelText: 'Tags (séparés par des virgules)',
                hintText: 'grâce, pardon, prière',
              ),
            ),
            const SizedBox(height: 24),
            Text('Photos de référence', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final ph in _photos)
                  PhotoThumbnail(
                    photo: ph,
                    onTap: () => showPhotoViewer(context, ph),
                    onRemove: () => setState(
                        () => _photos = _photos.where((x) => x.id != ph.id).toList()),
                  ),
                InkWell(
                  onTap: _addPhoto,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.colorScheme.outline),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.add_a_photo_outlined),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
