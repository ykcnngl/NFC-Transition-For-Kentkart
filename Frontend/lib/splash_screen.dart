import 'package:flutter/material.dart';
import 'dart:async';
import 'main.dart'; // LoginScreen'e gitmek için main.dart'ı çağırıyoruz

class FullScreenSplash extends StatefulWidget {
  const FullScreenSplash({super.key});

  @override
  State<FullScreenSplash> createState() => _FullScreenSplashState();
}

class _FullScreenSplashState extends State<FullScreenSplash> {
  @override
  void initState() {
    super.initState();
    // 2.5 saniye boyunca bu tam ekran resmi göster, sonra Login'e git
    Timer(const Duration(milliseconds: 2500), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold ile tüm ekranı kaplıyoruz
    return Scaffold(
      backgroundColor: const Color(0xFF070B14), // Resmin arka planıyla aynı renk
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Image.asset(
          'assets/aa.jpg',
          fit: BoxFit.cover, // İŞTE SİHİR BURADA: Resmi tüm ekrana sündürmeden yayar
        ),
      ),
    );
  }
}