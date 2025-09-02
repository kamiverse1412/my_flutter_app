import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:auto_route/annotations.dart';

@RoutePage()
class AccountPage extends StatefulWidget {
  const AccountPage({super.key});
  @override
  State<AccountPage> createState() => _AccountRouteState();
}

class _AccountRouteState extends State<AccountPage> {
  Map<String, dynamic>? user;
  final storage = FlutterSecureStorage();
  final dio = Dio();

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final token = await storage.read(key: 'auth_token');

      if (token == null) {
        showError("Токен не найден. Пожалуйста, войдите снова.");
        return;
      }

      final response = await dio.get(
        'https://api.store.astra-lombard.kz/api/personal/profile',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          user = response.data;
        });
      } else {
        showError("Ошибка при загрузке профиля");
      }
    } catch (e) {
      print('fetch error: $e');
      showError("Не удалось загрузить данные пользователя");
    }
  }

  void showError(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  String displayField(String? value) =>
      (value != null && value.isNotEmpty) ? value : '—';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Text(
          'Аккаунт',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 1,
      ),
      body: user == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 20),
                  infoTile('Имя', displayField(user?['firstName'])),
                  SizedBox(height: 20),
                  infoTile('Фамилия', displayField(user?['lastName'])),
                  SizedBox(height: 20),
                  infoTile(
                    'Номер телефона',
                    displayField(user?['phoneNumber']),
                  ),
                  SizedBox(height: 20),
                  Container(
                    width: 410,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Пароль',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '********',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      trailing: Icon(Icons.edit, size: 24, color: Colors.black),
                    ),
                  ),
                  SizedBox(height: 30),
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
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront),
            label: 'Магазин',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Каталог'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Корзина',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Избранное',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
        ],
      ),
    );
  }

  Widget infoTile(String label, String? value) {
    return Container(
      width: 410,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
            SizedBox(height: 4),
            Text(
              value ?? '—',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
