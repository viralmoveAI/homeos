import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/animated_gradient_background.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/emergency_providers.dart';
import '../../domain/models/emergency_contact.dart';

class EmergencyScreen extends ConsumerWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactsAsync = ref.watch(emergencyContactsProvider);

    return AnimatedGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Emergency Contacts', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: contactsAsync.when(
          data: (contacts) => contacts.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: contacts.length,
                  itemBuilder: (context, index) => _buildContactCard(context, contacts[index]),
                ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          backgroundColor: Colors.redAccent,
          child: const Icon(Icons.add_rounded, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.emergency_rounded, size: 80, color: AppColors.textHint.withOpacity(0.3)),
          const SizedBox(height: 20),
          Text(
            'No emergency contacts yet',
            style: TextStyle(color: AppColors.textSecondary.withOpacity(0.7), fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(BuildContext context, EmergencyContact contact) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: ListTile(
            contentPadding: const EdgeInsets.all(20),
            leading: const CircleAvatar(
              backgroundColor: Colors.redAccent,
              child: Icon(Icons.person_rounded, color: Colors.white),
            ),
            title: Text(contact.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(contact.relation, style: TextStyle(color: AppColors.textSecondary.withOpacity(0.7))),
            trailing: IconButton(
              icon: const Icon(Icons.phone_rounded, color: Colors.redAccent),
              onPressed: () {}, // Implement call logic
            ),
          ),
        ),
      ),
    );
  }
}
