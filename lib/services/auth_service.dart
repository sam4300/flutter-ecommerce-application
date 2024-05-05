import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ecommerce_application/constants/error_handling.dart';
import 'package:flutter_ecommerce_application/constants/global_variables.dart';
import 'package:flutter_ecommerce_application/constants/utils.dart';
import 'package:flutter_ecommerce_application/features/home/screens/home_screen.dart';
import 'package:flutter_ecommerce_application/models/user.dart';
import 'package:flutter_ecommerce_application/providers/user_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  void signUpUser({
    required BuildContext context,
    required String email,
    required String password,
    required String name,
  }) async {
    void snackBar(String text) {
      showSnackBar(context, text);
    }

    void httpErrorHandling(
      http.Response res,
    ) {
      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          snackBar('Account created! Login with the same credentials!');
        },
      );
    }

    try {
      User user = User(
        id: '',
        name: name,
        password: password,
        email: email,
        address: '',
        type: '',
        token: '',
      );

      http.Response res = await http.post(
        Uri.parse('$uri/api/signup'),
        body: user.toJson(),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      httpErrorHandling(res);
    } catch (e) {
      snackBar(e.toString());
    }
  }

  void signInUser({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    void snackBar(String text) {
      showSnackBar(context, text);
    }

    void httpErrorHandling(
      http.Response res,
      VoidCallback onSuccess,
    ) {
      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: onSuccess,
      );
    }

    final navigator = Navigator.of(context);

    try {
      final res = await http.post(
        Uri.parse('$uri/api/signin'),
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      httpErrorHandling(res, () async {
        final prefs = await SharedPreferences.getInstance();
        if (!context.mounted) return;
        Provider.of<UserProvider>(context, listen: false).setUser(res.body);
        await prefs.setString('x-auth-token', jsonDecode(res.body)['token']);
        navigator.pushNamedAndRemoveUntil(
            HomeScreen.routeName, (route) => false);
      });
    } catch (e) {
      snackBar(e.toString());
    }
  }
}
