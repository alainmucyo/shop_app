import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app/models/http_exception.dart';

class AuthProvider with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;

  bool get isAuth {
    return token != null;
  }

  String get token {
    if (_token != null &&
        _userId != null &&
        _expiryDate != null &&
        _expiryDate.isAfter(DateTime.now())) {
      return _token;
    }
    return null;
  }

  String get userId {
    return _userId;
  }

  Future<void> _authenticate(
      String email, String password, String authType) async {
    final url =
        "https://identitytoolkit.googleapis.com/v1/accounts:$authType?key=AIzaSyDP3tBINRzRJOYLI0g6lDrkExctmMTKT58";
    try {
      final res = await http.post(
        url,
        body: jsonEncode(
            {"email": email, "password": password, "returnSecureToken": true}),
      );
      final responseData = jsonDecode(res.body);
      if (responseData["error"] != null)
        return HttpException("Invalid credentials");
      _token = responseData["idToken"];
      _userId = responseData["localId"];
      _expiryDate = DateTime.now()
          .add(Duration(seconds: int.parse(responseData["expiresIn"])));
      _autoLogout();
      final prefs = await SharedPreferences.getInstance();
      final authData = jsonEncode({
        "token": token,
        "userId": _userId,
        "expiryDate": _expiryDate.toIso8601String(),
      });
      prefs.setString("authData", authData);
      notifyListeners();
    } catch (err) {
      print(err);
      throw err;
    }
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, "signUp");
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, "signInWithPassword");
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.remove("authData");
    prefs.clear();

  }

  void _autoLogout() {
    if (_authTimer != null) _authTimer.cancel();

    final expiryTime = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: expiryTime), logout);
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey("authData")) return false;
    final extractedData =
        jsonDecode(prefs.getString("authData")) as Map<String, dynamic>;
    final expiryDate = DateTime.parse(extractedData["expiryDate"]);
    if (expiryDate.isBefore(DateTime.now())) return false;

    _expiryDate = expiryDate;
    _token = extractedData["token"];
    _userId = extractedData["userId"];
    notifyListeners();
    _autoLogout();
    return true;
  }
}
