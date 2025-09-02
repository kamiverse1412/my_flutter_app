import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:auto_route/annotations.dart';

@RoutePage()
class FaceIdPage extends StatefulWidget {
  final String? phone;
  final String? password;

  const FaceIdPage({super.key, this.phone, this.password});

  @override
  State<FaceIdPage> createState() => _FaceIdRouteState();
}

class _FaceIdRouteState extends State<FaceIdPage> {
  final LocalAuthentication auth = LocalAuthentication();
  final storage = const FlutterSecureStorage();
  String enteredPin = '';
  bool showPin = false;
  String phone = '';
  String passwordFromFirestore = '';

  @override
  void initState() {
    super.initState();
    authenticateWithBiometrics();
    loadUserData();
  }

  void loadUserData() async {
    phone = (await storage.read(key: 'phone')) ?? '';
    if (phone.isNotEmpty) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(phone)
          .get();
      passwordFromFirestore = doc.data()?['password'] ?? '';
    }
  }

  void authenticateWithBiometrics() async {
    try {
      bool authenticated = await auth.authenticate(
        localizedReason: 'Пожалуйста, подтвердите Face ID',
        options: const AuthenticationOptions(biometricOnly: true),
      );

      if (authenticated) {
        Navigator.pushReplacementNamed(context, '/verification');
      } else {
        setState(() {
          showPin = true;
        });
      }
    } catch (e) {
      setState(() {
        showPin = true;
      });
    }
  }

  void handlePinInput(String value) {
    if (enteredPin.length < 4) {
      setState(() {
        enteredPin += value;
      });
    }
    if (enteredPin.length == 4) {
      checkPin();
    }
  }

  void checkPin() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (enteredPin == '0000') {
      Navigator.pushReplacementNamed(context, '/shop');
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('INCORRECT PIN CODE')));
    }
  }

  void deletePin() {
    if (enteredPin.isNotEmpty) {
      setState(() {
        enteredPin = enteredPin.substring(0, enteredPin.length - 1);
      });
    }
  }

  Widget buildPinDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        return Container(
          margin: const EdgeInsets.all(8),
          width: 15,
          height: 15,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index < enteredPin.length ? Colors.black : Colors.grey[300],
          ),
        );
      }),
    );
  }

  Widget buildKeypad() {
    List<String> keys = [
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '',
      '0',
      '<',
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 60),
      itemCount: 12,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.5,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      itemBuilder: (context, index) {
        String key = keys[index];
        if (key.isEmpty) {
          return const SizedBox.shrink();
        } else if (key == '<') {
          return IconButton(
            icon: const Icon(Icons.backspace_outlined),
            onPressed: deletePin,
          );
        } else {
          return ElevatedButton(
            onPressed: () => handlePinInput(key),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: const CircleBorder(),
              elevation: 2,
            ),
            child: Text(
              key,
              style: const TextStyle(fontSize: 22, color: Colors.black),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              '/Users/kamila/Downloads/1x/halyk/astra_application/Logo.png',
              height: 50,
            ),
            const SizedBox(height: 20),
            const Text(
              'Код быстрого доступа',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => Navigator.pushReplacementNamed(context, '/login'),
              child: const Text(
                'Забыли ПИН-код?',
                style: TextStyle(color: Colors.blue),
              ),
            ),
            const SizedBox(height: 40),
            buildPinDots(),
            const SizedBox(height: 40),
            if (showPin) buildKeypad(),
          ],
        ),
      ),
    );
  }
}
