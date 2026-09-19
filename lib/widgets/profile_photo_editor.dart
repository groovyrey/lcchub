import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../theme/app_theme.dart';

/// Returned when the user chooses to delete their current photo.
enum ProfilePhotoAction { remove }

class PickedProfilePhoto {
  final Uint8List bytes;
  final String filename;
  final String mimeType;

  const PickedProfilePhoto({
    required this.bytes,
    required this.filename,
    required this.mimeType,
  });
}

enum _SheetChoice { camera, gallery, remove, cancel }

/// Shows the profile photo editing sheet.
///
/// Returns null when cancelled. Returns [PickedProfilePhoto] when the user
/// picked a new image, or [ProfilePhotoAction.remove] to delete the photo.
Future<Object?> showProfilePhotoEditor({
  required BuildContext context,
  String? currentUrl,
}) async {
  final action = await showModalBottomSheet<_SheetChoice>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text('Profile Photo', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _option(ctx, PhosphorIcons.camera(), 'Take Photo', _SheetChoice.camera),
          _option(ctx, PhosphorIcons.images(), 'Choose from Gallery', _SheetChoice.gallery),
          if (currentUrl != null && currentUrl.isNotEmpty)
            _option(ctx, PhosphorIcons.trash(), 'Remove Photo', _SheetChoice.remove),
          _option(ctx, PhosphorIcons.x(), 'Cancel', _SheetChoice.cancel),
        ],
      ),
    ),
  );

  switch (action) {
    case _SheetChoice.camera:
      final picked = await ImagePicker().pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        imageQuality: 85,
      );
      if (picked == null) return null;
      return await _fromXFile(picked);
    case _SheetChoice.gallery:
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        imageQuality: 85,
      );
      if (picked == null) return null;
      return await _fromXFile(picked);
    case _SheetChoice.remove:
      return ProfilePhotoAction.remove;
    default:
      return null;
  }
}

Future<PickedProfilePhoto> _fromXFile(XFile file) async {
  final ext = (file.name.split('.').lastOrNull ?? '').toLowerCase();
  final mime = file.mimeType ??
      (ext == 'png'
          ? 'image/png'
          : ext == 'webp'
              ? 'image/webp'
              : ext == 'gif'
                  ? 'image/gif'
                  : 'image/jpeg');
  return PickedProfilePhoto(
    bytes: await file.readAsBytes(),
    filename: file.name.isNotEmpty ? file.name : 'avatar.jpg',
    mimeType: mime,
  );
}

Widget _option(BuildContext context, IconData icon, String label, _SheetChoice choice) {
  final isRemove = choice == _SheetChoice.remove;
  final isCancel = choice == _SheetChoice.cancel;
  return ListTile(
    leading: Icon(
      icon,
      color: isRemove ? AppColors.error : AppColors.primary,
    ),
    title: Text(
      label,
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: isRemove
            ? AppColors.error
            : isCancel
                ? AppColors.onSurfaceVariant
                : AppColors.onSurface,
      ),
    ),
    onTap: () => Navigator.pop(context, choice),
  );
}