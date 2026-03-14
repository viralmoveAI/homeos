import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/user_avatar.dart';
import 'comments_section.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/family_hub_providers.dart';
import '../../../../core/providers/auth_providers.dart';

class PostCard extends ConsumerStatefulWidget {
  final QueryDocumentSnapshot doc;
  const PostCard({super.key, required this.doc});

  @override
  ConsumerState<PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<PostCard> {
  bool _showComments = false;

  Map<String, dynamic> get _data => widget.doc.data() as Map<String, dynamic>;
  String get _postId => widget.doc.id;

  String get _authorName => _data['authorName'] ?? 'User';
  String get _content => _data['content'] ?? '';
  String? get _imageUrl => _data['imageUrl'] as String?;
  int get _commentCount => (_data['commentCount'] ?? 0) as int;
  Map<String, dynamic> get _reactions =>
      Map<String, dynamic>.from(_data['reactions'] ?? {});

  String get _timeAgo {
    final ts = _data['createdAt'] as Timestamp?;
    if (ts == null) return 'Just now';
    final dt = ts.toDate();
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 365) return '${(diff.inDays / 365).floor()} year(s) ago';
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()} month(s) ago';
    if (diff.inDays > 0) return '${diff.inDays} day(s) ago';
    if (diff.inHours > 0) return '${diff.inHours} hr ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes} min ago';
    return 'Just now';
  }

  bool get _isMe {
    final uid = ref.watch(authStateProvider).value?.uid;
    return _data['authorId'] == uid;
  }

  String? get _myReaction {
    final uid = ref.watch(authStateProvider).value?.uid;
    if (uid == null) return null;
    for (final entry in _reactions.entries) {
      final list = List<String>.from(entry.value as List? ?? []);
      if (list.contains(uid)) return entry.key;
    }
    return null;
  }

  int _totalReactions() {
    int total = 0;
    for (final v in _reactions.values) {
      total += (v as List).length;
    }
    return total;
  }

  void _showEditPostDialog() {
    final controller = TextEditingController(text: _content);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Post'),
          content: TextField(
            controller: controller,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Edit your post...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final newContent = controller.text.trim();
                if (newContent.isNotEmpty) {
                  ref
                      .read(familyHubServiceProvider)
                      .editPost(_postId, newContent, _imageUrl);
                }
                Navigator.pop(context);
              },
              child: const Text('Save Changes'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Row(
                  children: [
                    UserAvatar(name: _authorName, radius: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _authorName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            _timeAgo,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_isMe)
                      PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.more_horiz,
                          color: AppColors.textSecondary,
                        ),
                        onSelected: (val) {
                          if (val == 'edit') {
                            _showEditPostDialog();
                          } else if (val == 'delete') {
                            ref
                                .read(familyHubServiceProvider)
                                .deletePost(_postId);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.edit,
                                  size: 20,
                                  color: AppColors.primaryBlue,
                                ),
                                SizedBox(width: 8),
                                Text('Edit Post'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete,
                                  size: 20,
                                  color: AppColors.errorRed,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Delete Post',
                                  style: TextStyle(color: AppColors.errorRed),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              // Content
              if (_content.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Text(
                    _content,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ),

              // Image
              if (_imageUrl != null && _imageUrl!.isNotEmpty)
                ClipRRect(
                  child: Image.network(
                    _imageUrl!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),

              // Reaction summary
              if (_totalReactions() > 0)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: _ReactionSummary(reactions: _reactions),
                ),

              // Divider
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Divider(color: Colors.grey.shade200, height: 1),
              ),

              // Action bar: reactions + comment button
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Row(
                  children: [
                    // Emoji reactions
                    ..._buildReactionButtons(),
                    const Spacer(),
                    // Comment
                    GestureDetector(
                      onTap: () =>
                          setState(() => _showComments = !_showComments),
                      child: Row(
                        children: [
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 20,
                            color: _showComments
                                ? AppColors.primaryBlue
                                : AppColors.textSecondary,
                          ),
                          if (_commentCount > 0) ...[
                            const SizedBox(width: 4),
                            Text(
                              '$_commentCount',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Comments section
              if (_showComments) CommentsSection(postId: _postId),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildReactionButtons() {
    const emojis = ['❤️', '👍', '😂', '😮', '😢'];
    return emojis.map((emoji) {
      final list = List<String>.from(_reactions[emoji] as List? ?? []);
      final isSelected = _myReaction == emoji;
      return GestureDetector(
        onTap: () => ref
            .read(familyHubServiceProvider)
            .toggleReaction(postId: _postId, emoji: emoji),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryBlue.withOpacity(0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              if (list.isNotEmpty) ...[
                const SizedBox(width: 2),
                Text(
                  '${list.length}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? AppColors.primaryBlue
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }).toList();
  }
}

class _ReactionSummary extends StatelessWidget {
  final Map<String, dynamic> reactions;
  const _ReactionSummary({required this.reactions});

  @override
  Widget build(BuildContext context) {
    final active = reactions.entries
        .where((e) => (e.value as List).isNotEmpty)
        .toList();
    if (active.isEmpty) return const SizedBox.shrink();

    int total = 0;
    for (final e in active) {
      total += (e.value as List).length;
    }

    return Row(
      children: [
        ...active
            .take(3)
            .map((e) => Text(e.key, style: const TextStyle(fontSize: 14))),
        const SizedBox(width: 4),
        Text(
          '$total',
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
