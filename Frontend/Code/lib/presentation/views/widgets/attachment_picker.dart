import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme.dart';
import '../animations/animated_list_item.dart';

// ─── Result type ──────────────────────────────────────────────────────────────

class AttachmentPickerResult {
  final String path;
  final String name;
  final AttachmentSource source;

  const AttachmentPickerResult({
    required this.path,
    required this.name,
    required this.source,
  });
}

enum AttachmentSource { camera, gallery, document, cloud }

// ─── Helper to show the sheet ─────────────────────────────────────────────────

Future<AttachmentPickerResult?> showAttachmentPickerSheet(
    BuildContext context) async {
  return showModalBottomSheet<AttachmentPickerResult>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => const AttachmentPickerSheet(),
  );
}

// ─── Sheet widget ─────────────────────────────────────────────────────────────

class AttachmentPickerSheet extends StatelessWidget {
  const AttachmentPickerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.borderPrimary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Add Attachment',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: context.textPrimaryColor,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Choose where to attach from',
            style: TextStyle(
              fontSize: 13,
              color: context.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _PickerOption(
                index: 0,
                icon: Icons.camera_alt_rounded,
                label: 'Camera',
                color: AppTheme.primaryColor,
                gradient: AppTheme.primaryGradient,
                onTap: () => _pickFromCamera(context),
              ),
              const SizedBox(width: 12),
              _PickerOption(
                index: 1,
                icon: Icons.photo_library_rounded,
                label: 'Gallery',
                color: AppTheme.secondaryColor,
                gradient: LinearGradient(
                  colors: [AppTheme.secondaryColor, AppTheme.accentColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: () => _pickFromGallery(context),
              ),
              const SizedBox(width: 12),
              _PickerOption(
                index: 2,
                icon: Icons.insert_drive_file_rounded,
                label: 'Document',
                color: AppTheme.warningColor,
                gradient: AppTheme.warningGradient,
                onTap: () => _pickDocument(context),
              ),
              const SizedBox(width: 12),
              _PickerOption(
                index: 3,
                icon: Icons.cloud_upload_rounded,
                label: 'Cloud',
                color: AppTheme.accentColor,
                gradient: AppTheme.accentGradient,
                onTap: () => _pickCloud(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Future<void> _pickFromCamera(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (image != null && context.mounted) {
        Navigator.pop(
          context,
          AttachmentPickerResult(
            path: image.path,
            name: image.name,
            source: AttachmentSource.camera,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Camera error: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _pickFromGallery(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image != null && context.mounted) {
        Navigator.pop(
          context,
          AttachmentPickerResult(
            path: image.path,
            name: image.name,
            source: AttachmentSource.gallery,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gallery error: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _pickDocument(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );
      if (result != null && result.files.isNotEmpty && context.mounted) {
        final file = result.files.first;
        if (file.path != null) {
          Navigator.pop(
            context,
            AttachmentPickerResult(
              path: file.path!,
              name: file.name,
              source: AttachmentSource.document,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File picker error: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _pickCloud(BuildContext context) async {
    // Cloud picking is a placeholder — in a real app you'd integrate
    // Google Drive / Dropbox SDK here.
    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cloud storage coming soon'),
          backgroundColor: AppTheme.accentColor,
        ),
      );
    }
  }
}

// ─── Individual picker option tile ────────────────────────────────────────────

class _PickerOption extends StatelessWidget {
  final int index;
  final IconData icon;
  final String label;
  final Color color;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _PickerOption({
    required this.index,
    required this.icon,
    required this.label,
    required this.color,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedListItem(
        index: index,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: gradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: context.textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
