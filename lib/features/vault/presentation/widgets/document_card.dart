import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/vault_document.dart';

class DocumentCard extends StatelessWidget {
  final VaultDocument document;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const DocumentCard({
    super.key,
    required this.document,
    this.onEdit,
    this.onDelete,
  });

  IconData _getFileIcon() {
    switch (document.fileType) {
      case FileType.pdf:
        return Icons.picture_as_pdf_outlined;
      case FileType.image:
        return Icons.image_outlined;
      case FileType.document:
        return Icons.description_outlined;
      case FileType.other:
        return Icons.insert_drive_file_outlined;
    }
  }

  Color _getCategoryColor() {
    switch (document.category) {
      case VaultCategory.property:
        return Colors.deepPurple;
      case VaultCategory.insurance:
        return Colors.blue;
      case VaultCategory.utilityService:
        return Colors.teal;
      case VaultCategory.applianceManual:
        return Colors.orange;
      case VaultCategory.maintenanceRecord:
        return Colors.green;
      case VaultCategory.legalTax:
        return Colors.indigo;
      case VaultCategory.vehicle:
        return Colors.blueGrey;
      case VaultCategory.emergency:
        return Colors.red;
      case VaultCategory.other:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isExpiringSoon =
        document.expiryDate != null &&
        document.expiryDate!.isBefore(
          DateTime.now().add(const Duration(days: 30)),
        );
    final catColor = _getCategoryColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getFileIcon(),
                  color: Colors.blue.shade800,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      document.category.displayName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: catColor.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: onEdit,
                    icon: Icon(
                      Icons.edit_outlined,
                      size: 20,
                      color: AppColors.textSecondary.withOpacity(0.6),
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    onPressed: onDelete,
                    icon: Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: AppColors.errorRed.withOpacity(0.6),
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ],
          ),
          if (document.description != null &&
              document.description!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              document.description!,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              if (document.fileReference != null) ...[
                Icon(Icons.attach_file, size: 14, color: AppColors.textHint),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    document.fileReference!,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textHint,
                      fontStyle: FontStyle.italic,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              if (document.expiryDate != null) ...[
                const Spacer(),
                Icon(
                  Icons.event_note_outlined,
                  size: 14,
                  color: isExpiringSoon
                      ? AppColors.errorRed
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Expiring: ${DateFormat('MM/dd/yyyy').format(document.expiryDate!)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isExpiringSoon
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isExpiringSoon
                        ? AppColors.errorRed
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
          if (document.tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: document.tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.textHint.withOpacity(0.1),
                    ),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
