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
              _buildModernHeader(),
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
                                            120,
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

  Widget _buildExpiryAlert(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.warningOrange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.warningOrange.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: AppColors.warningOrange.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.warningOrange.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.report_problem_outlined,
                color: AppColors.warningOrange,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$count document${count > 1 ? 's' : ''} expiring soon',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.warningOrange,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernHeader() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(20),
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
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                            letterSpacing: -1,
                          ),
                        ),
                        Text(
                          'Securely store your home documents',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.accentPurple.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.accentPurple.withOpacity(0.2),
                        ),
                      ),
                      child: const Icon(
                        Icons.shield_outlined,
                        color: AppColors.accentPurple,
                        size: 26,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.8),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search documents, tags...',
                      hintStyle: TextStyle(
                        color: AppColors.textHint.withOpacity(0.8),
                        fontWeight: FontWeight.w400,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        size: 22,
                        color: AppColors.accentPurple,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildFilterChip(null, 'All Categories'),
                      ...VaultCategory.values.map(
                        (c) => _buildFilterChip(c, c.displayName),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(VaultCategory? category, String label) {
    final isSelected = _selectedCategory == category;
    final color = category == null
        ? AppColors.accentPurple
        : AppColors.primaryBlue;

    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = category),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? color.withOpacity(0.5)
                : Colors.white.withOpacity(0.8),
            width: 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected
                ? Colors.white
                : AppColors.textPrimary.withOpacity(0.7),
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
