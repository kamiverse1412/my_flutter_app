import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:astra_mobile/auth_service.dart';
import 'package:auto_route/annotations.dart';

@RoutePage()
class ShopPage extends StatefulWidget {
  static var page;

  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> searchResults = [];
  bool isLoading = true;
  bool isSearching = false;
  Set<String> likedIds = {};
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    initData();
  }

  Future<void> initData() async {
    await fetchLiked();
    await fetchProducts();
  }

  Future<void> fetchLiked() async {
    final token = await AuthService.getToken();
    if (token == null) return;
    final resp = await http.get(
      Uri.parse('https://api.store.astra-lombard.kz/api/v1/favourites'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (resp.statusCode == 200) {
      final items = jsonDecode(resp.body)['items'] as List;
      likedIds = items.map((e) => e['product']['id'] as String).toSet();
    }
  }

  Future<void> fetchProducts() async {
    try {
      final resp = await http.post(
        Uri.parse('https://api.store.astra-lombard.kz/api/v1/products/search'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"pageSize": 30}),
      );
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body)['data'] as List;
        products = data.map((p) {
          final m = Map<String, dynamic>.from(p);
          m['isFavorite'] = likedIds.contains(m['id']);
          return m;
        }).toList();
      }
    } catch (_) {}
    setState(() => isLoading = false);
  }

  Future<void> searchProducts(String query) async {
    final response = await http.post(
      Uri.parse('https://api.store.astra-lombard.kz/api/v1/products/search'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        "pageSize": 30,
        "pageNumber": 1,
        "orderBy": [],
        "advancedFilter": {
          "logic": "and",
          "filters": [
            {"field": "name", "operator": "contains", "value": query},
          ],
        },
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final items = List<Map<String, dynamic>>.from(data['data']);
      setState(() {
        searchResults = items;
        isSearching = false;
      });
    } else {
      print('Search failed: ${response.statusCode}');
      setState(() {
        isSearching = false;
      });
    }
  }

  void addToCartToast(Map<String, dynamic> p) {
    final overlay = Overlay.of(context);
    if (overlay == null) return;
    final entry = OverlayEntry(
      builder: (_) => Positioned(
        top: 10,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(blurRadius: 8, color: Colors.black26)],
            ),
            child: Row(
              children: [
                Image.network(
                  p['imagePath'] ?? '',
                  width: 60,
                  height: 40,
                  fit: BoxFit.cover,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Товар добавлен в корзину',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(p['name'], overflow: TextOverflow.ellipsis),
                      Text('Цена: ${p['priceWithDiscount']} ₸'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    overlay.insert(entry);
    Future.delayed(Duration(seconds: 3), () => entry.remove());
  }

  @override
  Widget build(BuildContext ctx) {
    final nf = NumberFormat('#,###', 'ru_RU');
    final dataToShow = searchQuery.isEmpty ? products : searchResults;

    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                SizedBox(height: 60),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: TextField(
                    controller: searchController,
                    onChanged: (value) async {
                      setState(() {
                        searchQuery = value;
                        isSearching = true;
                      });

                      if (value.isEmpty) {
                        setState(() {
                          searchResults.clear();
                          isSearching = false;
                        });
                        return;
                      }

                      await searchProducts(value);
                    },
                    decoration: InputDecoration(
                      hintText: 'Поиск...',
                      prefixIcon: Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/catalog');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                17,
                                14,
                                120,
                              ),
                              minimumSize: Size.fromHeight(48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Прейти в Астра-ломбард',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 400,
                          height: 300,
                          child: Image.asset(
                            'assets/images/Frame120.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        if (dataToShow.isNotEmpty) ...[
                          CarouselSlider(
                            options: CarouselOptions(
                              height: 250,
                              autoPlay: true,
                              enlargeCenterPage: true,
                            ),
                            items: dataToShow.take(5).map((p) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  p['imagePath'] ?? '',
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              );
                            }).toList(),
                          ),
                          SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Text(
                              'Новинки',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          buildProductRow(dataToShow.take(6).toList(), nf),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Text(
                              'Популярные товары',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          buildProductRow(
                            dataToShow.skip(6).take(6).toList(),
                            nf,
                          ),
                        ],
                        SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (i) {
          switch (i) {
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

  Widget buildProductRow(List<Map<String, dynamic>> items, NumberFormat nf) {
    return Container(
      height: 280,
      margin: EdgeInsets.only(bottom: 16),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 12),
        itemCount: items.length,
        separatorBuilder: (_, __) => SizedBox(width: 12),
        itemBuilder: (_, i) {
          final p = items[i];
          final price = nf.format((p['priceWithDiscount'] as num).toInt());
          return SizedBox(
            width: 180,
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/details', arguments: p);
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: Image.network(
                          p['imagePath'] ?? '',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p['name'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '$price ₸',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 6),
                          ElevatedButton(
                            onPressed: () => addToCartToast(p),
                            child: Text(
                              'В корзину',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              minimumSize: Size.fromHeight(30),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
