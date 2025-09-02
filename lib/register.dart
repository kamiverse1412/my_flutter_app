import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:auto_route/annotations.dart';

@RoutePage()
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterSecureStorage storage = FlutterSecureStorage();

  final maskFormatter = MaskTextInputFormatter(
    mask: '+7 (###) ### ##-##',
    filter: {"#": RegExp(r'\d')},
    initialText: '+7 ',
  );

  String normalizePhone(String formattedPhone) {
    return formattedPhone.replaceAll(RegExp(r'[^\d]'), '');
  }

  void registerUser(BuildContext context) async {
    String surname = surnameController.text.trim();
    String firstName = firstNameController.text.trim();
    String phone = phoneController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (surname.isEmpty ||
        firstName.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Пожалуйста, заполните все поля")));
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Пароли не совпадают")));
      return;
    }

    String normalizedPhone = normalizePhone(phone);

    DocumentSnapshot doc = await _firestore
        .collection('users')
        .doc(normalizedPhone)
        .get();
    if (doc.exists) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Этот номер уже зарегистрирован")));
      return;
    }

    await _firestore.collection('users').doc(normalizedPhone).set({
      'phone': normalizedPhone,
      'password': password,
      'surname': surname,
      'firstName': firstName,
    });

    await storage.write(key: 'pin_code', value: password);
    await storage.write(key: 'phone', value: normalizedPhone);

    Navigator.pushNamed(context, '/faceid');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 130,
        title: Image.asset(
          "/Users/kamila/Downloads/1x/halyk/astra_application/Logo.png",
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(size: 25, color: Colors.black),
      ),
      body: Column(
        children: [
          const SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.only(right: 210),
            child: const Text(
              'Регистрация',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w700,
                fontSize: 25,
              ),
            ),
          ),
          const SizedBox(height: 40),
          Center(
            child: SizedBox(
              width: 370,
              child: TextField(
                controller: surnameController,
                decoration: InputDecoration(
                  hintText: 'Фамилия',
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey, width: 1),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: 370,
              child: TextField(
                controller: firstNameController,
                decoration: InputDecoration(
                  hintText: 'Имя',
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey, width: 1),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: 370,
              child: TextField(
                keyboardType: TextInputType.phone,
                controller: phoneController,
                inputFormatters: [maskFormatter],
                decoration: InputDecoration(
                  hintText: '+7 (___) ___ __-__',
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey, width: 1),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: 370,
              child: TextField(
                controller: passwordController,
                obscureText: true,
                maxLength: 8,
                decoration: InputDecoration(
                  hintText: '8-значный пароль',
                  counterText: '',
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey, width: 1),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: 370,
              child: TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Подтвердить пароль',
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey, width: 1),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 33),
          Container(
            width: 370,
            height: 55,
            child: ElevatedButton(
              onPressed: () => registerUser(context),
              child: Text(
                'Зарегистрироваться',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 233, 140, 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Уже зарегистрированные?'),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/login");
                },
                child: Text('Войти'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Column(
            children: [
              Text(
                'Регистрируя аккаунт, вы подтверждаете,',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'что прочитали и приняли ',
                    style: TextStyle(fontSize: 13),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, "/privacy");
                    },
                    child: Text(
                      'Политику конфиденциальности.',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
