import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:astra_mobile/auth_service.dart';
import 'package:auto_route/annotations.dart';

@RoutePage()
class CartPage extends StatefulWidget {
  static var page;

  const CartPage({super.key});
  @override
  State<CartPage> createState() => _CartState();
}

class _CartState extends State<CartPage> {
  List<dynamic> cartItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCartItems();
  }

  Future<void> fetchCartItems() async {
    final token = await AuthService.getToken();
    if (token == null) {
      print('Token is missing');
      setState(() => isLoading = false);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('https://api.store.astra-lombard.kz/api/v1/cart'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        final items = jsonBody['items'];

        setState(() {
          cartItems = items;
          isLoading = false;
        });
      } else {
        print('Ошибка: ${response.statusCode}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Exception: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> deleteCartItem(String productId) async {
    final token = await AuthService.getToken();
    if (token == null) {
      print('Token is missing');
      return;
    }

    try {
      final response = await http.delete(
        Uri.parse('https://api.store.astra-lombard.kz/api/v1/cart/$productId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        fetchCartItems();
      } else {
        print('Failed to delete item: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception while deleting: $e');
    }
  }

  int getTotalItems() => cartItems.length;

  int getTotalPrice() {
    return cartItems.fold(0, (sum, item) {
      final price = item['product']['priceWithDiscount'];

      if (price is int) {
        return sum + price;
      } else if (price is double) {
        return sum + price.toInt();
      } else if (price is String) {
        return sum + (int.tryParse(price) ?? 0);
      } else {
        return sum;
      }
    });
  }

  String formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]} ',
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalPrice = cartItems.fold(0.0, (sum, item) {
      final price = item['product']['priceWithDiscount'];
      return sum +
          (price is num
              ? price.toDouble()
              : double.tryParse(price.toString()) ?? 0.0);
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, toolbarHeight: 30),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : cartItems.isEmpty
          ? Center(
              child: Container(
                width: 500,
                height: 300,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_cart_outlined, size: 70),
                    SizedBox(height: 20),
                    Text(
                      'Ваша корзина пуста',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 26,
                      ),
                    ),
                    SizedBox(height: 17),
                    Text(
                      'Желаете приобрести ювелирные изделия?',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    Text(
                      'Посмотрите наши хиты продаж, загляните\nв товары со скидкой.',
                      style: TextStyle(color: Colors.grey.shade600),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/catalog'),
                      child: Container(
                        width: 300,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.orange),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            'Вернуться к покупкам',
                            style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(18),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final product = cartItems[index]['product'];
                      return Card(
                        color: Colors.grey.shade100,
                        margin: EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: Image.network(
                            product['imagePath'] ?? '',
                            height: 90,
                            width: 60,
                            fit: BoxFit.cover,
                          ),
                          title: Text(
                            product['localizedName'] ?? product['name'],
                          ),
                          trailing: GestureDetector(
                            onTap: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(
                                    'Вы уверены, что хотите удалить этот товар из корзины?',
                                  ),
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
                                final productId = product['id'];
                                await deleteCartItem(productId);
                              }
                            },
                            child: Icon(
                              Icons.delete_outline,
                              size: 24,
                              color: Colors.red,
                            ),
                          ),
                          subtitle: Text(
                            '${formatPrice((product['priceWithDiscount'] is num) ? product['priceWithDiscount'].toInt() : double.tryParse(product['priceWithDiscount'].toString())?.toInt() ?? 0)} ₸',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Товаров ${getTotalItems()}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'ИТОГО',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '${formatPrice(getTotalPrice())} ₸',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          minimumSize: Size(double.infinity, 50),
                        ),
                        onPressed: () {
                          // TODO: implement order logic
                        },
                        child: Text(
                          'Оформить заказ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}


// bottomNavigationBar: BottomNavigationBar(
//         currentIndex: 2,
//         selectedItemColor: Colors.orange,
//         unselectedItemColor: Colors.grey,
//         type: BottomNavigationBarType.fixed,
//         onTap: (index) {
//           switch (index) {
//             case 0:
//               Navigator.pushNamed(context, '/shop');
//               break;
//             case 1:
//               Navigator.pushNamed(context, '/catalog');
//               break;
//             case 2:
//               break;
//             case 3:
//               Navigator.pushNamed(context, '/liked');
//               break;
//             case 4:
//               Navigator.pushNamed(context, '/profile');
//               break;
//           }
//         },
//         items: [
//           BottomNavigationBarItem(
//   icon: Icon(Icons.storefront), // Магазин
//   label: 'Магазин',
// ),
// BottomNavigationBarItem(
//   icon: Icon(Icons.category), // Каталог
//   label: 'Каталог',
// ),
// BottomNavigationBarItem(
//   icon: Icon(Icons.shopping_cart), // Корзина
//   label: 'Корзина',
// ),
// BottomNavigationBarItem(
//   icon: Icon(Icons.favorite_border), // Избранное
//   label: 'Избранное',
// ),
// BottomNavigationBarItem(
//   icon: Icon(Icons.person), // Профиль
//   label: 'Профиль',
// ),

//         ],
//       ),