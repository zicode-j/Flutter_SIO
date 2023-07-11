import 'package:flutter/material.dart';
import 'package:flutter_sio/modules/home/home_screen.dart';

class SplashScreen extends StatelessWidget {
  static const routeName = '/';

  const SplashScreen({super.key});

  void _navigateNext(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 3));

    // Navigasi
    if (context.mounted) {
      Navigator.of(context).popAndPushNamed(HomeScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    _navigateNext(context);

    return const Scaffold(
      backgroundColor: Colors.green,
      body: Center(
        child: Icon(
          Icons.shopify,
          size: 100,
          color: Colors.white,
        ),
      ),
    );
  }
}
