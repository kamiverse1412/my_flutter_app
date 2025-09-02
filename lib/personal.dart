import 'package:flutter/material.dart';

import 'package:auto_route/annotations.dart';

@RoutePage()
class PersonalPage extends StatelessWidget {
  const PersonalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Мои данные',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
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
                  'Аккаунт',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                onTap: () {
                  Navigator.pushNamed(context, '/account');
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
                  color: Colors.black,
                ),
                title: Text(
                  'Мои бонусы',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
