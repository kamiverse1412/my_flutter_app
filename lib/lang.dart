import 'package:flutter/material.dart';
import 'package:auto_route/annotations.dart';

@RoutePage()
class LanguagePage extends StatelessWidget {
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            const SizedBox(height: 50),
            Image.asset(
              '/Users/kamila/Downloads/1x/halyk/astra_application/Logo.png',
              height: 150,
            ),
            const SizedBox(height: 20),
            const Text(
              'Выберите язык \n   приложения',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Вы всегда сможете изменить язык\n        в настройках приложения',
              style: TextStyle(color: Color.fromARGB(255, 116, 116, 116)),
            ),
            const SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.only(right: 320),
              child: const Text('Язык', style: TextStyle(color: Colors.black)),
            ),
            const SizedBox(height: 20),
            SelectLan(),
            const SizedBox(height: 150),
            Container(
              width: 360,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/login");
                },
                child: Text(
                  'Продолжить',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 8, 4, 130),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SelectLan extends StatefulWidget {
  @override
  _SelectLanState createState() => _SelectLanState();
}

class _SelectLanState extends State<SelectLan> {
  final List<String> items = [
    'Русский',
    'Kazakça',
    'Polski',
    'Türkçe',
    'English',
  ];
  String? selectedLanguage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: DropdownButtonFormField<String>(
        value: selectedLanguage,
        hint: const Text('Выберите язык'),
        icon: const Icon(Icons.expand_more, color: Colors.black),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.orange, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.orange, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        dropdownColor: Colors.white,
        items: items
            .map(
              (item) => DropdownMenuItem(
                value: item,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item),
                    if (selectedLanguage == item)
                      const Icon(Icons.check, color: Colors.orange),
                  ],
                ),
              ),
            )
            .toList(),
        onChanged: (value) {
          setState(() {
            selectedLanguage = value;
          });
        },
      ),
    );
  }
}
