import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:http/http.dart' as http;

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _items = [];
  String _authToken;

  void update(String authToken, List<OrderItem> items) {
    this._authToken = authToken;
    this._items = items;
  }

  List<OrderItem> get orders {
    return [..._items];
  }

  Future<void> fetchAndSave() async {
    final url =
        "https://flutter-shop-ccd72-default-rtdb.firebaseio.com/orders.json?auth=$_authToken";
    final resp = await http.get(url);
    final ordersData = jsonDecode(resp.body) as Map<String, dynamic>;
    if (ordersData == null) return;
    List<OrderItem> loadedOrders = [];

    ordersData.forEach((key, value) {
      loadedOrders.add(
        OrderItem(
          id: key,
          amount: value["amount"],
          dateTime: DateTime.parse(value["datetime"]),
          products: (value["products"] as List<dynamic>).map((e) {
            return CartItem(
              id: e["id"],
              title: e["title"],
              quantity: e["quantity"],
              price: e["price"],
            );
          }).toList(),
        ),
      );
    });
    _items = loadedOrders.reversed.toList();
  }

  Future<void> addOrder(double amount, List<CartItem> products) async {
    final url =
        "https://flutter-shop-ccd72-default-rtdb.firebaseio.com/orders.json?auth=$_authToken";
    final datetime = DateTime.now().toIso8601String();
    await http.post(
      url,
      body: jsonEncode({
        "amount": amount,
        "datetime": datetime,
        "products": products.map((p) {
          return {
            "id": p.id,
            "price": p.price,
            "quantity": p.quantity,
            "title": p.title
          };
        }).toList()
      }),
    );
    _items.insert(
      0,
      OrderItem(
        id: DateTime.now().toString(),
        amount: amount,
        products: products,
        dateTime: DateTime.now(),
      ),
    );
    notifyListeners();
  }
}
