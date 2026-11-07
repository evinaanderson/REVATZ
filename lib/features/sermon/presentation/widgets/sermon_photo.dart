import 'dart:io';

import 'package:flutter/material.dart';

import '../../domain/entities/reference_photo.dart';

/// Photo de référence d'un sermon.
/// Sans photo (ou fichier introuvable) : image par défaut `assets/images/default.jpg`.
class SermonPhoto extends StatelessWidget {
  static const defaultAsset = 'assets/images/default.jpg';

  final ReferencePhoto? photo;
  final double? width;
  final double? height;
  final BoxFit fit;

  const SermonPhoto({
    super.key,
    required this.photo,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  Widget _fallback() =>
      Image.asset(defaultAsset, width: width, height: height, fit: fit);

  @override
  Widget build(BuildContext context) {
    final path = photo?.path;
    if (path == null) return _fallback();
    return Image.file(
      File(path),
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => _fallback(),
    );
  }
}
