import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:saver_gallery/saver_gallery.dart';
import '../../../core/theme/app_theme.dart';

class NewsImageAttachment extends StatefulWidget {
  const NewsImageAttachment({
    super.key,
    required this.imageUrl,
    required this.newsId,
  });

  final String imageUrl;
  final String newsId;

  @override
  State<NewsImageAttachment> createState() => _NewsImageAttachmentState();
}

String _imageExtensionFromBytes(List<int> bytes, String imageUrl) {
  bool matches(List<int> signature) {
    return bytes.length >= signature.length &&
        List.generate(
          signature.length,
              (index) => bytes[index] == signature[index],
        ).every((match) => match);
  }

  // JPEG
  if (matches([0xFF, 0xD8, 0xFF])) return 'jpg';

  // PNG
  if (matches([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])) {
    return 'png';
  }

  // GIF
  if (matches([0x47, 0x49, 0x46, 0x38, 0x37, 0x61]) ||
      matches([0x47, 0x49, 0x46, 0x38, 0x39, 0x61])) {
    return 'gif';
  }

  // WebP
  if (bytes.length >= 12 &&
      matches([0x52, 0x49, 0x46, 0x46]) &&
      String.fromCharCodes(bytes.sublist(8, 12)) == 'WEBP') {
    return 'webp';
  }

  // BMP
  if (matches([0x42, 0x4D])) return 'bmp';

  // TIFF
  if (matches([0x49, 0x49, 0x2A, 0x00]) ||
      matches([0x4D, 0x4D, 0x00, 0x2A])) {
    return 'tiff';
  }

  // AVIF
  if (bytes.length >= 12 &&
      String.fromCharCodes(bytes.sublist(4, 8)) == 'ftyp') {
    final brand = String.fromCharCodes(bytes.sublist(8, 12));

    if (brand == 'avif' || brand == 'avis') return 'avif';

    if ([
      'heic',
      'heix',
      'hevc',
      'hevx',
      'mif1',
      'msf1',
    ].contains(brand)) {
      return 'heic';
    }
  }

  // Si no se reconoce la firma, intenta obtener la extensión de la URL.
  final uri = Uri.tryParse(imageUrl);
  final path = uri?.path ?? '';
  final match = RegExp(r'\.([a-zA-Z0-9]+)$').firstMatch(path);
  final extension = match?.group(1)?.toLowerCase();

  const supportedExtensions = {
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp',
    'bmp',
    'tif',
    'tiff',
    'avif',
    'heic',
  };

  if (extension != null && supportedExtensions.contains(extension)) {
    return extension == 'jpeg' ? 'jpg' : extension;
  }

  throw const FormatException(
    'No se pudo identificar el formato de la imagen.',
  );
}

class _NewsImageAttachmentState extends State<NewsImageAttachment> {
  bool _downloading = false;

  String get _heroTag => 'news-image-${widget.newsId}';

  Future<void> _downloadImage() async {
    if (_downloading) return;
    setState(() => _downloading = true);

    try {
      final bytes = await _downloadImageBytes(widget.imageUrl);

      // Detecta el formato real de la imagen para asignar su extensión.
      final extension = _imageExtensionFromBytes(
        bytes,
        widget.imageUrl,
      );

      final result = await SaverGallery.saveImage(
        bytes,
        quality: 100,
        fileName:
        'cuc_noticia_${widget.newsId}_${DateTime.now().millisecondsSinceEpoch}.$extension',
        skipIfExists: false,
      );

      if (!result.isSuccess) {
        throw Exception(
          result.errorMessage ?? 'El dispositivo no pudo guardar la imagen.',
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Imagen guardada en tu galería.'),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo guardar la imagen. Inténtalo de nuevo.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _downloading = false);
      }
    }
  }

  void _openViewer() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _NewsImageViewer(
          imageUrl: widget.imageUrl,
          heroTag: _heroTag,
          onDownload: _downloadImage,
          isDownloading: _downloading,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Abrir imagen de la noticia',
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Material(
            color: AppColors.background,
            child: InkWell(
              onTap: _openViewer,
              child: Hero(
                tag: _heroTag,
                child: CachedNetworkImage(
                  imageUrl: widget.imageUrl,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  placeholder: (_, __) => const AspectRatio(
                    aspectRatio: 4 / 3,
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  errorWidget: (_, __, ___) => const AspectRatio(
                    aspectRatio: 4 / 3,
                    child: _NewsImageError(),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Material(
              color: Colors.black54,
              shape: const CircleBorder(),
              child: IconButton(
                tooltip: 'Guardar imagen',
                onPressed: _downloading ? null : _downloadImage,
                color: Colors.white,
                icon: _downloading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.download_outlined),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NewsImageViewer extends StatelessWidget {
  const _NewsImageViewer({
    required this.imageUrl,
    required this.heroTag,
    required this.onDownload,
    required this.isDownloading,
  });

  final String imageUrl;
  final String heroTag;
  final VoidCallback onDownload;
  final bool isDownloading;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Imagen de la noticia'),
        actions: [
          IconButton(
            tooltip: 'Guardar imagen',
            onPressed: isDownloading ? null : onDownload,
            icon: isDownloading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.download_outlined),
          ),
        ],
      ),
      body: InteractiveViewer(
        minScale: 0.8,
        maxScale: 4,
        child: Center(
          child: Hero(
            tag: heroTag,
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              width: double.infinity,
              fit: BoxFit.contain,
              placeholder: (_, __) => const CircularProgressIndicator(
                color: AppColors.primary,
              ),
              errorWidget: (_, __, ___) => const _NewsImageError(),
            ),
          ),
        ),
      ),
    );
  }
}

class _NewsImageError extends StatelessWidget {
  const _NewsImageError();



  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.broken_image_outlined, color: AppColors.muted, size: 32),
        SizedBox(height: 8),
        Text(
          'No se pudo cargar la imagen',
          style: TextStyle(color: AppColors.muted, fontSize: 12),
        ),
      ],
    );
  }
}

Future<Uint8List> _downloadImageBytes(String imageUrl) async {
  final client = HttpClient();
  try {
    final request = await client.getUrl(Uri.parse(imageUrl));
    final response = await request.close();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException('Respuesta HTTP ${response.statusCode}');
    }

    final builder = BytesBuilder(copy: false);
    await for (final chunk in response) {
      builder.add(chunk);
    }
    return builder.takeBytes();
  } finally {
    client.close(force: true);
  }
}
