// import 'package:auto_route/auto_route.dart';
// import 'package:flutter/material.dart';

// import '../auth_service.dart';
// import '../router/app_router.dart';

// class SplashPage extends StatefulWidget {
//   const SplashPage({super.key});

//   @override
//   State<SplashPage> createState() => _SplashPageState();
// }

// class _SplashPageState extends State<SplashPage> {
//   @override
//   void initState() {
//     super.initState();
//     _checkLogin();
//   }

//   void _checkLogin() async {
//     final creds = await AuthService.getSavedCredentials();

//     if (!mounted) return;

//     if (creds != null) {
//       context.router.replace(
//         FaceIdRoute(phone: creds['phone'], password: creds['password']),
//       );
//     } else {
//       context.router.replace(const LoginRoute());
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(body: Center(child: CircularProgressIndicator()));
//   }
// }

import 'package:astra_mobile/lang.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:auto_route/annotations.dart';

@RoutePage()
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LanguagePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Image.asset('assets/images/Logo.png', width: 220)),
    );
  }
}
