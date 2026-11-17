// Repository Code
import 'dart:convert';
import 'package:flutter_bloc_auth_profile/models/products.model.dart';
import 'package:http/http.dart' as http;
//import 'package:tutorial/models/products.model.dart';

class ProductRepository {
  final String apiUrl = "https://fakestoreapi.com/products";

  Future<List<Product>> getItems() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Product.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load data');
    }
  }
}