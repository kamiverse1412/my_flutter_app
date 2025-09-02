import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:astra_mobile/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:auto_route/annotations.dart';

final dio = Dio();

void getHttp() async {
  final response = await dio.get(
    'https://api.store.astra-lombard.kz/api/tokens',
  );
  print(response);
}

void request() async {
  Response response;
  response = await dio.get('/test?id=12&name=dio');
  print(response.data.toString());
  response = await dio.get('/test', queryParameters: {'id': 12, 'name': 'dio'});
  print(response.data.toString());
}

@RoutePage()
class CheckPage extends StatefulWidget {
  static var page;

  const CheckPage({super.key});

  @override
  State<CheckPage> createState() => _CheckPageState();
}

class _CheckPageState extends State<CheckPage> {
  Map<String, dynamic>? user;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map<String, dynamic>) {
      setState(() {
        user = args;
      });
      print('PROFILE PAGE got user: $user');
      AuthService.setToken(user?['token']);
    }
  }

  bool isFaceIDEnabled = true;
  bool isFingerprintEnabled = false;

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Профиль',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.black),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('phone');
              await prefs.remove('password');

              final storage = FlutterSecureStorage();
              await storage.delete(key: 'auth_token');

              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 12),
            Container(
              width: 410,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(
                  Icons.person_outline,
                  size: 24,
                  color: Colors.black,
                ),
                title: Text(
                  'Мои данные',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                trailing: Text(
                  'Бонусы ~ 120,000 ₸',
                  style: TextStyle(color: Colors.orange),
                ),
                onTap: () =>
                    Navigator.pushNamed(context, '/personal', arguments: user),
              ),
            ),
            SizedBox(height: 12),
            Container(
              width: 410,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(
                  Icons.local_shipping, // closest match to delivery/truck
                  size: 24,
                  color: Colors.black, // optional
                ),
                title: Text(
                  'Доставка и оплата',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                onTap: () {},
              ),
            ),
            SizedBox(height: 12),
            Container(
              width: 410,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(
                  Icons.sticky_note_2_outlined,
                  size: 24,
                  color: Colors.black,
                ),

                title: Text(
                  'Пользовательское соглашение',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                onTap: () {
                  final controller = WebViewController()
                    ..setJavaScriptMode(JavaScriptMode.unrestricted)
                    ..addJavaScriptChannel(
                      "goToBack",
                      onMessageReceived: (JavaScriptMessage message) {
                        Navigator.of(context).pop();
                      },
                    )
                    ..loadRequest(
                      Uri.parse('https://astra-market-hzmg.vercel.app/oferta'),
                    );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Scaffold(
                        body: SafeArea(
                          child: WebViewWidget(controller: controller),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 12),
            Container(
              width: 410,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(
                  Icons.emoji_events,
                  size: 24,
                  color: Colors.black, // or Colors.amber for a golden vibe
                ),

                title: Text(
                  'Гарантия качества',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                onTap: () {},
              ),
            ),
            SizedBox(height: 12),
            Container(
              width: 410,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(
                  Icons.sticky_note_2_outlined,
                  size: 24,
                  color: Colors.black,
                ),
                title: Text(
                  'Публичная оферта',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                onTap: () {},
              ),
            ),
            SizedBox(height: 12),
            Container(
              width: 410,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 0,
                ),
                leading: Icon(Icons.language, color: Colors.black),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Язык',
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color(0xFF757575),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Русский',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                onTap: () {},
              ),
            ),
            SizedBox(height: 15),

            SwitchListTile(
              title: Text('Вход по Face ID'),
              value: isFaceIDEnabled,
              onChanged: (val) {
                setState(() {
                  isFaceIDEnabled = val;
                });
              },
              activeColor: Colors.orange,
            ),

            SwitchListTile(
              title: Text('Вход по отпечатку пальца'),
              value: isFingerprintEnabled,
              onChanged: (val) {
                setState(() {
                  isFingerprintEnabled = val;
                });
              },
              activeColor: Colors.orange,
            ),

            SizedBox(height: 40),
            Container(
              width: 430,
              color: Color.fromRGBO(52, 57, 139, 1),
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  Text(
                    'Гарячая линия',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final Uri phoneUri = Uri.parse('tel:88000700540');

                      if (await canLaunchUrl(phoneUri)) {
                        await launchUrl(
                          phoneUri,
                          mode: LaunchMode.externalApplication,
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Не удалось открыть номер'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: Text(
                      '8 800 070 05 40',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),

                  SizedBox(height: 4),
                  Text(
                    'Понедельник - Пятница 9:00 - 20:00',
                    style: TextStyle(color: Colors.white70),
                  ),
                  Text(
                    'Суббота 10:00 - 19:00',
                    style: TextStyle(color: Colors.white70),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Мы в соцсетях',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt, color: Colors.white, size: 35),
                      SizedBox(width: 15),
                      Icon(Icons.facebook, color: Colors.white, size: 35),
                      SizedBox(width: 15),
                      Icon(Icons.telegram, color: Colors.white, size: 35),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 4,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/shop');
              break;
            case 1:
              Navigator.pushNamed(context, '/catalog');
              break;
            case 2:
              Navigator.pushNamed(context, '/cart');
              break;
            case 3:
              Navigator.pushNamed(context, '/liked');
              break;
            // case 4:
            //   Navigator.pushNamed(context, '/profile');
            //   break;
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront), // Магазин
            label: 'Магазин',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category), // Каталог
            label: 'Каталог',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart), // Корзина
            label: 'Корзина',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border), // Избранное
            label: 'Избранное',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person), // Профиль
            label: 'Профиль',
          ),
        ],
      ),
    );
  }
}
