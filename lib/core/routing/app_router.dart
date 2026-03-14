import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/main_shell.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/family_hub/presentation/family_hub_screen.dart';

import '../../features/auth/presentation/signup_screen.dart';
import '../../features/onboarding/presentation/setup_quiz_screen.dart';
import '../../features/onboarding/presentation/invite_family_screen.dart';
import '../../features/onboarding/presentation/success_screen.dart';

import '../../features/maintenance/presentation/screens/maintenance_screen.dart';

import '../../features/vault/presentation/screens/vault_screen.dart';
import '../../features/ai_assistant/presentation/screens/ai_assistant_screen.dart';
import '../../features/appliances/presentation/screens/appliance_screen.dart';
import '../../features/vehicles/presentation/screens/vehicle_screen.dart';
import '../../features/subscriptions/presentation/screens/subscription_screen.dart';
import '../../features/utilities/presentation/screens/utility_screen.dart';
import '../../features/emergency/presentation/screens/emergency_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/settings/presentation/screens/profile_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/ai-assistant',
      builder: (context, state) => const AiAssistantScreen(),
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),
    GoRoute(
      path: '/setup-quiz',
      builder: (context, state) => const SetupQuizScreen(),
    ),
    GoRoute(
      path: '/invite-family',
      builder: (context, state) => const InviteFamilyScreen(),
    ),
    GoRoute(
      path: '/setup-success',
      builder: (context, state) => const SuccessScreen(),
    ),
    GoRoute(
      path: '/appliances',
      builder: (context, state) => const ApplianceScreen(),
    ),
    GoRoute(
      path: '/vehicles',
      builder: (context, state) => const VehicleScreen(),
    ),
    GoRoute(
      path: '/subscriptions',
      builder: (context, state) => const SubscriptionScreen(),
    ),
    GoRoute(
      path: '/utilities',
      builder: (context, state) => const UtilityScreen(),
    ),
    GoRoute(
      path: '/emergency',
      builder: (context, state) => const EmergencyScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/family-hub',
              builder: (context, state) => const FamilyHubScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/maintenance',
              builder: (context, state) => const MaintenanceScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/vault',
              builder: (context, state) => const VaultScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
