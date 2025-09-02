import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:astra_mobile/auth_service.dart';
import 'package:intl/intl.dart';
import 'package:auto_route/annotations.dart';

@RoutePage()
class DetailsPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const DetailsPage({super.key, required this.product});

  @override
  State<DetailsPage> createState() => _DetailsRouteState();
}

class _DetailsRouteState extends State<DetailsPage> {
  bool descExpanded = false;
  bool charExpanded = false;
  bool deliveryExpanded = false;
  bool returnExpanded = false;
  bool isAddingToCart = false;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final name = product['name'] ?? 'Без названия';
    final weight = product['weight']?.toString() ?? '—';
    final size = product['size']?.toString() ?? '—';
    final rawPrice = product['priceWithDiscount'];
    final formattedPrice = rawPrice != null
        ? NumberFormat('#,###', 'ru_RU')
              .format((rawPrice is double) ? rawPrice.toInt() : rawPrice)
              .replaceAll(',', ' ')
        : '0';

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 250,
                child: Builder(
                  builder: (context) {
                    final List<String> imageUrls = [];
                    if (product['imagePath']?.toString().isNotEmpty == true) {
                      imageUrls.add(product['imagePath']);
                    }
                    if (product['bannerImagePath']?.toString().isNotEmpty ==
                            true &&
                        product['bannerImagePath'] != product['imagePath']) {
                      imageUrls.add(product['bannerImagePath']);
                    }
                    if (imageUrls.length == 1) {
                      imageUrls.add(imageUrls.first);
                    }

                    return PageView.builder(
                      itemCount: imageUrls.length,
                      itemBuilder: (context, index) {
                        return Image.network(
                          imageUrls[index],
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey[300],
                            height: 250,
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 60,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(height: 6),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Text("Вес: $weight г"),
                    const SizedBox(width: 16),
                    Text("Размер: $size"),
                  ],
                ),
              ),

              const SizedBox(height: 12),
              const Divider(),

              buildExpandableTile(
                "Описание",
                product['description'] ?? "Нет описания",
                descExpanded,
                (v) => setState(() => descExpanded = v),
              ),
              buildExpandableTile(
                "Характеристики",
                _buildCharacteristics(product),
                charExpanded,
                (v) => setState(() => charExpanded = v),
              ),
              buildExpandableTile(
                "Доставка и оплата",
                "Доставка по Казахстану в течение 3‑5 рабочих дней.",
                deliveryExpanded,
                (v) => setState(() => deliveryExpanded = v),
              ),
              buildExpandableTile(
                "Обмен и возврат",
                "Обмен возможен в течение 14 дней при наличии чека.",
                returnExpanded,
                (v) => setState(() => returnExpanded = v),
              ),

              const SizedBox(height: 16),

              /// Add to Cart Button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: isAddingToCart
                      ? null
                      : () => addToCart(product['id']),
                  child: isAddingToCart
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          "В корзину – $formattedPrice ₸",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildExpandableTile(
    String title,
    dynamic content,
    bool expanded,
    Function(bool) onChanged,
  ) {
    return ExpansionTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      initiallyExpanded: expanded,
      onExpansionChanged: onChanged,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: content is String
              ? Text(content)
              : content is Widget
              ? content
              : const Text("Нет данных"),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildCharacteristics(Map<String, dynamic> product) {
    final metal = product['metalColor'] ?? '—';
    final sample = product['sample'] ?? '—';
    final gender = product['gender'] ?? '—';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Металл: $metal"),
        const SizedBox(height: 4),
        Text("Проба: $sample"),
        const SizedBox(height: 4),
        Text("Пол: $gender"),
      ],
    );
  }

  Future<void> addToCart(String? productId) async {
    if (productId == null) return;

    setState(() => isAddingToCart = true);

    final token = await AuthService.getToken();
    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Вы не авторизованы')));
      setState(() => isAddingToCart = false);
      return;
    }

    final response = await http.post(
      Uri.parse('https://api.store.astra-lombard.kz/api/v1/cart'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({"productId": productId, "quantity": 1}),
    );

    setState(() => isAddingToCart = false);

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Товар добавлен в корзину')));
    } else if (response.statusCode == 401) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Сессия истекла, войдите заново')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка добавления в корзину')),
      );
    }
  }
}
