import 'package:flutter/material.dart';
import 'package:foodtogo_shippers/screens/splash_screen.dart';
import 'package:foodtogo_shippers/screens/user_register_screen.dart';
import 'package:foodtogo_shippers/settings/kTheme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FoodToGo - Customers',
      theme: KTheme.kTheme,
      home: const Scaffold(
        body: SplashScreen(),
        // body: UserRegisterScreen(),
      ),
    );
  }
}
