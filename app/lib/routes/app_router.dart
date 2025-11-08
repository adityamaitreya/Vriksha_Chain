import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/batches_screen.dart';
import '../screens/batch_detail_screen.dart';
import '../screens/analytics_screen.dart';
import '../screens/quality_metrics_screen.dart';
import '../screens/blockchain_test_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isAuthenticated = authProvider.isAuthenticated;
      final isLoading = authProvider.isLoading;

      // Don't redirect while loading
      if (isLoading) return null;

      // Protected routes
      final isLoginRoute = state.matchedLocation == '/login';
      final isSplashRoute = state.matchedLocation == '/splash';

      if (isSplashRoute) {
        return null; // Allow splash screen
      }

      // Redirect to login if not authenticated
      if (!isAuthenticated && !isLoginRoute) {
        return '/login';
      }

      // Redirect to dashboard if authenticated and on login
      if (isAuthenticated && isLoginRoute) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/batches',
        builder: (context, state) => const BatchesScreen(),
      ),
      GoRoute(
        path: '/batch/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return BatchDetailScreen(batchId: id);
        },
      ),
      GoRoute(
        path: '/analytics',
        builder: (context, state) => const AnalyticsScreen(),
      ),
      GoRoute(
        path: '/quality',
        builder: (context, state) => const QualityMetricsScreen(),
      ),
      GoRoute(
        path: '/blockchain-test',
        builder: (context, state) => const BlockchainTestScreen(),
      ),
    ],
  );
}

