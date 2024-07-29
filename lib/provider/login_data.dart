import 'dart:convert';

import 'package:cartasiapp/core/api_client.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginData with ChangeNotifier, DiagnosticableTreeMixin {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late List<Map<String, dynamic>> _userData = [];
  List<Map<String, dynamic>> get getUserData => _userData;

  Future setUserInfo(String token) async {
    final SharedPreferences prefs = await _prefs;

    ApiClient apiClient = ApiClient();
    _userData = await apiClient.userInfo(token);
    // Add token to each map in the list
    for (var user in _userData) {
      user['token'] = token;
    }

    // print("provider $_userData");
    String userDataString = jsonEncode(_userData);

    prefs.setString("userData", userDataString.toString());
    notifyListeners();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('userData', json.encode(_userData)));
  }
}
