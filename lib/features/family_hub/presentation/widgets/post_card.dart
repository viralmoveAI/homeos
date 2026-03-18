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
  String? get _feeling => _data['feeling'] as String?;
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
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                UserAvatar(name: _authorName, radius: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: _authorName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black,
                                letterSpacing: -0.2,
                              ),
                            ),
                            if (_feeling != null) ...[
                              const TextSpan(
                                text: ' is feeling ',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              TextSpan(
                                text: _feeling,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            _timeAgo,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "•",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.public,
                            size: 13,
                            color: Colors.grey.shade600,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (_isMe)
                  PopupMenuButton<String>(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    icon: Icon(Icons.more_horiz, color: Colors.grey.shade600),
                    onSelected: (val) {
                      if (val == 'edit') {
                        _showEditPostDialog();
                      } else if (val == 'delete') {
                        ref.read(familyHubServiceProvider).deletePost(_postId);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 20),
                            SizedBox(width: 12),
                            Text('Edit Post'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              color: AppColors.errorRed,
                              size: 20,
                            ),
                            SizedBox(width: 12),
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
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Text(
                _content,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ),

          // Image
          if (_imageUrl != null && _imageUrl!.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade100),
                  bottom: BorderSide(color: Colors.grey.shade100),
                ),
              ),
              child: Image.network(
                _imageUrl!,
                width: double.infinity,
                fit: BoxFit.fitWidth,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),

          // Reaction summary (FB style)
          if (_totalReactions() > 0 || _commentCount > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  if (_totalReactions() > 0)
                    _ReactionSummary(reactions: _reactions),
                  const Spacer(),
                  if (_commentCount > 0)
                    Text(
                      '$_commentCount ${_commentCount == 1 ? 'comment' : 'comments'}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
            ),

          // Divider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(color: Colors.grey.shade200, height: 1),
          ),

          // Action bar (Like, Comment, Share)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Row(
              children: [
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        final currentReact = _myReaction;
                        if (currentReact != null) {
                          ref
                              .read(familyHubServiceProvider)
                              .toggleReaction(
                                postId: _postId,
                                emoji: currentReact,
                              );
                        } else {
                          ref
                              .read(familyHubServiceProvider)
                              .toggleReaction(postId: _postId, emoji: '👍');
                        }
                      },
                      onLongPress: _showEmojiPicker,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _myReaction != null
                                  ? Icons.thumb_up_rounded
                                  : Icons.thumb_up_off_alt_rounded,
                              size: 20,
                              color: _myReaction != null
                                  ? AppColors.primaryBlue
                                  : Colors.grey.shade700,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _myReaction ?? 'Like',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _myReaction != null
                                    ? AppColors.primaryBlue
                                    : Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () =>
                          setState(() => _showComments = !_showComments),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 20,
                              color: Colors.grey.shade700,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Comment',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        // Share functionality would go here
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Share functionality coming soon!'),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.share_outlined,
                              size: 20,
                              color: Colors.grey.shade700,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Share',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Comments section
          if (_showComments)
            Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade100)),
              ),
              child: CommentsSection(postId: _postId),
            ),
        ],
      ),
    );
  }

  void _showEmojiPicker() {
    final extraEmojis = [
      '❤️',
      '💖',
      '✨',
      '🔥',
      '👏',
      '🥳',
      '💯',
      '🙏',
      '👀',
      '🤔',
      '💪',
      '🌈',
      '🍦',
      '🍕',
      '🎉',
      '🌟',
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white.withOpacity(0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(20),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Choose a Reaction',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 20),
              GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemCount: extraEmojis.length,
                itemBuilder: (context, index) {
                  final emoji = extraEmojis[index];
                  return GestureDetector(
                    onTap: () {
                      ref
                          .read(familyHubServiceProvider)
                          .toggleReaction(postId: _postId, emoji: emoji);
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primaryBlue.withOpacity(0.1),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
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
        SizedBox(
          width: 20.0 + (active.length > 1 ? (active.length - 1) * 14.0 : 0),
          height: 20,
          child: Stack(
            children: [
              for (int i = 0; i < active.length && i < 3; i++)
                Positioned(
                  left: i * 14.0,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    child: Text(
                      active[i].key,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$total',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
