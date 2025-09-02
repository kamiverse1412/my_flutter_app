import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:astra_mobile/auth_service.dart';
import 'package:intl/intl.dart';
import 'package:auto_route/annotations.dart';

@RoutePage()
class LikePage extends StatefulWidget {
  static var page;

  const LikePage({super.key});

  @override
  State<LikePage> createState() => _LikePageState();
}

class _LikePageState extends State<LikePage> {
  List<dynamic> favourites = [];
  final dio = Dio();
  var f = NumberFormat('#,###', 'ru_RU');

  get authService => null;

  @override
  void initState() {
    super.initState();
    fetchFavourites();
  }

  Future<void> fetchFavourites() async {
    try {
      final items = await AuthService.fetchFavourites();
      setState(() {
        favourites = items;
      });
    } catch (e) {
      print("Ошибка при загрузке избранных: $e");
    }
  }

  void removeFavourite(int index) async {
    final item = favourites[index];
    final productId = item["id"];

    if (productId == null) {
      if (kDebugMode) {
        print("⚠️ productId is null, cannot delete.");
      }
      return;
    }

    final url =
        "https://api.store.astra-lombard.kz/api/v1/favourites/$productId";

    try {
      final token = await AuthService.getToken();
      final response = await dio.delete(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if ([200, 201, 204].contains(response.statusCode)) {
        setState(() {
          favourites.removeAt(index);
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Удалено из избранного')));
      } else {
        print("Failed: ${response.statusCode}, ${response.data}");
      }
    } catch (e) {
      print("Ошибка при удалении: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ошибка при удалении')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text("Избранное", style: TextStyle(fontWeight: FontWeight.w500)),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: favourites.isEmpty
          ? Center(child: Text("Список избранного пуст"))
          : ListView.builder(
              padding: EdgeInsets.all(screenWidth * 0.025),
              itemCount: favourites.length,
              itemBuilder: (context, index) {
                final productFav = favourites[index];
                final String img = productFav["imagePath"] ?? "";
                final String name = productFav["name"] ?? "";
                final int price = productFav["basePrice"]?.toInt() ?? 0;
                final money = f.format(price);
                final String weight = productFav["weight"]?.toString() ?? "0";

                return Container(
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFFF8F8F8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          img,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 4),
                            RichText(
                              text: TextSpan(
                                text: "Вес изделия: ",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF909090),
                                ),
                                children: [
                                  TextSpan(
                                    text: "$weight г",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF34398B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "$money ₸",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Удалить из избранного?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: Text(
                                    'Отмена',
                                    style: TextStyle(color: Colors.orange),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: Text(
                                    'Подтвердить',
                                    style: TextStyle(color: Colors.orange),
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            removeFavourite(index);
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(
                            Icons.delete_outline,
                            size: 24,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
