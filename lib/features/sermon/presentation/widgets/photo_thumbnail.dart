import 'dart:io';

import 'package:flutter/material.dart';

import '../../domain/entities/reference_photo.dart';

class PhotoThumbnail extends StatelessWidget {
  final ReferencePhoto photo;
  final double size;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  const PhotoThumbnail({
    super.key,
    required this.photo,
    this.size = 96,
    this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: onTap,
              child: Image.file(
                File(photo.path),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: const Icon(Icons.broken_image_outlined),
                ),
              ),
            ),
          ),
          if (onRemove != null)
            Positioned(
              top: 2,
              right: 2,
              child: InkWell(
                onTap: onRemove,
                child: const CircleAvatar(
                  radius: 11,
                  backgroundColor: Colors.black54,
                  child: Icon(Icons.close, size: 14, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Affiche une photo en plein écran (zoom possible).
void showPhotoViewer(BuildContext context, ReferencePhoto photo) {
  showDialog<void>(
    context: context,
    builder: (ctx) => Dialog.fullscreen(
      backgroundColor: Colors.black,
      child: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              maxScale: 5,
              child: Image.file(File(photo.path)),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
