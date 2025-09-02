// // main_tab_screen.dart
// import 'package:auto_route/auto_route.dart';
// import 'package:flutter/material.dart';
// import 'package:astra_mobile/router/app_router.gr.dart';

// @RoutePage()
// class MainTabRoute extends StatelessWidget {
//   const MainTabRoute({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return AutoTabsScaffold(
//       backgroundColor: Colors.white,
//       resizeToAvoidBottomInset: false,
//       routes: const [
//         ShopRoute(),
//         CatalogRoute(),
//         CartRoute(),
//         LikeRoute(),
//         CheckRoute(),
//       ],
//       bottomNavigationBuilder: (context, tabsRouter) {
//         return BottomNavigationBar(
//           currentIndex: tabsRouter.activeIndex,
//           onTap: tabsRouter.setActiveIndex,
//           type: BottomNavigationBarType.fixed,
//           selectedItemColor: Colors.black,
//           unselectedItemColor: Colors.grey,
//           showSelectedLabels: true,
//           showUnselectedLabels: true,
//           items: const [
//             BottomNavigationBarItem(
//               icon: Icon(Icons.storefront),
//               label: 'Магазин',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.category),
//               label: 'Каталог',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.shopping_cart),
//               label: 'Корзина',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.favorite),
//               label: 'Избранное',
//             ),
//             BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
//           ],
//         );
//       },
//     );
//   }
// }
