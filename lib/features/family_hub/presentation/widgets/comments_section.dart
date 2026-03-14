import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/user_avatar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/family_hub_providers.dart';
import '../../../../core/providers/auth_providers.dart';

class CommentsSection extends ConsumerStatefulWidget {
  final String postId;
  const CommentsSection({super.key, required this.postId});

  @override
  ConsumerState<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends ConsumerState<CommentsSection> {
  final _controller = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);
    await ref
        .read(familyHubServiceProvider)
        .addComment(postId: widget.postId, text: text);
    _controller.clear();
    setState(() => _sending = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: ref
                .watch(familyHubServiceProvider)
                .commentsStream(widget.postId),
            builder: (context, snap) {
              if (!snap.hasData || snap.data!.docs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(
                    'No comments yet',
                    style: TextStyle(color: AppColors.textHint, fontSize: 13),
                  ),
                );
              }
              return Column(
                children: snap.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = data['authorName'] ?? 'User';
                  final text = data['text'] ?? '';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        UserAvatar(name: name, radius: 14),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  text,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
          // Comment input
          Row(
            children: [
              UserAvatar(
                name: ref.watch(authStateProvider).value?.displayName ?? 'Me',
                radius: 14,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Write a comment...',
                    hintStyle: const TextStyle(
                      color: AppColors.textHint,
                      fontSize: 13,
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.7),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: _sending
                        ? const Padding(
                            padding: EdgeInsets.all(10),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : IconButton(
                            icon: const Icon(
                              Icons.send_rounded,
                              size: 20,
                              color: AppColors.primaryBlue,
                            ),
                            onPressed: _send,
                          ),
                  ),
                  onSubmitted: (_) => _send(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
