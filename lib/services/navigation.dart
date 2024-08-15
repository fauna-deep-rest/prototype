import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:fauna_prototype/views/authPage.dart';
import 'package:fauna_prototype/views/homePage.dart';
import 'package:fauna_prototype/views/procPage.dart';
import 'package:fauna_prototype/views/medPage.dart';

final routerConfig = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (context, state) => const AuthPage(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => HomePage(),
    ),
    GoRoute(
      path: '/meditation',
      builder: (context, state) => MedPage(),
    ),
    GoRoute(
      path: '/procrastination',
      builder: (context, state) => ProcPage(),
    ),
  ],
);

class NavigationService {
  late final GoRouter _router;

  NavigationService() {
    _router = routerConfig;
  }

  void goHome() {
    _router.go('/home');
  }

  void goMeditation() {
    _router.go('/meditation');
  }

  void goProcrastination() {
    _router.go('/procrastination');
  }

  void pop(BuildContext context) {
    _router.pop(context);
  }
}