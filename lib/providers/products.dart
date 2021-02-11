import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shop_app/models/http_exception.dart';
import 'package:shop_app/providers/product.dart';
import 'package:http/http.dart' as http;

class Products with ChangeNotifier {
  List<Product> _items = [
    /*Product(
      id: 'p1',
      title: 'Red Shirt',
      description: 'A red shirt - it is pretty red!',
      price: 29.99,
      imageUrl:
          'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    ),
    Product(
      id: 'p2',
      title: 'Trousers',
      description: 'A nice pair of trousers.',
      price: 59.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    ),
    Product(
      id: 'p3',
      title: 'Yellow Scarf',
      description: 'Warm and cozy - exactly what you need for the winter.',
      price: 19.99,
      imageUrl:
          'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    ),
    Product(
      id: 'p4',
      title: 'A Pan',
      description: 'Prepare any meal you want.',
      price: 49.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    ),*/
  ];

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
    const URL =
        "https://flutter-shop-ccd72-default-rtdb.firebaseio.com/products.json";
    List<Product> loadedProducts = [];
    try {
      final response = await http.get(URL);
      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
      responseBody.forEach((key, value) {
        loadedProducts.add(
          Product(
            id: key,
            title: value["title"],
            description: value['description'],
            imageUrl: value["imageUrl"],
            price: value["price"],
            isFavorite: value["isFavorite"],
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
      const URL =
          "https://flutter-shop-ccd72-default-rtdb.firebaseio.com/products.json";
      var response = await http.post(URL,
          body: json.encode({
            "title": product.title,
            "description": product.description,
            "isFavorite": product.isFavorite,
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
        "https://flutter-shop-ccd72-default-rtdb.firebaseio.com/products/$productId.json";
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
        "https://flutter-shop-ccd72-default-rtdb.firebaseio.com/products/$productId.json";
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
