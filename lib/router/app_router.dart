// // lib/router/app_router.dart

// import 'package:astra_mobile/main_screen.dart';
// import 'package:astra_mobile/splash.dart';
// import 'package:auto_route/auto_route.dart';
// import 'package:flutter/material.dart';

// import 'package:astra_mobile/login.dart';
// import 'package:astra_mobile/register.dart';
// import 'package:astra_mobile/face_id_screen.dart';
// import 'package:astra_mobile/shop.dart';
// import 'package:astra_mobile/catalog.dart';
// import 'package:astra_mobile/cart.dart';
// import 'package:astra_mobile/liked.dart';
// import 'package:astra_mobile/profile.dart';
// import 'package:astra_mobile/personal.dart';
// import 'package:astra_mobile/account.dart';
// import 'package:astra_mobile/selected.dart';
// import 'package:astra_mobile/details.dart';
// import 'package:astra_mobile/filterpage.dart';
// import 'package:astra_mobile/results.dart';
// import 'package:astra_mobile/lang.dart';
// import 'package:astra_mobile/main_screen.dart'; // your bottom navigation wrapper

// part 'app_router.gr.dart';

// @AutoRouterConfig(replaceInRouteName: 'Page,Route')
// class AppRouter extends _$AppRouter {
//   @override
//   final List<AutoRoute> routes = [
//     // 👉 bottom nav wrapper
//     AutoRoute(
//       page: MainTabScreen.page,
//       initial: true,
//       path: '/',
//       children: [
//         AutoRoute(page: ShopRoute.page, path: 'shop'),
//         AutoRoute(page: CatalogRoute.page, path: 'catalog'),
//         AutoRoute(page: CartRoute.page, path: 'cart'),
//         AutoRoute(page: LikeRoute.page, path: 'liked'),
//         AutoRoute(page: CheckRoute.page, path: 'profile'),
//       ],
//     ),

//     // 👉 non-tab screens (opened via push, etc)
//     AutoRoute(page: FaceIdRoute.page),
//     AutoRoute(page: RegisterRoute.page),
//     AutoRoute(page: LoginRoute.page),
//     AutoRoute(page: DetailsRoute.page),
//     AutoRoute(page: SelectedRoute.page),
//     AutoRoute(page: PersonalRoute.page),
//     AutoRoute(page: AccountRoute.page),
//     AutoRoute(page: ResultsRoute.page),
//     AutoRoute(page: LanguageRoute.page),
//     AutoRoute(page: FilterRoute.page),
//   ];
// }

// class _$AppRouter {}

import 'package:auto_route/auto_route.dart';
import 'package:astra_mobile/shop.dart';
import 'package:astra_mobile/catalog.dart';
import 'package:astra_mobile/cart.dart';
import 'package:astra_mobile/liked.dart';
import 'package:astra_mobile/profile.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: CatalogPage.page),
    AutoRoute(page: CartPage.page),
    AutoRoute(page: LikePage.page),
    AutoRoute(page: CheckPage.page),
    AutoRoute(page: ShopPage.page),
  ];
}

// //   void replace(FaceIdPage faceIdPage) {}

// //   config() {}
// // }

// // class $AppRouter {}

// // // import 'package:auto_route/auto_route.dart';
// // // import 'package:astra_mobile/login.dart';
// // // import 'package:astra_mobile/register.dart';
// // // import 'package:astra_mobile/splash.dart';
// // // import 'package:astra_mobile/face_id_screen.dart';
// // // import 'package:astra_mobile/shop.dart';
// // // import 'package:astra_mobile/catalog.dart';
// // // import 'package:astra_mobile/cart.dart';
// // // import 'package:astra_mobile/liked.dart';
// // // import 'package:astra_mobile/profile.dart';
// // // import 'package:astra_mobile/personal.dart';
// // // import 'package:astra_mobile/account.dart';
// // // import 'package:astra_mobile/selected.dart';
// // // import 'package:astra_mobile/details.dart';
// // // import 'package:astra_mobile/filterpage.dart';
// // // import 'package:astra_mobile/results.dart';
// // // import 'package:astra_mobile/lang.dart';
// // // import 'package:auto_route/annotations.dart';

// // // part 'app_router.gr.dart';

// // // @AutoRouterConfig(replaceInRouteName: 'Page,Route')
// // // class AppRouter extends $AppRouter {
// // //   @override
// // //   final List<AutoRoute> routes = [
// // //     AutoRoute(page: SplashRoute.page, initial: true),
// // //     AutoRoute(page: LoginRoute.page),
// // //     AutoRoute(page: RegisterRoute.page),
// // //     AutoRoute(page: FaceIdRoute.page),
// // //     AutoRoute(page: ShopRoute.page),
// // //     AutoRoute(page: CatalogRoute.page),
// // //     AutoRoute(page: CartRoute.page),
// // //     AutoRoute(page: LikeRoute.page),
// // //     AutoRoute(page: CheckRoute.page),
// // //     AutoRoute(page: PersonalRoute.page),
// // //     AutoRoute(page: AccountRoute.page),
// // //     AutoRoute(page: SelectedRoute.page),
// // //     AutoRoute(page: DetailsRoute.page),
// // //     // AutoRoute(page: FilterPageRoute.page),
// // //     AutoRoute(page: ResultsRoute.page),
// // //     AutoRoute(page: LanguageRoute.page),
// // //   ];

// // //   void replace(faceIdRoute) {}

// // //   config() {}
// // // }

// // // import 'package:auto_route/auto_route.dart';
// // // import 'package:flutter/material.dart';

// // // import 'package:astra_mobile/splash.dart';
// // // import 'package:astra_mobile/login.dart';
// // // import 'package:astra_mobile/register.dart';
// // // import 'package:astra_mobile/shop.dart';
// // // import 'package:astra_mobile/filterpage.dart';
// // // import 'package:astra_mobile/lang.dart';
// // // import 'package:astra_mobile/personal.dart';
// // // import 'package:astra_mobile/profile.dart';
// // // import 'package:astra_mobile/liked.dart';
// // // import 'package:astra_mobile/catalog.dart';
// // // import 'package:astra_mobile/selected.dart';
// // // import 'package:astra_mobile/results.dart';
// // // import 'package:astra_mobile/account.dart';
// // // import 'package:astra_mobile/details.dart';
// // // import 'package:astra_mobile/face_id_screen.dart';

// // // part 'app_router.gr.dart'; // AutoRoute will generate this

// // // @AutoRouterConfig(replaceInRouteName: 'Screen,Page,Route')
// // // class AppRouter extends _$AppRouter {
// // //   @override
// // //   List<AutoRoute> get routes => [
// // //     AutoRoute(page: SplashRoute.page, initial: true),
// // //     AutoRoute(page: LoginRoute.page),
// // //     AutoRoute(page: RegisterRoute.page),
// // //     AutoRoute(page: ShopRoute.page),
// // //     AutoRoute(page: FilterPageRoute.page),
// // //     AutoRoute(page: LanguageRoute.page),
// // //     AutoRoute(page: PersonalRoute.page),
// // //     AutoRoute(page: CheckRoute.page),
// // //     AutoRoute(page: LikeRoute.page),
// // //     AutoRoute(page: CatalogRoute.page),
// // //     AutoRoute(page: SelectedRoute.page),
// // //     AutoRoute(page: ResultsRoute.page),
// // //     AutoRoute(page: AccountRoute.page),
// // //     AutoRoute(page: DetailsRoute.page),
// // //     AutoRoute(page: FaceIdRoute.page),
// // //   ];
// // // }
