import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static String? _token;

  // Set token and save to local storage
  static Future<void> setToken(String newToken) async {
    _token = newToken;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', newToken);
    print('Token saved: $newToken');
  }

  // Get token (load from storage if not in memory)
  static Future<String?> getToken() async {
    if (_token != null) return _token;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    print('Token loaded from storage: $_token');
    return _token;
  }

  // Save login credentials
  static Future<void> saveCredentials(String phone, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('phone', phone);
    await prefs.setString('password', password);
  }

  static Future<Map<String, String>?> getSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString('phone');
    final password = prefs.getString('password');
    if (phone != null && password != null) {
      return {'phone': phone, 'password': password};
    }
    return null;
  }

  static Future<void> clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('phone');
    await prefs.remove('password');
    await prefs.remove('token');
    _token = null;
  }

  static Future<void> logout() async {
    await clearCredentials();
    _token = null;
    print('Logged out, token and credentials cleared');
  }

  static Future<List<dynamic>> fetchFavourites() async {
    final token = await getToken();
    final dio = Dio();

    try {
      final response = await dio.post(
        'https://api.store.astra-lombard.kz/api/v1/favourites/search',
        data: {"pageSize": 1000, "pageNumber": 1, "orderBy": []},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      final data = response.data["data"] as List;
      print(" Received favourites: ${data.length}");

      // return only product list
      return data.map((e) => e["product"]).toList();
    } catch (e) {
      print("Error fetching favourites: $e");
      throw e;
    }
  }

  // Like/Unlike toggle
  Future<void> toggleFavourite(
    String productId, {
    bool isCurrentlyLiked = false,
  }) async {
    final token = await getToken();
    if (token == null || token.isEmpty || productId.isEmpty) {
      print('product ID is null,cannot dleete');
      return;
    }

    final url = Uri.parse(
      'https://api.store.astra-lombard.kz/api/v1/favourites',
    );
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    try {
      final response = isCurrentlyLiked
          ? await http.delete(
              url.replace(queryParameters: {'productId': productId}),
              headers: headers,
            )
          : await http.post(
              url,
              headers: headers,
              body: jsonEncode({'productId': productId}),
            );

      if (![200, 201, 204].contains(response.statusCode)) {
        print(
          'Failed to toggle favourite: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      print('Error toggling favourite: $e');
    }
  }

  Future<void> removeFavourite(String productId) async {
    await toggleFavourite(productId, isCurrentlyLiked: true);
  }

  // Phone verification logic
  Future<void> verifyPhoneNumber({
    required String phone,
    required Function(String verificationId) codeSent,
    required Function(String error) onError,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (e) {
          onError(e.message ?? 'Verification failed');
        },
        codeSent: (verificationId, resendToken) {
          codeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (_) {},
      );
    } catch (e) {
      onError(e.toString());
    }
  }

  // Sign in with SMS code
  Future<User?> signInWithSmsCode(String verificationId, String smsCode) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      return null;
    }
  }

  // Validate password from Firestore
  Future<bool> checkPassword({
    required String phone,
    required String enteredPassword,
  }) async {
    final query = await _firestore
        .collection('users')
        .where('phone', isEqualTo: phone)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return false;

    final data = query.docs.first.data();
    return data['password'] == enteredPassword;
  }

  // Full login process
  Future<void> login({
    required String phone,
    required String password,
    required Function(String verificationId) onCodeSent,
    required Function(String errorMessage) onError,
  }) async {
    final passwordOk = await checkPassword(
      phone: phone,
      enteredPassword: password,
    );
    if (!passwordOk) {
      onError('Incorrect phone number or password');
      return;
    }

    await saveCredentials(phone, password);
    await verifyPhoneNumber(
      phone: phone,
      codeSent: onCodeSent,
      onError: onError,
    );
  }
}

class LikedStorage {
  static const _key = 'liked_products';

  // Like product (save to local storage)
  static Future<void> likeProduct(Map<String, dynamic> product) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    List<dynamic> list = raw != null ? jsonDecode(raw) : [];

    // Prevent duplicates
    final exists = list.any((item) => item['id'] == product['id']);
    if (!exists) {
      list.add(product);
      await prefs.setString(_key, jsonEncode(list));
      print('Product liked: ${product['name']}');
    }
  }

  // Unlike product
  static Future<void> unlikeProduct(String productId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return;

    List<dynamic> list = jsonDecode(raw);

    list.removeWhere((item) => item['id'] == productId);

    await prefs.setString(_key, jsonEncode(list));
    print('Product unliked: $productId');
  }

  // Get liked products
  static Future<List<Map<String, dynamic>>> getLikedProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];

    final List<dynamic> decoded = jsonDecode(raw);
    return decoded.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  // Check if a product is liked
  static Future<bool> isLiked(String productId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return false;

    final List<dynamic> list = jsonDecode(raw);
    return list.any((item) => item['id'] == productId);
  }
}
