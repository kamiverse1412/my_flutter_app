import 'package:astra_mobile/details.dart';
import 'package:astra_mobile/liked.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:astra_mobile/auth_service.dart' hide LikedStorage;
import 'package:intl/intl.dart';
import 'package:astra_mobile/liked_storage.dart';
import 'package:auto_route/annotations.dart';

@RoutePage()
class SelectedPage extends StatefulWidget {
  final String categoryName;
  final String categoryId;

  const SelectedPage({
    super.key,
    required this.categoryName,
    required this.categoryId,
  });

  @override
  State<SelectedPage> createState() => _SelectedPageState();
}

class _SelectedPageState extends State<SelectedPage> {
  List<Map<String, dynamic>> filteredProducts = [];
  bool isLoading = true;
  Set<String> likedProductIds = {};

  @override
  void initState() {
    super.initState();
    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    await fetchLikedProducts();
    await fetchAndFilterProducts();
  }

  Future<void> fetchLikedProducts() async {
    final token = await AuthService.getToken();
    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse('https://api.store.astra-lombard.kz/api/v1/favourites'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['items'] ?? [];

        setState(() {
          likedProductIds = items
              .map<String>((item) => item['product']['id'] as String)
              .toSet();
        });
      }
    } catch (e) {
      print("Error fetching liked products: $e");
    }
  }

  Future<void> fetchAndFilterProducts() async {
    try {
      final response = await http.post(
        Uri.parse('https://api.store.astra-lombard.kz/api/v1/products/search'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"pageSize": 200}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> allProducts = responseData['data'];

        final filtered = allProducts
            .where((product) => product['category']?['id'] == widget.categoryId)
            .map<Map<String, dynamic>>((product) {
              product['isFavourite'] = likedProductIds.contains(
                product['id'] ?? '',
              );
              return product;
            })
            .toList();

        setState(() {
          filteredProducts = filtered;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
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
                        product['name'],
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

  Future<void> fetchdetails() async {
    try {
      final response = await http.post(
        Uri.parse(
          'https://api.store.astra-lombard.kz/api/v1/products/d93695a9-958d-466f-8fa7-08dcf28cf308',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"pageSize": 200}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> allProducts = responseData['data'];

        final filtered = allProducts
            .where((product) => product['category']?['id'] == widget.categoryId)
            .map<Map<String, dynamic>>((product) {
              product['isFavourite'] = likedProductIds.contains(
                product['id'] ?? '',
              );
              return product;
            })
            .toList();

        setState(() {
          filteredProducts = filtered;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Widget buildProductItem(Map<String, dynamic> product) {
    final String imageUrl = product['imagePath'] ?? '';
    final String name = product['name'] ?? '';
    final rawPrice = product['priceWithDiscount'];

    final formattedPrice = rawPrice != null
        ? NumberFormat('#,###', 'ru_RU')
              .format((rawPrice is double) ? rawPrice.toInt() : rawPrice)
              .replaceAll(',', ' ')
        : '0';

    final String productId = product['id'] ?? '';
    final bool isLiked = product['isFavourite'] ?? false;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailsPage(product: product),
          ),
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
                // height: 90,
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
                      if (wasLiked) {
                        product['isFavourite'] = false;
                      } else {
                        product['isFavourite'] = true;
                      }
                    });

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

                      if (response.statusCode == 200 ||
                          response.statusCode == 201) {
                        if (wasLiked) {
                          await LikedStorage.unlikeProduct(productId);
                        } else {
                          await LikedStorage.likeProduct(product);
                        }
                        final testList = await LikedStorage.getLikedProducts();
                        print(
                          "Currently liked: ${testList.map((e) => e['name']).toList()}",
                        );
                      } else {
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
                      SnackBar(content: Text('Tovar uje est v korzine')),
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(widget.categoryName, style: TextStyle(color: Colors.black)),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.sort, size: 18),
                          SizedBox(width: 4),
                          Text("По популярности"),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/filter');
                        },
                        child: Row(
                          children: [
                            Icon(Icons.filter_alt_outlined, size: 18),
                            SizedBox(width: 4),
                            Text("Фильтр"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: filteredProducts.isEmpty
                      ? Center(child: Text("Нет товаров"))
                      : GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          gridDelegate:
                              SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 200,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10,
                                mainAxisExtent: 330,
                              ),
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, index) =>
                              buildProductItem(filteredProducts[index]),
                        ),
                ),
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
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
            case 4:
              Navigator.pushNamed(context, '/profile');
              break;
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
