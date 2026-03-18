import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/animated_gradient_background.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/family_hub_providers.dart';
import '../../../core/providers/auth_providers.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String groupId;
  final String groupName;
  final String groupEmoji;

  const ChatScreen({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.groupEmoji,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  File? _selectedImage;
  bool _loading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty && _selectedImage == null) return;

    setState(() => _loading = true);

    try {
      String? imageUrl;
      final service = ref.read(familyHubServiceProvider);

      if (_selectedImage != null) {
        final path = 'family_hub/messages/${const Uuid().v4()}.jpg';
        imageUrl = await service.uploadImage(_selectedImage!, path);
      }

      _controller.clear();
      setState(() => _selectedImage = null);

      await service.sendMessage(
        groupId: widget.groupId,
        text: text,
        imageUrl: imageUrl,
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final myUid = ref.watch(authStateProvider).value?.uid;

    return AnimatedGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.white.withOpacity(0.3),
          elevation: 0,
          title: Row(
            children: [
              Text(widget.groupEmoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 10),
              Text(
                widget.groupName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.info_outline_rounded,
                color: AppColors.primaryBlue,
              ),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  builder: (_) => _GroupInfoSheet(
                    groupId: widget.groupId,
                    groupName: widget.groupName,
                    groupEmoji: widget.groupEmoji,
                  ),
                );
              },
            ),
          ],
          flexibleSpace: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(color: Colors.transparent),
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: ref
                    .watch(familyHubServiceProvider)
                    .messagesStream(widget.groupId),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snap.hasData || snap.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.groupEmoji,
                            style: const TextStyle(fontSize: 56),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No messages yet',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Say hi to start the conversation! 👋',
                            style: TextStyle(color: AppColors.textHint),
                          ),
                        ],
                      ),
                    );
                  }

                  _scrollToBottom();
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    itemCount: snap.data!.docs.length,
                    itemBuilder: (_, i) {
                      final doc = snap.data!.docs[i];
                      final data = doc.data() as Map<String, dynamic>;
                      final isMe = data['senderId'] == myUid;
                      final name = data['senderName'] ?? 'User';
                      final text = data['text'] ?? '';
                      final imageUrl = data['imageUrl'] as String?;
                      final messageId = doc.id;

                      return _MessageBubble(
                        isMe: isMe,
                        name: name,
                        text: text,
                        imageUrl: imageUrl,
                        messageId: messageId,
                        groupId: widget.groupId,
                      );
                    },
                  );
                },
              ),
            ),
            // Input bar
            Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: MediaQuery.of(context).padding.bottom + 16,
              ),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.3)),
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.image,
                          color: AppColors.primaryBlue,
                        ),
                        onPressed: _pickImage,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_selectedImage != null)
                              Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  Container(
                                    height: 100,
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(bottom: 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      image: DecorationImage(
                                        image: FileImage(_selectedImage!),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.cancel,
                                      color: Colors.white,
                                    ),
                                    onPressed: () =>
                                        setState(() => _selectedImage = null),
                                  ),
                                ],
                              ),
                            TextField(
                              controller: _controller,
                              style: const TextStyle(
                                fontSize: 15,
                                color: AppColors.textPrimary,
                              ),
                              onSubmitted: (_) => _send(),
                              decoration: InputDecoration(
                                hintText: 'Message...',
                                hintStyle: const TextStyle(
                                  color: AppColors.textHint,
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.8),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: _send,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.primaryBlue,
                                AppColors.accentPurple,
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryBlue.withOpacity(0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: _loading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(
                                    Icons.send,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends ConsumerWidget {
  final bool isMe;
  final String name;
  final String text;
  final String? imageUrl;
  final String messageId;
  final String groupId;

  const _MessageBubble({
    required this.isMe,
    required this.name,
    required this.text,
    this.imageUrl,
    required this.messageId,
    required this.groupId,
  });

  void _showOptions(BuildContext context, WidgetRef ref) {
    if (!isMe) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: AppColors.primaryBlue),
                title: const Text('Edit Message'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditDialog(context, ref);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: AppColors.errorRed),
                title: const Text('Delete Message'),
                onTap: () {
                  Navigator.pop(context);
                  ref
                      .read(familyHubServiceProvider)
                      .deleteMessage(groupId, messageId);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(text: text);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Message'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Enter new message'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final newText = controller.text.trim();
                if (newText.isNotEmpty) {
                  ref
                      .read(familyHubServiceProvider)
                      .editMessage(groupId, messageId, newText);
                }
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onLongPress: () => _showOptions(context, ref),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment: isMe
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe) ...[
              CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.accentPurple,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Column(
                crossAxisAlignment: isMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  if (!isMe)
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 4),
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: isMe
                          ? const LinearGradient(
                              colors: [
                                AppColors.primaryBlue,
                                AppColors.accentPurple,
                              ],
                            )
                          : null,
                      color: isMe ? null : Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: isMe
                            ? const Radius.circular(20)
                            : const Radius.circular(4),
                        bottomRight: isMe
                            ? const Radius.circular(4)
                            : const Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isMe
                              ? AppColors.primaryBlue.withOpacity(0.3)
                              : Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: isMe
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        if (imageUrl != null && imageUrl!.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              imageUrl!,
                              width: 200,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Text('Image Failed'),
                            ),
                          ),
                        if (text.isNotEmpty) ...[
                          if (imageUrl != null) const SizedBox(height: 8),
                          Text(
                            text,
                            style: TextStyle(
                              fontSize: 15,
                              color: isMe
                                  ? Colors.white
                                  : AppColors.textPrimary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupInfoSheet extends ConsumerStatefulWidget {
  final String groupId;
  final String groupName;
  final String groupEmoji;

  const _GroupInfoSheet({
    required this.groupId,
    required this.groupName,
    required this.groupEmoji,
  });

  @override
  ConsumerState<_GroupInfoSheet> createState() => _GroupInfoSheetState();
}

class _GroupInfoSheetState extends ConsumerState<_GroupInfoSheet> {
  final _firestore = FirebaseFirestore.instance;

  Future<void> _deleteGroup() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Group?'),
        content: const Text(
          'Are you sure you want to delete this group? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.errorRed),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(familyHubServiceProvider).deleteChatGroup(widget.groupId);
      if (mounted) {
        Navigator.pop(context); // Close sheet
        Navigator.pop(context); // Close chat
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(widget.groupEmoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.groupName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                onPressed: _deleteGroup,
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppColors.errorRed,
                ),
                tooltip: 'Delete Group',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Members:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    builder: (context) {
                      return StreamBuilder<DocumentSnapshot>(
                        stream: _firestore
                            .collection('users')
                            .doc(ref.read(effectiveUidProvider))
                            .collection('chatGroups')
                            .doc(widget.groupId)
                            .snapshots(),
                        builder: (context, snap) {
                          if (!snap.hasData) return const SizedBox();
                          final data =
                              snap.data!.data() as Map<String, dynamic>? ?? {};
                          final currentMembers = List<String>.from(
                            data['members'] ?? [],
                          );
                          return _AddGroupMemberSheet(
                            groupId: widget.groupId,
                            currentMembers: currentMembers,
                          );
                        },
                      );
                    },
                  );
                },
                icon: const Icon(Icons.person_add_alt_1, size: 20),
                label: const Text('Add Member'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: _firestore
                  .collection('users')
                  .doc(ref.watch(effectiveUidProvider))
                  .collection('chatGroups')
                  .doc(widget.groupId)
                  .snapshots(),
              builder: (context, groupSnap) {
                if (groupSnap.connectionState == ConnectionState.waiting)
                  return const Center(child: CircularProgressIndicator());
                if (!groupSnap.hasData || groupSnap.data?.data() == null)
                  return const Text('Group not found');

                final data = groupSnap.data!.data() as Map<String, dynamic>;
                final members = List<String>.from(data['members'] ?? []);

                return ListView.builder(
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    final memberId = members[index];
                    return FutureBuilder<DocumentSnapshot>(
                      future: _firestore
                          .collection('users')
                          .doc(memberId)
                          .get(),
                      builder: (context, userSnap) {
                        if (!userSnap.hasData) return const SizedBox();
                        final userData =
                            userSnap.data!.data() as Map<String, dynamic>? ??
                            {};
                        final name = userData['firstName'] ?? 'User';
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primaryBlue.withOpacity(
                              0.2,
                            ),
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : 'U',
                              style: const TextStyle(
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ),
                          title: Text(
                            name,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AddGroupMemberSheet extends ConsumerStatefulWidget {
  final String groupId;
  final List<String> currentMembers;

  const _AddGroupMemberSheet({
    required this.groupId,
    required this.currentMembers,
  });

  @override
  ConsumerState<_AddGroupMemberSheet> createState() =>
      _AddGroupMemberSheetState();
}

class _AddGroupMemberSheetState extends ConsumerState<_AddGroupMemberSheet> {
  final Set<String> _selectedMembers = {};
  bool _loading = false;

  Future<void> _addMembers() async {
    if (_selectedMembers.isEmpty) return;
    setState(() => _loading = true);
    await ref
        .read(familyHubServiceProvider)
        .addMembersToGroup(widget.groupId, _selectedMembers.toList());
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Add Members',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ref
              .watch(familyMembersProvider)
              .when(
                data: (members) {
                  final availableMembers = members
                      .where((m) => !widget.currentMembers.contains(m['uid']))
                      .toList();

                  if (availableMembers.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        'No new members to add.',
                        style: TextStyle(color: AppColors.textHint),
                      ),
                    );
                  }

                  return ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.4,
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: availableMembers.length,
                      itemBuilder: (context, index) {
                        final memberData = availableMembers[index];
                        final memberId = memberData['uid'] as String;
                        final memberName =
                            memberData['name'] ??
                            memberData['firstName'] ??
                            'User';

                        return CheckboxListTile(
                          title: Text(memberName),
                          value: _selectedMembers.contains(memberId),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                _selectedMembers.add(memberId);
                              } else {
                                _selectedMembers.remove(memberId);
                              }
                            });
                          },
                          activeColor: AppColors.primaryBlue,
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        );
                      },
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Text(
                  'Error: $e',
                  style: const TextStyle(color: AppColors.errorRed),
                ),
              ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryBlue, AppColors.accentPurple],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _loading || _selectedMembers.isEmpty
                    ? null
                    : _addMembers,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Add to Group',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
