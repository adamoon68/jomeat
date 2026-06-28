import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config.dart';

class ApiService {
  static Uri _url(String endpoint) =>
      Uri.parse('${AppConfig.baseUrl}/$endpoint');

  static Map<String, dynamic> _connectionError(Object error) {
    return {
      'success': false,
      'message': 'Connection error. Check backend server and baseUrl. $error',
    };
  }

  static Future<Map<String, dynamic>> _post(
    String endpoint,
    Map<String, String> body,
  ) async {
    try {
      final response = await http.post(_url(endpoint), body: body);
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (error) {
      return _connectionError(error);
    }
  }

  static Future<Map<String, dynamic>> _multipartPost(
    String endpoint,
    Map<String, String> fields, {
    String? imagePath,
  }) async {
    try {
      final request = http.MultipartRequest('POST', _url(endpoint));
      request.fields.addAll(fields);
      if (imagePath != null && imagePath.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath('image', imagePath),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (error) {
      return _connectionError(error);
    }
  }

  static Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String password,
    required String role,
  }) {
    return _post('register.php', {
      'name': name,
      'email': email,
      'password': password,
      'role': role,
    });
  }

  static Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) {
    return _post('login.php', {'email': email, 'password': password});
  }

  static Future<Map<String, dynamic>> getMenu({String category = ''}) async {
    try {
      final response = await http.post(
        _url('get_menu.php'),
        body: {'category': category},
      );
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (error) {
      return _connectionError(error);
    }
  }

  static Future<Map<String, dynamic>> getFoodDetail(int foodId) {
    return _post('get_food_detail.php', {'food_id': foodId.toString()});
  }

  static Future<Map<String, dynamic>> addOrder({
    required int userId,
    required int foodId,
    required int quantity,
    required String notes,
  }) {
    return _post('add_order.php', {
      'user_id': userId.toString(),
      'food_id': foodId.toString(),
      'quantity': quantity.toString(),
      'notes': notes,
    });
  }

  static Future<Map<String, dynamic>> getOrders(int userId) {
    return _post('get_orders.php', {'user_id': userId.toString()});
  }

  static Future<Map<String, dynamic>> updateOrder({
    required int orderId,
    required int quantity,
    required String notes,
  }) {
    return _post('update_order.php', {
      'order_id': orderId.toString(),
      'quantity': quantity.toString(),
      'notes': notes,
    });
  }

  static Future<Map<String, dynamic>> cancelOrder(int orderId) {
    return _post('cancel_order.php', {'order_id': orderId.toString()});
  }

  static Future<Map<String, dynamic>> adminAddFood({
    required String name,
    required String description,
    required String category,
    required String price,
    required String preparationTime,
    required String availability,
    required String imagePath,
  }) {
    return _multipartPost('admin_add_food.php', {
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'preparation_time': preparationTime,
      'availability': availability,
    }, imagePath: imagePath);
  }

  static Future<Map<String, dynamic>> adminUpdateFood({
    required int foodId,
    required String name,
    required String description,
    required String category,
    required String price,
    required String preparationTime,
    required String availability,
    String? imagePath,
  }) {
    return _multipartPost('admin_update_food.php', {
      'food_id': foodId.toString(),
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'preparation_time': preparationTime,
      'availability': availability,
    }, imagePath: imagePath);
  }

  static Future<Map<String, dynamic>> adminDeleteFood(int foodId) {
    return _post('admin_delete_food.php', {'food_id': foodId.toString()});
  }
}
