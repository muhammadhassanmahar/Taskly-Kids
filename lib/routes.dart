import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/role_screen.dart';
import 'screens/parent_dashboard.dart';
import 'screens/child_dashboard.dart';

final Map<String, WidgetBuilder> routes = {
  // ================= SPLASH =================
  '/splash': (_) => const SplashScreen(),

  // ================= ROLE =================
  '/role': (_) => const RoleScreen(),

  // ================= AUTH =================
  '/login': (_) => const LoginScreen(),
  '/signup': (_) => const SignupScreen(),

  // ================= PARENT DASHBOARD =================
  '/parent': (context) {
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is Map<String, dynamic> &&
        args['parentEmail'] is String &&
        (args['parentEmail'] as String).isNotEmpty) {
      return ParentDashboard(
        parentEmail: args['parentEmail'],
      );
    }

    // ❌ agar email missing ho → login
    return const LoginScreen();
  },

  // ================= CHILD DASHBOARD =================
  '/child': (context) {
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is Map<String, dynamic> &&
        args['childEmail'] is String &&
        (args['childEmail'] as String).isNotEmpty) {
      return ChildDashboard(
        childEmail: args['childEmail'],
      );
    }

    // ❌ agar email missing ho → login
    return const LoginScreen();
  },
};
