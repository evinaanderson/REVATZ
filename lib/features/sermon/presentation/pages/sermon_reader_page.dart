import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../../core/presentation/widgets/empty_state.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';
import '../../domain/services/rich_content.dart';
import '../state/sermon_providers.dart';
import '../widgets/rich_content_view.dart';

enum _ReaderTheme {
  light('Clair', Color(0xFFFFFFFF), Color(0xFF111111)),
  dark('Sombre', Color(0xFF0B1F4B), Color(0xFFF5F5F5)),
  sepia('Sépia', Color(0xFFF4ECD8), Color(0xFF4A3B2A));

  final String label;
  final Color background;
  final Color text;
  const _ReaderTheme(this.label, this.background, this.text);
}

/// Mode lecture : texte agrandi, zoom (pincement ou curseur), thème de lecture,
/// écran maintenu allumé pendant la lecture.
class SermonReaderPage extends ConsumerStatefulWidget {
  final String sermonId;
  const SermonReaderPage({super.key, required this.sermonId});

  @override
  ConsumerState<SermonReaderPage> createState() => _SermonReaderPageState();
}

class _SermonReaderPageState extends ConsumerState<SermonReaderPage> {
  static const _minScale = 0.8;
  static const _maxScale = 3.0;
  static const _kScale = 'reader_scale';
  static const _kTheme = 'reader_theme';

  late final SharedPreferences _prefs;
  double _scale = 1.0;
  double _baseScale = 1.0;
  _ReaderTheme _theme = _ReaderTheme.light;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _prefs = sl<SharedPreferences>();
    _scale = (_prefs.getDouble(_kScale) ?? 1.0).clamp(_minScale, _maxScale).toDouble();
    final themeIndex = _prefs.getInt(_kTheme) ?? 0;
    _theme = _ReaderTheme.values[themeIndex.clamp(0, _ReaderTheme.values.length - 1)];
    try {
      WakelockPlus.enable();
    } catch (_) {}
  }

  @override
  void dispose() {
    try {
      WakelockPlus.disable();
    } catch (_) {}
    super.dispose();
  }

  void _setScale(double value) {
    final v = value.clamp(_minScale, _maxScale).toDouble();
    setState(() => _scale = v);
    _prefs.setDouble(_kScale, v);
  }

  void _setTheme(_ReaderTheme t) {
    setState(() => _theme = t);
    _prefs.setInt(_kTheme, t.index);
  }

  Widget _controls() {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  IconButton(
                    tooltip: 'Réduire',
                    icon: const Icon(Icons.text_decrease),
                    onPressed: () => _setScale(_scale - 0.1),
                  ),
                  Expanded(
                    child: Slider(
                      min: _minScale,
                      max: _maxScale,
                      value: _scale,
                      onChanged: (v) => setState(() => _scale = v),
                      onChangeEnd: _setScale,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Agrandir',
                    icon: const Icon(Icons.text_increase),
                    onPressed: () => _setScale(_scale + 0.1),
                  ),
                  TextButton(
                    onPressed: () => _setScale(1.0),
                    child: Text('${(_scale * 100).round()} %'),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final t in _ReaderTheme.values)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(t.label),
                        selected: _theme == t,
                        onSelected: (_) => _setTheme(t),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sermon = ref.watch(sermonByIdProvider(widget.sermonId));
    if (sermon == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(icon: Icons.search_off, title: 'Sermon introuvable'),
      );
    }

    final base = Theme.of(context);
    final bg = _theme.background;
    final fg = _theme.text;
    final themed = base.copyWith(
      scaffoldBackgroundColor: bg,
      colorScheme: base.colorScheme.copyWith(surface: bg, onSurface: fg),
      textTheme: base.textTheme.apply(bodyColor: fg, displayColor: fg),
    );

    return Theme(
      data: themed,
      child: Builder(
        builder: (context) => Scaffold(
          backgroundColor: bg,
          appBar: AppBar(
            title: const Text('Mode lecture'),
            actions: [
              IconButton(
                tooltip: _showControls ? 'Masquer les réglages' : 'Réglages de lecture',
                icon: Icon(_showControls ? Icons.keyboard_arrow_down : Icons.tune),
                onPressed: () => setState(() => _showControls = !_showControls),
              ),
            ],
          ),
          body: GestureDetector(
            // Zoom par pincement (deux doigts) ; un doigt = défilement.
            onScaleStart: (_) => _baseScale = _scale,
            onScaleUpdate: (d) {
              if (d.pointerCount >= 2) {
                setState(() => _scale =
                    (_baseScale * d.scale).clamp(_minScale, _maxScale).toDouble());
              }
            },
            onScaleEnd: (_) => _prefs.setDouble(_kScale, _scale),
            child: MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(_scale)),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                child: DefaultTextStyle(
                  style: TextStyle(color: fg, fontSize: 16, height: 1.4),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sermon.title,
                          style: TextStyle(
                            color: fg,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            height: 1.25,
                          ),
                        ),
                        if (!RichContent.isBlank(sermon.content)) ...[
                          const SizedBox(height: 16),
                          RichContentView(content: sermon.content),
                        ],
                        if (sermon.passages.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          for (final p in sermon.passages) ...[
                            Text(
                              p.reference,
                              style: TextStyle(
                                color: _theme == _ReaderTheme.light
                                    ? AppColors.goldDark
                                    : AppColors.gold,
                                fontWeight: FontWeight.w800,
                                fontSize: 17,
                              ),
                            ),
                            if (p.text.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 2, bottom: 14),
                                child: Text(
                                  '« ${p.text} »',
                                  style: TextStyle(
                                    color: fg,
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                    height: 1.4,
                                  ),
                                ),
                              )
                            else
                              const SizedBox(height: 12),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          bottomNavigationBar: _showControls ? _controls() : null,
        ),
      ),
    );
  }
}
