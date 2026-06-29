import 'package:go_router/go_router.dart';

import '../providers/admin_auth_provider.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/admin_login_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/home_screen.dart';
import '../screens/employee/employee_login_screen.dart';
import '../screens/success_screen.dart';
import '../screens/visitor/visitor_mode_screen.dart';
import '../screens/visitor/visitor_registration_screen.dart';
import '../screens/visitor/visitor_checkout_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    refreshListenable: AdminAuthProvider.instance,
    redirect: (context, state) {
      final isAdminRoute = state.fullPath == '/admin';
      final isAuthenticated = AdminAuthProvider.instance.isAuthenticated;
      if (isAdminRoute && !isAuthenticated) return '/admin-login';
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/employee',
        builder: (context, state) => const EmployeeLoginScreen(),
      ),
      GoRoute(
        path: '/visitor',
        builder: (context, state) => const VisitorModeScreen(),
      ),
      GoRoute(
        path: '/visitor/checkin',
        builder: (context, state) => const VisitorCheckInScreen(),
      ),
      GoRoute(
        path: '/visitor/checkout',
        builder: (context, state) => const VisitorCheckOutScreen(),
      ),
      GoRoute(
        path: '/success',
        builder: (context, state) => SuccessScreen(
          message: state.extra as String? ?? 'Success!',
        ),
      ),
      GoRoute(
        path: '/admin-login',
        builder: (context, state) => const AdminLoginScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
    ],
  );
}
