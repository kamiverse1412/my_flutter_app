import 'package:astra_mobile/auth_service.dart' hide LikedStorage;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:astra_mobile/liked_storage.dart';
import 'package:auto_route/annotations.dart';

@RoutePage()
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<LoginPage> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final dio = Dio();
  final storage = FlutterSecureStorage();

  final maskFormatter = MaskTextInputFormatter(
    mask: '+7 (###) ### ##-##',
    filter: {"#": RegExp(r'\d')},
    type: MaskAutoCompletionType.lazy,
  );

  get user => null;

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ),
    );
  }

  void login() async {
    final rawPhone = phoneController.text.trim();
    final phone =
        '+7' +
        rawPhone.replaceAll(RegExp(r'\D'), '').substring(1); // keep +7 format
    final password = passwordController.text.trim();

    if (phone.isEmpty || password.isEmpty) {
      showError("Пожалуйста, заполните все поля");
      return;
    }

    try {
      final response = await dio.post(
        'https://api.store.astra-lombard.kz/api/tokens',
        data: jsonEncode({"PhoneNumber": phone, "Password": password}),
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = response.data['token'] ?? response.data['access_token'];
        if (token == null || token.isEmpty) {
          showError("Токен не получен");
          return;
        }
        await storage.write(key: 'auth_token', value: token);

        await AuthService.setToken(token);
        await AuthService.saveCredentials(phone, password);

        Navigator.pushNamed(context, '/check');
      } else {
        showError("Неверный номер или пароль");
      }
    } catch (e) {
      print('Login error: $e');
      showError("Ошибка при входе");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 130,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(size: 25, color: Colors.black),
        title: Image.asset(
          "/Users/kamila/Downloads/1x/halyk/astra_application/Logo.png",
          height: 80,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Вход',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 25,
                ),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: 370,
              child: TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [maskFormatter],
                decoration: InputDecoration(
                  hintText: '+7 (777) 777 77-77',
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: CupertinoColors.inactiveGray,
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 370,
              child: TextField(
                controller: passwordController,
                maxLength: 8,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: '8-значный ПИН-код',
                  counterText: '',
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: CupertinoColors.inactiveGray,
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: 360,
              height: 55,
              child: ElevatedButton(
                onPressed: login,
                child: Text(
                  'Войти',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 255, 153, 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Нет учетной записи?'),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "/register");
                  },
                  child: Text('Зарегистрироваться'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
