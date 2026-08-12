import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth_service.dart';
import '../models/quiz_model.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/home_screen.dart';
import '../screens/mcq_screen.dart';
import '../screens/fill_screen.dart';
import '../screens/generated_screen.dart';
import '../screens/quiz_screen.dart';
import '../screens/fill_quiz_screen.dart';
import '../screens/result_screen.dart';

// Makes GoRouter re-evaluate redirect whenever Firebase auth state changes
class _GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<User?> _sub;

  _GoRouterRefreshStream() {
    _sub = FirebaseAuth.instance.authStateChanges().listen((_) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

class AppRouter {
  static final _refreshListenable = _GoRouterRefreshStream();

  static GoRouter router = GoRouter(
    initialLocation: '/login',
    refreshListenable: _refreshListenable,
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/mcq',
        builder: (context, state) => const MCQScreen(),
      ),
      GoRoute(
        path: '/fill',
        builder: (context, state) => const FillScreen(),
      ),
      GoRoute(
        path: '/generated',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          return GeneratedScreen(data: data);
        },
      ),
      GoRoute(
        path: '/quiz',
        builder: (context, state) {
          final questions = state.extra as List<QuizQuestion>;
          return QuizScreen(questions: questions);
        },
      ),
      GoRoute(
        path: '/fill-quiz',
        builder: (context, state) {
          final questions = state.extra as List<QuizQuestion>;
          return FillQuizScreen(questions: questions);
        },
      ),
      GoRoute(
        path: '/result',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          return ResultScreen(data: data);
        },
      ),
    ],
    redirect: (context, state) {
      final isLoggedIn = FirebaseAuth.instance.currentUser != null;
      final loc = state.matchedLocation;
      final isAuthRoute = loc == '/login' || loc == '/signup' || loc == '/forgot-password';

      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) return '/home';
      return null;
    },
  );
}
