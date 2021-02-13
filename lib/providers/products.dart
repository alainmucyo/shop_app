import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shop_app/models/http_exception.dart';
import 'package:shop_app/providers/product.dart';
import 'package:http/http.dart' as http;

class Products with ChangeNotifier {
  List<Product> _items = [];

  String _authToken;
  String _userId;

  void update(String authToken, String userId, List<Product> items) {
    this._authToken = authToken;
    this._items = items;
    this._userId = userId;
  }

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoritesItem {
    return _items.where((element) => element.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((element) => element.id == id);
  }

  Future<void> fetchAndSet() async {
    final url =
        "https://flutter-shop-ccd72-default-rtdb.firebaseio.com/products.json?auth=$_authToken";
    final favoriteUrl =
        "https://flutter-shop-ccd72-default-rtdb.firebaseio.com/userFavorites/$_userId.json?auth=$_authToken";
    List<Product> loadedProducts = [];
    try {
      final response = await http.get(url);
      final favoritesResp = await http.get(favoriteUrl);
      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
      final favoriteBody = jsonDecode(favoritesResp.body);
      responseBody.forEach((key, value) {
        loadedProducts.add(
          Product(
            id: key,
            title: value["title"],
            description: value['description'],
            imageUrl: value["imageUrl"],
            price: value["price"],
            isFavorite: favoriteBody[key] ?? false,
          ),
        );
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (err) {
      print(err);
      throw err;
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      final url =
          "https://flutter-shop-ccd72-default-rtdb.firebaseio.com/products.json?auth=$_authToken";
      var response = await http.post(url,
          body: json.encode({
            "title": product.title,
            "description": product.description,
            "price": product.price,
            "imageUrl": product.imageUrl
          }));
      var responseBody = jsonDecode(response.body);
      product.id = responseBody["name"];
      _items.add(product);
      notifyListeners();
    } catch (err) {
      print(err);
      throw err;
    }
  }

  Future<void> updateProduct(String productId, Product newProduct) async {
    final url =
        "https://flutter-shop-ccd72-default-rtdb.firebaseio.com/products/$productId.json?auth=$_authToken";
    try {
      await http.patch(
        url,
        body: json.encode({
          "title": newProduct.title,
          "description": newProduct.description,
          "price": newProduct.price,
          "imageUrl": newProduct.imageUrl
        }),
      );
      print("Update finished!");
      int productIndex =
          _items.indexWhere((element) => element.id == productId);
      _items[productIndex] = newProduct;
      notifyListeners();
    } catch (err) {
      print(err);
      throw err;
    }
  }

  Future<void> deleteProduct(String productId) async {
    final url =
        "https://flutter-shop-ccd72-default-rtdb.firebaseio.com/products/$productId.json?auth=$_authToken";
    int productIndex = _items.indexWhere((element) => element.id == productId);
    Product existingProduct = _items[productIndex];
    _items.removeAt(productIndex);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode > 400) {
      _items.insert(productIndex, existingProduct);
      notifyListeners();
      throw HttpException("Unable to delete product");
    } else {
      existingProduct = null;
    }
  }
}
