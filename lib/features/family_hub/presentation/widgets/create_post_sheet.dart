import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../providers/family_hub_providers.dart';
import '../../../../core/providers/auth_providers.dart';

class CreatePostSheet extends ConsumerStatefulWidget {
  final String? initialFeeling;
  const CreatePostSheet({super.key, this.initialFeeling});

  @override
  ConsumerState<CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends ConsumerState<CreatePostSheet> {
  final _contentController = TextEditingController();
  File? _selectedImage;
  String? _selectedFeeling;
  bool _loading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _selectedFeeling = widget.initialFeeling;
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  Future<void> _submit() async {
    final text = _contentController.text.trim();
    if (text.isEmpty && _selectedImage == null) return;
    setState(() => _loading = true);

    try {
      String? imageUrl;
      final service = ref.read(familyHubServiceProvider);

      if (_selectedImage != null) {
        final path = 'family_hub/posts/${const Uuid().v4()}.jpg';
        imageUrl = await service.uploadImage(_selectedImage!, path);
      }

      await service.createPost(
        content: text,
        imageUrl: imageUrl,
        feeling: _selectedFeeling,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      // Handle error gracefully if needed
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to create post: $e')));
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            // Header bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, size: 28),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Create Post',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _loading ? null : _submit,
                    child: Text(
                      'POST',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color:
                            _contentController.text.isNotEmpty ||
                                _selectedImage != null
                            ? AppColors.primaryBlue
                            : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User info row
                    ref
                        .watch(userProfileProvider)
                        .when(
                          data: (profile) => Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundImage: profile?['photoUrl'] != null
                                    ? NetworkImage(profile!['photoUrl'])
                                    : null,
                                backgroundColor: AppColors.primaryBlue,
                                child: profile?['photoUrl'] == null
                                    ? Text(
                                        (profile?['firstName'] ?? 'U')[0],
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text:
                                              '${profile?['firstName'] ?? 'User'} ${profile?['lastName'] ?? ''}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        if (_selectedFeeling != null) ...[
                                          const TextSpan(
                                            text: ' is feeling ',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.black54,
                                            ),
                                          ),
                                          TextSpan(
                                            text: _selectedFeeling,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.public, size: 12),
                                        SizedBox(width: 4),
                                        Text(
                                          'Public',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        Icon(Icons.arrow_drop_down, size: 16),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _contentController,
                      maxLines: null,
                      autofocus: true,
                      onChanged: (val) => setState(() {}),
                      style: const TextStyle(fontSize: 18),
                      decoration: const InputDecoration(
                        hintText: "What's on your mind?",
                        border: InputBorder.none,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_selectedImage != null)
                      Stack(
                        alignment: Alignment.topRight,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              _selectedImage!,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircleAvatar(
                              backgroundColor: Colors.black54,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
                                onPressed: () =>
                                    setState(() => _selectedImage = null),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            // Bottom Action Bar
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                children: [
                  const Text(
                    'Add to your post',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const Spacer(),

                  IconButton(
                    onPressed: _pickImage,
                    icon: const Icon(
                      Icons.photo_library,
                      color: AppColors.successGreen,
                    ),
                  ),
                  IconButton(
                    onPressed: _showFeelingPicker,
                    icon: const Icon(
                      Icons.emoji_emotions_outlined,
                      color: Colors.orange,
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

  void _showFeelingPicker() {
    final feelings = [
      'Happy 😊',
      'Blessed 😇',
      'Loved 😍',
      'Sad 😢',
      'Angry 😠',
      'Excited 🤩',
      'Crazy 🤪',
      'Grateful 🙏',
      'Tired 😴',
      'Confused 😕',
      'Cool 😎',
      'Sleepy 🥱',
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'How are you feeling?',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: feelings.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(feelings[index]),
                    onTap: () {
                      setState(() => _selectedFeeling = feelings[index]);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
