import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/animated_gradient_background.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/vault_providers.dart';
import '../widgets/document_card.dart';
import '../widgets/add_document_bottom_sheet.dart';
import '../../domain/models/vault_document.dart';

class VaultScreen extends ConsumerStatefulWidget {
  const VaultScreen({super.key});

  @override
  ConsumerState<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends ConsumerState<VaultScreen> {
  final TextEditingController _searchController = TextEditingController();
  VaultCategory? _selectedCategory;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final docsAsync = ref.watch(vaultDocumentsProvider);

    return AnimatedGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: docsAsync.when(
                  data: (docs) {
                    final filteredDocs = docs.where((doc) {
                      final matchesSearch =
                          doc.title.toLowerCase().contains(
                            _searchQuery.toLowerCase(),
                          ) ||
                          (doc.description?.toLowerCase().contains(
                                _searchQuery.toLowerCase(),
                              ) ??
                              false) ||
                          doc.tags.any(
                            (tag) => tag.toLowerCase().contains(
                              _searchQuery.toLowerCase(),
                            ),
                          );
                      final matchesCategory =
                          _selectedCategory == null ||
                          doc.category == _selectedCategory;
                      return matchesSearch && matchesCategory;
                    }).toList();

                    final expiringSoonCount = docs
                        .where(
                          (doc) =>
                              doc.expiryDate != null &&
                              doc.expiryDate!.isBefore(
                                DateTime.now().add(const Duration(days: 30)),
                              ) &&
                              doc.expiryDate!.isAfter(DateTime.now()),
                        )
                        .length;

                    return Column(
                      children: [
                        if (expiringSoonCount > 0)
                          _buildExpiryAlert(expiringSoonCount),
                        _buildFilterBar(),
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(36),
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(36),
                              ),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 15,
                                  sigmaY: 15,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.4),
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(36),
                                    ),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.4),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: filteredDocs.isEmpty
                                      ? _buildEmptyState()
                                      : ListView.builder(
                                          padding: const EdgeInsets.fromLTRB(
                                            20,
                                            24,
                                            20,
                                            120, // Increased to ensure no overlap and account for 80pt requested
                                          ),
                                          itemCount: filteredDocs.length,
                                          itemBuilder: (context, index) {
                                            final doc = filteredDocs[index];
                                            return DocumentCard(
                                              document: doc,
                                              onEdit: () =>
                                                  showModalBottomSheet(
                                                    context: context,
                                                    isScrollControlled: true,
                                                    useRootNavigator: true,
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    builder: (context) =>
                                                        AddDocumentBottomSheet(
                                                          document: doc,
                                                        ),
                                                  ),
                                              onDelete: () => ref
                                                  .read(
                                                    vaultNotifierProvider
                                                        .notifier,
                                                  )
                                                  .deleteDocument(doc.id),
                                            );
                                          },
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Center(child: Text('Error: $e')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Digital Vault',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Securely store your home documents',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accentPurple.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.security,
                  color: AppColors.accentPurple,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: const InputDecoration(
                hintText: 'Search documents, tags...',
                prefixIcon: Icon(Icons.search, color: AppColors.textHint),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpiryAlert(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange[50]!.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.warningOrange.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.report_problem_outlined,
              color: AppColors.warningOrange,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$count document${count > 1 ? 's' : ''} expiring soon',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.warningOrange,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      clipBehavior: Clip.none,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Row(
        children: [
          _buildFilterChip(null, 'All Categories'),
          ...VaultCategory.values.map(
            (c) => _buildFilterChip(c, c.displayName),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(VaultCategory? category, String label) {
    final isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = category),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              )
            else
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open_outlined,
            size: 64,
            color: AppColors.textHint.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Vault is Empty',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start by adding your first document',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
