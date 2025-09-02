import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class LikedStorage {
  static const _key = 'liked_products';

  static Future<void> likeProduct(Map<String, dynamic> product) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    List<dynamic> list = raw != null ? jsonDecode(raw) : [];

    final exists = list.any((item) => item['id'] == product['id']);
    if (!exists) {
      list.add(product);
      await prefs.setString(_key, jsonEncode(list));
    }
  }

  static Future<void> unlikeProduct(String productId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return;

    List<dynamic> list = jsonDecode(raw);
    list.removeWhere((item) => item['id'] == productId);

    await prefs.setString(_key, jsonEncode(list));
  }

  static Future<bool> isLiked(String productId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return false;

    final List<dynamic> list = jsonDecode(raw);
    return list.any((item) => item['id'] == productId);
  }

  static Future<List<Map<String, dynamic>>> getLikedProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];

    final List<dynamic> decoded = jsonDecode(raw);
    return decoded.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  static Future<void> loadFavouritesFromServer() async {
    final token = await AuthService.getToken();
    if (token == null || token.isEmpty) return;

    final response = await http.get(
      Uri.parse('https://api.store.astra-lombard.kz/api/v1/favourites'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List items = data['items'] ?? [];

      List<Map<String, dynamic>> products = [];
      for (var item in items) {
        final product = item['product'];
        if (product != null) {
          products.add(Map<String, dynamic>.from(product));
        }
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, jsonEncode(products));
      print('Favourites loaded from server: ${products.length} items');
    } else {
      print('Failed to load favourites from server: ${response.statusCode}');
    }
  }

  static Future<void> clearLiked() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
