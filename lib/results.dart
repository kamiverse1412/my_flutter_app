import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_service.dart';
import 'liked.dart';
import 'details.dart';
import 'package:astra_mobile/auth_service.dart';
import 'package:auto_route/annotations.dart';

@RoutePage()
class ResultsPage extends StatefulWidget {
  const ResultsPage({super.key});

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  List<Map<String, dynamic>> filteredProducts = [];
  bool isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!isInitialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is List<dynamic>) {
        filteredProducts = args.cast<Map<String, dynamic>>();
      }
      isInitialized = true;
    }
  }

  void showAddToCartToast(BuildContext context, Map<String, dynamic> product) {
    final overlay = Overlay.of(context);
    if (overlay == null) return;

    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 80,
        right: 20,
        left: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26)],
            ),
            child: Row(
              children: [
                Image.network(
                  product['imagePath'] ?? '',
                  height: 60,
                  width: 60,
                  fit: BoxFit.cover,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Тауар себетке сәтті қосылды',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        product['name'] ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text('Салмағы: ${product['weight'] ?? '—'} г'),
                      SizedBox(height: 2),
                      Text('Бағасы: ${product['priceWithDiscount']} ₸'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(Duration(seconds: 3), () => overlayEntry.remove());
  }

  Widget buildProductItem(Map<String, dynamic> product) {
    final String imageUrl = product['imagePath'] ?? '';
    final String name = product['name'] ?? '';
    final rawPrice = product['priceWithDiscount'];
    final String productId = product['id'] ?? '';
    final bool isLiked = product['isFavourite'] ?? false;

    final formattedPrice = rawPrice != null
        ? NumberFormat('#,###', 'ru_RU')
              .format((rawPrice is double) ? rawPrice.toInt() : rawPrice)
              .replaceAll(',', ' ')
        : '0';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailsPage(product: product)),
        );
      },
      child: Container(
        padding: EdgeInsets.all(6),
        margin: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                height: 90,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(height: 90, color: Colors.grey[200]),
              ),
            ),
            SizedBox(height: 6),
            Text(
              name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13),
            ),
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$formattedPrice ₸',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 16, 50, 111),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    final token = await AuthService.getToken();
                    if (token == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Пользователь не авторизован')),
                      );
                      return;
                    }

                    final wasLiked = await LikedStorage.isLiked(productId);

                    setState(() {
                      product['isFavourite'] = !wasLiked;
                    });

                    if (wasLiked) {
                      await LikedStorage.unlikeProduct(productId);
                    } else {
                      await LikedStorage.likeProduct(product);
                    }

                    final url =
                        'https://api.store.astra-lombard.kz/api/v1/favourites';
                    final headers = {
                      'Content-Type': 'application/json',
                      'Authorization': 'Bearer $token',
                    };
                    final body = jsonEncode({"productId": productId});

                    try {
                      final response = wasLiked
                          ? await http.delete(
                              Uri.parse(url).replace(
                                queryParameters: {'productId': productId},
                              ),
                              headers: headers,
                            )
                          : await http.post(
                              Uri.parse(url),
                              headers: headers,
                              body: body,
                            );

                      if (response.statusCode != 200 &&
                          response.statusCode != 201) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Already liked')),
                        );
                      }
                    } catch (e) {
                      setState(() {
                        product['isFavourite'] = wasLiked;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Сервер недоступен. Попробуйте позже'),
                        ),
                      );
                    }
                  },
                  child: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.orange : Colors.grey.shade400,
                    size: 24,
                  ),
                ),
              ],
            ),
            SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              height: 36,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  final token = await AuthService.getToken();
                  if (token == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Пользователь не авторизован')),
                    );
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

                  if (response.statusCode == 200 ||
                      response.statusCode == 201) {
                    showAddToCartToast(context, product);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Ошибка добавления в корзину')),
                    );
                  }
                },
                child: Text("В корзину"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Результаты", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
        elevation: 1,
      ),
      backgroundColor: Colors.white,
      body: filteredProducts.isEmpty
          ? Center(child: Text("Нет результатов"))
          : GridView.builder(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                mainAxisExtent: 250,
              ),
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) =>
                  buildProductItem(filteredProducts[index]),
            ),
    );
  }
}
