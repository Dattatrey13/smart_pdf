import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf_app/core/theme/app_theme.dart';
import 'package:pdf_app/core/widgets/common_widgets.dart';

class UploadPanel extends StatelessWidget {
  final File? selectedFile;
  final bool uploading;
  final bool uploaded;
  final String? status;
  final VoidCallback onPickPdf;
  final VoidCallback onUpload;
  final VoidCallback onTestConnection;

  const UploadPanel({
    super.key,
    this.selectedFile,
    required this.uploading,
    required this.uploaded,
    this.status,
    required this.onPickPdf,
    required this.onUpload,
    required this.onTestConnection,
  });

  StatusType _statusType() {
    if (status == null) return StatusType.info;
    if (uploading) return StatusType.loading;
    if (status!.contains('✓') || status!.contains('ready') || status!.contains('complete') || uploaded) {
      return StatusType.success;
    }
    if (status!.contains('error') || status!.contains('✗') || status!.contains('Cannot')) {
      return StatusType.error;
    }
    return StatusType.info;
  }

  @override
  Widget build(BuildContext context) {
    final fileName = selectedFile != null
        ? selectedFile!.path.split(Platform.pathSeparator).last
        : null;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.primary.withOpacity(0.12),
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // File selector row
          GlowCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: selectedFile != null
                        ? AppTheme.error.withOpacity(0.15)
                        : AppTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selectedFile != null
                          ? AppTheme.error.withOpacity(0.3)
                          : const Color(0xFF2A2A4A),
                    ),
                  ),
                  child: Icon(
                    Icons.picture_as_pdf_rounded,
                    color: selectedFile != null
                        ? AppTheme.error
                        : AppTheme.onSurfaceMuted,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileName ?? 'No PDF selected',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: fileName != null
                              ? FontWeight.w500
                              : FontWeight.w400,
                          color: fileName != null
                              ? AppTheme.onSurface
                              : AppTheme.onSurfaceMuted,
                          fontFamily: 'Outfit',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (selectedFile != null)
                        Text(
                          '${(selectedFile!.lengthSync() / 1024).toStringAsFixed(1)} KB',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.onSurfaceMuted,
                            fontFamily: 'Outfit',
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _SmallButton(
                  icon: Icons.folder_open_rounded,
                  label: 'Browse',
                  onTap: uploading ? null : onPickPdf,
                  color: AppTheme.accent,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Action row
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: uploading ? null : Icons.cloud_upload_rounded,
                  label: uploading ? 'Uploading...' : 'Upload & Index',
                  loading: uploading,
                  onTap: (selectedFile != null && !uploading) ? onUpload : null,
                  gradient: AppTheme.primaryGradient,
                ),
              ),
              const SizedBox(width: 10),
              _SmallButton(
                icon: Icons.wifi_tethering_rounded,
                label: 'Test',
                onTap: uploading ? null : onTestConnection,
                color: AppTheme.onSurfaceMuted,
                outlined: true,
              ),
            ],
          ),
          // Status
          if (status != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                StatusChip(label: status!, type: _statusType()),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData? icon;
  final String label;
  final VoidCallback? onTap;
  final LinearGradient gradient;
  final bool loading;

  const _ActionButton({
    this.icon,
    required this.label,
    this.onTap,
    required this.gradient,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            gradient: enabled ? gradient : null,
            color: enabled ? null : AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(12),
            border: enabled
                ? null
                : Border.all(color: const Color(0xFF2A2A4A)),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (loading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white54,
                  ),
                )
              else if (icon != null)
                Icon(
                  icon,
                  color: enabled ? Colors.white : AppTheme.onSurfaceMuted,
                  size: 16,
                ),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: enabled ? Colors.white : AppTheme.onSurfaceMuted,
                  fontFamily: 'Outfit',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmallButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color color;
  final bool outlined;

  const _SmallButton({
    required this.icon,
    required this.label,
    this.onTap,
    required this.color,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: outlined ? Colors.transparent : color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: enabled ? color.withOpacity(0.4) : const Color(0xFF2A2A4A),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  color: enabled ? color : AppTheme.onSurfaceMuted, size: 14),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: enabled ? color : AppTheme.onSurfaceMuted,
                  fontFamily: 'Outfit',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}