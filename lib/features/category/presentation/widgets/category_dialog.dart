import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/category.dart';
import '../state/category_providers.dart';

const kCategoryColors = <int>[
  0xFF1565C0,
  0xFF2E7D32,
  0xFFC62828,
  0xFF6A1B9A,
  0xFFEF6C00,
  0xFF00838F,
  0xFF4E342E,
  0xFF455A64,
];

/// Création ou modification d'une catégorie (si [category] est fourni).
Future<void> showCategoryDialog(BuildContext context, {Category? category}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _CategoryDialog(category: category),
  );
}

class _CategoryDialog extends ConsumerStatefulWidget {
  final Category? category;
  const _CategoryDialog({this.category});

  @override
  ConsumerState<_CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends ConsumerState<_CategoryDialog> {
  late final TextEditingController _name;
  late int _color;
  String? _error;
  bool _saving = false;

  bool get _isEdit => widget.category != null;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.category?.name ?? '');
    _color = widget.category?.colorValue ?? kCategoryColors.first;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    final actions = ref.read(categoryActionsProvider);
    final result = _isEdit
        ? await actions.update(
            widget.category!.copyWith(name: _name.text, colorValue: _color))
        : await actions.add(_name.text, _color);
    if (!mounted) return;
    result.when<void>(
      success: (_) => Navigator.pop(context),
      failure: (f) => setState(() {
        _saving = false;
        _error = f.message;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEdit ? 'Modifier la catégorie' : 'Nouvelle catégorie'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _name,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(labelText: 'Nom', errorText: _error),
            onSubmitted: (_) => _saving ? null : _save(),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final c in kCategoryColors)
                GestureDetector(
                  onTap: () => setState(() => _color = c),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Color(c),
                    child: _color == c
                        ? const Icon(Icons.check, size: 18, color: Colors.white)
                        : null,
                  ),
                ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: _saving ? null : () => Navigator.pop(context),
            child: const Text('Annuler')),
        FilledButton(
            onPressed: _saving ? null : _save, child: const Text('Enregistrer')),
      ],
    );
  }
}
