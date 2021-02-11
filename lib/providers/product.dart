import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exception.dart';

class Product with ChangeNotifier {
  String id;
  String title;
  String description;
  String imageUrl;
  double price;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.imageUrl,
    @required this.price,
    this.isFavorite = false,
  });

  Future<void> toggleFavorite() async {
    final url =
        "https://flutter-shop-ccd72-default-rtdb.firebaseio.com/products/${this.id}.json";

    this.isFavorite = !this.isFavorite;
    notifyListeners();
    try {
      final response = await http.patch(url,
          body: jsonEncode({"isFavorite": this.isFavorite}));
      if (response.statusCode > 400) {
        this.isFavorite = !this.isFavorite;
        notifyListeners();
        throw HttpException("Unable to change favorite.");
      }
    } catch (err) {
      throw err;
    }
  }
}
