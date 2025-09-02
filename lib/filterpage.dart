import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:auto_route/annotations.dart';

@RoutePage()
class FilterPage extends StatefulWidget {
  const FilterPage({super.key});

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  double priceStart = 182;
  double priceEnd = 120928;
  double weightStart = 0.001;
  double weightEnd = 100.25;

  final TextEditingController probeFromController = TextEditingController(
    text: '585',
  );
  final TextEditingController probeToController = TextEditingController(
    text: '750',
  );

  String selectedGender = 'Женщине';
  String? selectedSize;
  String? selectedLength;
  String selectedColor = 'Красное золото';

  final List<String> sizes = ['14', '15', '16', '17', '18', '19'];
  final List<String> lengths = ['40', '45', '50'];
  final List<String> genders = ['Женщине', 'Мужчине', 'Ребенку'];
  final List<String> colors = [
    'Красное золото',
    'Белое золото',
    'Желтое золото',
  ];

  Map<String, String> genderMapping = {
    'Женщине': 'Женское',
    'Мужчине': 'Мужское',
    'Ребенку': 'Детское',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Фильтр', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Цена"),
            RangeSlider(
              values: RangeValues(priceStart, priceEnd),
              min: 182,
              max: 120928,
              activeColor: Colors.orange,
              onChanged: (values) {
                setState(() {
                  priceStart = values.start;
                  priceEnd = values.end;
                });
              },
            ),
            Text(
              "От ${priceStart.toStringAsFixed(0)} ₸ до ${priceEnd.toStringAsFixed(0)} ₸",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),

            const Text("Вес"),
            RangeSlider(
              values: RangeValues(weightStart, weightEnd),
              min: 0.001,
              max: 100.25,
              activeColor: Colors.orange,
              onChanged: (values) {
                setState(() {
                  weightStart = values.start;
                  weightEnd = values.end;
                });
              },
            ),
            Text(
              (weightStart != null && weightEnd != null)
                  ? "От ${weightStart!.toStringAsFixed(3)} г до ${weightEnd!.toStringAsFixed(2)} г"
                  : "Выберите вес",
            ),

            const SizedBox(height: 16),

            const Text("Проба"),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: probeFromController,
                    decoration: const InputDecoration(
                      hintText: 'От',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: probeToController,
                    decoration: const InputDecoration(
                      hintText: 'До',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            const Text("Для кого"),
            Row(
              children: genders.map((gender) {
                final isSelected = selectedGender == gender;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(gender),
                    selected: isSelected,
                    selectedColor: Colors.orange,
                    onSelected: (_) {
                      setState(() {
                        selectedGender = gender;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            const Text("Размер"),
            DropdownButton<String>(
              value: selectedSize,
              hint: const Text("Выберите размер"),
              isExpanded: true,
              items: sizes.map((size) {
                return DropdownMenuItem(value: size, child: Text(size));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedSize = value;
                });
              },
            ),
            const SizedBox(height: 16),

            const Text("Длина"),
            DropdownButton<String>(
              value: selectedLength,
              hint: const Text("Выберите длину"),
              isExpanded: true,
              items: lengths.map((length) {
                return DropdownMenuItem(
                  value: length,
                  child: Text("$length см"),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedLength = value;
                });
              },
            ),
            const SizedBox(height: 16),

            const Text("Цвет золота"),
            Row(
              children: colors.map((color) {
                final isSelected = selectedColor == color;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(color),
                    selected: isSelected,
                    selectedColor: Colors.orange,
                    onSelected: (_) {
                      setState(() {
                        selectedColor = color;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 34),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () async {
                  final body = {
                    "pageSize": 30,
                    "pageNumber": 1,
                    "orderBy": [],
                    "advancedFilter": {
                      "logic": "and",
                      "filters": [
                        {
                          "filters": [
                            {
                              "field": "metadata.filters",
                              "operator": "contains",
                              "value":
                                  "{Для кого:${genderMapping[selectedGender]}}",
                            },
                          ],
                          "logic": "or",
                        },
                        {
                          "filters": [
                            {
                              "field": "metadata.filters",
                              "operator": "contains",
                              "value": "{Цвет металла:$selectedColor}",
                            },
                          ],
                          "logic": "or",
                        },
                        {
                          "filters": [
                            {
                              "field": "metadata.filters",
                              "operator": "contains",
                              "value": "{Проба:${probeFromController.text}}",
                            },
                          ],
                          "logic": "or",
                        },
                        {
                          "field": "priceWithDiscount",
                          "operator": "gte",
                          "value": priceStart.toInt(),
                        },
                        {
                          "field": "priceWithDiscount",
                          "operator": "lte",
                          "value": priceEnd.toInt(),
                        },
                      ],
                    },
                  };

                  print("🧪 Request Body: ${jsonEncode(body)}");

                  final response = await http.post(
                    Uri.parse(
                      'https://api.store.astra-lombard.kz/api/v1/products/search',
                    ),
                    headers: {
                      "Content-Type": "application/json",
                      "Accept": "application/json",
                    },
                    body: jsonEncode(body),
                  );

                  print("✅ API Status: ${response.statusCode}");
                  print("📦 API Response: ${response.body}");

                  if (response.statusCode == 200) {
                    final data = jsonDecode(response.body);
                    final products = data['data'] as List<dynamic>? ?? [];

                    if (products.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Нет подходящих товаров по фильтрам"),
                        ),
                      );
                    } else {
                      Navigator.pushNamed(
                        context,
                        '/results',
                        arguments: products,
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Ошибка при поиске")),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Показать",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
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
