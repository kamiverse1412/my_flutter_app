// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/services.dart';
// import 'package:auto_route/auto_route.dart';

// import 'auth_service.dart';
// import 'router/app_router.dart';

// // final _appRouter = AppRouter();

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp.router(
//       // routerConfig: _appRouter.config(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }

// import 'package:astra_mobile/details.dart';
// import 'package:astra_mobile/splash.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:firebase_core/firebase_core.dart';

// import 'auth_service.dart';
// import 'package:astra_mobile/lang.dart';
// import 'package:astra_mobile/login.dart';
// import 'package:astra_mobile/register.dart';
// import 'package:astra_mobile/profile.dart';
// import 'package:astra_mobile/face_id_screen.dart';
// import 'package:astra_mobile/shop.dart';
// import 'package:astra_mobile/catalog.dart';
// import 'package:astra_mobile/cart.dart';
// import 'package:astra_mobile/liked.dart';
// import 'package:astra_mobile/personal.dart';
// import 'package:astra_mobile/account.dart';
// import 'package:astra_mobile/selected.dart';
// import 'package:astra_mobile/filterpage.dart';
// import 'package:astra_mobile/results.dart';
// import 'package:astra_mobile/router/app_router.dart';

// final _appRouter = AppRouter();

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp.router(
//       routerConfig: _appRouter.config(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }

// class SplashCheck extends StatefulWidget {
//   const SplashCheck({super.key});

//   @override
//   State<SplashCheck> createState() => _SplashCheckState();
// }

// class _SplashCheckState extends State<SplashCheck> {
//   @override
//   void initState() {
//     super.initState();
//     _checkLogin();
//   }

//   void _checkLogin() async {
//     final creds = await AuthService.getSavedCredentials();
//     if (creds != null) {
//       _appRouter.replace(
//         FaceIdPage(phone: creds['phone'], password: creds['password']),
//       );
//     } else {
//       _appRouter.replace(LoginPage() as FaceIdPage);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(body: Center(child: CircularProgressIndicator()));
//   }
// }

import 'package:astra_mobile/details.dart';
import 'package:astra_mobile/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'face_id_screen.dart';

import 'auth_service.dart';
import 'package:astra_mobile/lang.dart';
import 'package:astra_mobile/login.dart';
import 'package:astra_mobile/register.dart';
import 'package:astra_mobile/profile.dart';
import 'package:astra_mobile/face_id_screen.dart';
import 'package:astra_mobile/shop.dart';
import 'package:astra_mobile/catalog.dart';
import 'package:astra_mobile/cart.dart';
import 'package:astra_mobile/liked.dart';
import 'package:astra_mobile/personal.dart';
import 'package:astra_mobile/account.dart';
import 'package:astra_mobile/selected.dart';
import 'package:astra_mobile/filterpage.dart';
import 'package:astra_mobile/results.dart';
import 'package:astra_mobile/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  get product => null;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashPage(),
      routes: {
        "/login": (context) => LoginPage(),
        "/SignUp": (context) => RegisterPage(),
        "/register": (context) => RegisterPage(),
        '/faceid': (context) => FaceIdPage(),
        '/shop': (context) => ShopPage(),
        '/catalog': (context) => CatalogPage(),
        '/cart': (context) => CartPage(),
        '/liked': (context) => LikePage(),
        '/profile': (context) => CheckPage(),
        '/personal': (context) => PersonalPage(),
        '/check': (context) => CheckPage(),
        '/account': (context) => AccountPage(),
        '/filter': (context) => FilterPage(),
        '/results': (context) => ResultsPage(),
        '/lang': (context) => LanguagePage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/selected') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => SelectedPage(
              categoryId: args['id'],
              categoryName: args['name'],
            ),
          );
        }
        return null;
      },
    );
  }
}

class SplashCheck extends StatefulWidget {
  const SplashCheck({super.key});

  @override
  State<SplashCheck> createState() => _SplashCheckState();
}

class _SplashCheckState extends State<SplashCheck> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  void _checkLogin() async {
    final creds = await AuthService.getSavedCredentials();
    if (creds != null) {
      Navigator.pushReplacementNamed(
        context,
        '/faceid',
        arguments: {'phone': creds['phone'], 'password': creds['password']},
      );
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
