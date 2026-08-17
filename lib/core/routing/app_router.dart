import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/analytics/analytics_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/budgets/budgets_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/shell/main_shell.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/transactions/transactions_screen.dart';
import '../../view_models/app_settings_view_model.dart';

class AppRouter {
  AppRouter(this.settings) {
    router = GoRouter(
      initialLocation: '/splash',
      redirect: _redirect,
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) => MainShell(
            navigationShell: navigationShell,
          ),
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
                  path: '/transactions',
                  builder: (context, state) => const TransactionsScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/budgets',
                  builder: (context, state) => const BudgetsScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/analytics',
                  builder: (context, state) => const AnalyticsScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/profile',
                  builder: (context, state) => const ProfileScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  final AppSettingsViewModel settings;
  late final GoRouter router;

  String? _redirect(BuildContext context, GoRouterState state) {
    final path = state.uri.path;
    if (!settings.isInitialized || !settings.splashFinished) {
      return path == '/splash' ? null : '/splash';
    }
    if (!settings.onboardingCompleted) {
      return path == '/onboarding' ? null : '/onboarding';
    }
    if (!settings.isSignedIn) {
      if (path == '/login' || path == '/register') return null;
      return '/login';
    }
    if (path == '/splash' ||
        path == '/onboarding' ||
        path == '/login' ||
        path == '/register') {
      return '/home';
    }
    return null;
  }
}
