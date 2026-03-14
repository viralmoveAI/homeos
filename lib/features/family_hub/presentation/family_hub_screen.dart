import 'package:flutter/material.dart';
import '../../../shared/widgets/animated_gradient_background.dart';
import '../../../core/theme/app_colors.dart';
import 'widgets/post_card.dart';
import 'widgets/create_post_sheet.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/family_hub_providers.dart';

class FamilyHubScreen extends ConsumerWidget {
  const FamilyHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(familyPostsProvider);
    return AnimatedGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Family Hub',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            'Stay connected with your family',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.people_alt_rounded,
                      color: AppColors.accentPurple,
                      size: 32,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Quick post composer bar
              GestureDetector(
                onTap: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  useRootNavigator: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const CreatePostSheet(),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 15,
                          spreadRadius: 2,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.edit_rounded,
                          size: 20,
                          color: AppColors.textHint,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Post to Family Hub...',
                          style: TextStyle(
                            color: AppColors.textHint,
                            fontSize: 15,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.image_outlined,
                          color: AppColors.primaryBlue.withOpacity(0.7),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Feed
              Expanded(
                child: postsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error: $err')),
                  data: (snap) {
                    if (snap.docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('📸', style: TextStyle(fontSize: 56)),
                            const SizedBox(height: 12),
                            const Text(
                              'The Family Hub is empty',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Be the first to share a memory!',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                      physics: const BouncingScrollPhysics(),
                      itemCount: snap.docs.length,
                      itemBuilder: (_, i) => PostCard(doc: snap.docs[i]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
