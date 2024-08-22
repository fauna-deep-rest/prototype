import 'package:flutter/material.dart';
import 'package:fauna_prototype/services/navigation.dart';
import 'package:provider/provider.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<NavigationService>(
          create: (_) => NavigationService(),
        ),
      ],
      child: MaterialApp.router(
        theme: ThemeData.light().copyWith(
          hintColor: Colors.black,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 0, 0, 0),
          ),
        ),
        routerConfig: routerConfig,
        restorationScopeId: 'app',
      ),
    );
  }
}
