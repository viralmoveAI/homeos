import 'package:flutter/material.dart';
import '../../../shared/widgets/animated_gradient_background.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/user_avatar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
                child: _buildHeader(),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Today\'s Highlights'),
                          const SizedBox(height: 16),
                          _buildHighlightsGrid(),
                          const SizedBox(height: 32),
                          _buildSectionTitle('Family Feed & Memories'),
                          const SizedBox(height: 16),
                          _buildFeedSection(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good Morning,',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            Row(
              children: [
                Text(
                  'Sarah!', // Placeholder user name
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                const Text('👋', style: TextStyle(fontSize: 24)),
              ],
            ),
          ],
        ),
        const UserAvatar(name: 'Sarah', radius: 24), // User Avatar Placeholder
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildHighlightsGrid() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Column(
            children: [
              _buildHomeHealthScore(),
              const SizedBox(height: 16),
              _buildAlertCard(
                icon: Icons.ac_unit,
                iconColor: Colors.blue,
                bgColor: Colors.blue[50]!,
                title: 'AC Service:\n3 days',
              ),
              const SizedBox(height: 12),
              _buildAlertCard(
                icon: Icons.sensors,
                iconColor: Colors.orange,
                bgColor: Colors.orange[50]!,
                title: 'Smoke Detector:\nCheck Battery',
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 1,
          child: Column(
            children: [
              _buildDinnerPoll(),
              const SizedBox(height: 16),
              _buildQuickReminders(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHomeHealthScore() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          const Text('Home Health Score', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          // Placeholder for circular progress
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: CircularProgressIndicator(
                  value: 0.82,
                  strokeWidth: 10,
                  backgroundColor: Colors.grey[200],
                  color: AppColors.successGreen,
                ),
              ),
              const Text(
                '82',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.successGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          RichText(
            text: const TextSpan(
              text: 'Overall: ',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              children: [
                TextSpan(
                  text: 'Good',
                  style: TextStyle(color: AppColors.successGreen, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDinnerPoll() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryMint.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tonight\'s\nWhat\'s for dinner\ntonight?',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          _buildPollOption('Pizza 🍕', true),
          const SizedBox(height: 8),
          _buildPollOption('Spaghetti 🍝', false),
          const SizedBox(height: 8),
          _buildPollOption('Chicken & Rice 🍗', false),
        ],
      ),
    );
  }

  Widget _buildPollOption(String text, bool isLeading) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isLeading ? Colors.white : Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          if (isLeading) 
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.warningOrange,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickReminders() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
           BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quick Reminders', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildReminderItem('Groceries: 3 items'),
          _buildReminderItem('Electricity Bill due in 5 days'),
          _buildReminderItem('Car Service: Next Month'),
        ],
      ),
    );
  }

  Widget _buildReminderItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: AppColors.primaryBlue, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary))),
        ],
      ),
    );
  }

  Widget _buildAlertCard({required IconData icon, required Color iconColor, required Color bgColor, required String title}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
           BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
           Container(
             padding: const EdgeInsets.all(8),
             decoration: BoxDecoration(
               color: bgColor,
               borderRadius: BorderRadius.circular(8),
             ),
             child: Icon(icon, color: iconColor, size: 20),
           ),
           const SizedBox(width: 12),
           Expanded(
             child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
           ),
        ],
      ),
    );
  }

  Widget _buildFeedSection() {
    return Container(
      height: 160,
      child: ListView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        children: [
          _buildMemoryCard(),
          const SizedBox(width: 16),
          _buildUpdateCard(),
        ],
      ),
    );
  }

  Widget _buildMemoryCard() {
    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(24),
        image: const DecorationImage(
           image: NetworkImage('https://picsum.photos/400/200?random=1'), // Placeholder
           fit: BoxFit.cover,
        ),
        boxShadow: [
           BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.7),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('3 Years Ago Today', style: TextStyle(color: Colors.white, fontSize: 10)),
            ),
            const Text('Family trip memories', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdateCard() {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
           BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Row(
             children: [
               const UserAvatar(name: 'Dad', radius: 12),
               const SizedBox(width: 8),
               const Text('Dad', style: TextStyle(fontWeight: FontWeight.bold)),
             ],
           ),
           const SizedBox(height: 8),
           ClipRRect(
             borderRadius: BorderRadius.circular(12),
             child: Image.network(
               'https://picsum.photos/400/200?random=2',
               height: 60,
               width: double.infinity,
               fit: BoxFit.cover,
             ),
           ),
           const SizedBox(height: 8),
           const Text('AC service scheduled for tomorrow!', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
           const Spacer(),
           Row(
             children: [
               const Icon(Icons.favorite_border, size: 16, color: AppColors.textHint),
               const SizedBox(width: 12),
               const Icon(Icons.chat_bubble_outline, size: 16, color: AppColors.textHint),
             ],
           ),
        ],
      ),
    );
  }
}
