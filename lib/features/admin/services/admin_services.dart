import 'dart:convert';
import 'dart:io';

import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ecommerce_application/constants/error_handling.dart';
import 'package:flutter_ecommerce_application/constants/global_variables.dart';
import 'package:flutter_ecommerce_application/constants/utils.dart';
import 'package:flutter_ecommerce_application/features/admin/models/sales.dart';
import 'package:flutter_ecommerce_application/models/order.dart';
import 'package:flutter_ecommerce_application/models/product.dart';
import 'package:flutter_ecommerce_application/providers/user_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class AdminServices {
//selling posts{
  void sellProduct({
    required BuildContext context,
    required String name,
    required String description,
    required double price,
    required double quantity,
    required String category,
    required List<File> images,
  }) async {
    void snackbar(String e) => showSnackBar(context, e);
    void httpErrorHandling(http.Response res, VoidCallback success) {
      httpErrorHandle(response: res, context: context, onSuccess: success);
    }

    final userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );

    try {
      final cloudinary = CloudinaryPublic('dwcvvya4t', 'onhiwhjs');
      List<String> imageUrls = [];

      for (int i = 0; i < images.length; i++) {
        CloudinaryResponse res = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(images[i].path, folder: name),
        );
        imageUrls.add(res.secureUrl);
      }

      Product product = Product(
        name: name,
        description: description,
        quantity: quantity,
        images: imageUrls,
        category: category,
        price: price,
      );

      http.Response res = await http.post(
        Uri.parse('$uri/admin/add-product'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
        body: product.toJson(),
      );

      httpErrorHandling(
        res,
        () {
          showSnackBar(context, 'Product Added Successfully!');
          Navigator.pop(context);
        },
      );
    } catch (e) {
      snackbar(e.toString());
    }
  }

//getting all posts
  Future<List<Product>> getAllProducts(
    BuildContext context,
  ) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    void snackbar(String e) => showSnackBar(context, e);
    void httpErrorHandling(http.Response res, VoidCallback success) {
      httpErrorHandle(response: res, context: context, onSuccess: success);
    }

    List<Product> products = [];

    try {
      final res = await http.get(
        Uri.parse('$uri/admin/get-posts'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': userProvider.user.token,
        },
      );

      httpErrorHandling(res, () {
        for (int i = 0; i < jsonDecode(res.body).length; i++) {
          products.add(
            Product.fromJson(
              jsonEncode(jsonDecode(res.body)[i]),
            ),
          );
        }
      });
    } catch (e) {
      snackbar(e.toString());
    }
    return products;
  }

//delete product
  void deleteProduct(
    BuildContext context,
    Product product,
    VoidCallback onSuccess,
  ) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    void snackbar(String e) => showSnackBar(context, e);
    void httpErrorHandling(
      http.Response res,
      VoidCallback success,
    ) {
      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: success,
      );
    }

    try {
      final res = await http.post(Uri.parse('$uri/admin/delete-post'),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'x-auth-token': userProvider.user.token,
          },
          body: jsonEncode({
            'id': product.id,
          }));
      httpErrorHandling(res, onSuccess);
    } catch (e) {
      snackbar(e.toString());
    }
  }

  // void deleteProduct({
  //   required BuildContext context,
  //   required Product product,
  //   required VoidCallback onSuccess,
  // }) async {
  //   final userProvider = Provider.of<UserProvider>(context, listen: false);
  //   void httpErrorHandling(
  //     http.Response res,
  //     VoidCallback onSuccess,
  //   ) {
  //     httpErrorHandle(
  //       response: res,
  //       context: context,
  //       onSuccess: onSuccess,
  //     );
  //   }

  //   void snackBar(String text) {
  //     showSnackBar(context, text);
  //   }

  //   try {
  //     http.Response res = await http.post(
  //       Uri.parse('$uri/admin/delete-product'),
  //       headers: {
  //         'Content-Type': 'application/json; charset=UTF-8',
  //         'x-auth-token': userProvider.user.token,
  //       },
  //       body: jsonEncode({
  //         'id': product.id,
  //       }),
  //     );

  //     httpErrorHandling(res, onSuccess);
  //   } catch (e) {
  //     snackBar(e.toString());
  //   }
  // }

  // Future<List<Order>> fetchAllOrders(BuildContext context) async {
  //   final userProvider = Provider.of<UserProvider>(context, listen: false);
  //   List<Order> orderList = [];
  //   void httpErrorHandling(
  //     http.Response res,
  //     VoidCallback onSuccess,
  //   ) {
  //     httpErrorHandle(
  //       response: res,
  //       context: context,
  //       onSuccess: onSuccess,
  //     );
  //   }

  //   void snackBar(String text) {
  //     showSnackBar(context, text);
  //   }

  //   try {
  //     http.Response res =
  //         await http.get(Uri.parse('$uri/admin/get-orders'), headers: {
  //       'Content-Type': 'application/json; charset=UTF-8',
  //       'x-auth-token': userProvider.user.token,
  //     });

  //     httpErrorHandling(res, () {
  //       for (int i = 0; i < jsonDecode(res.body).length; i++) {
  //         orderList.add(
  //           Order.fromJson(
  //             jsonEncode(
  //               jsonDecode(res.body)[i],
  //             ),
  //           ),
  //         );
  //       }
  //     });
  //   } catch (e) {
  //     snackBar(e.toString());
  //   }
  //   return orderList;
  // }

  // void changeOrderStatus({
  //   required BuildContext context,
  //   required int status,
  //   required Order order,
  //   required VoidCallback onSuccess,
  // }) async {
  //   final userProvider = Provider.of<UserProvider>(context, listen: false);
  //   void httpErrorHandling(
  //     http.Response res,
  //     VoidCallback onSuccess,
  //   ) {
  //     httpErrorHandle(
  //       response: res,
  //       context: context,
  //       onSuccess: onSuccess,
  //     );
  //   }

  //   void snackBar(String text) {
  //     showSnackBar(context, text);
  //   }

  //   try {
  //     http.Response res = await http.post(
  //       Uri.parse('$uri/admin/change-order-status'),
  //       headers: {
  //         'Content-Type': 'application/json; charset=UTF-8',
  //         'x-auth-token': userProvider.user.token,
  //       },
  //       body: jsonEncode({
  //         'id': order.id,
  //         'status': status,
  //       }),
  //     );

  //     httpErrorHandling(res, onSuccess);
  //   } catch (e) {
  //     snackBar(e.toString());
  //   }
  // }

  // Future<Map<String, dynamic>> getEarnings(BuildContext context) async {
  //   final userProvider = Provider.of<UserProvider>(context, listen: false);
  //   List<Sales> sales = [];
  //   int totalEarning = 0;

  //   void httpErrorHandling(
  //     http.Response res,
  //     VoidCallback onSuccess,
  //   ) {
  //     httpErrorHandle(
  //       response: res,
  //       context: context,
  //       onSuccess: onSuccess,
  //     );
  //   }

  //   void snackBar(String text) {
  //     showSnackBar(context, text);
  //   }

  //   try {
  //     http.Response res =
  //         await http.get(Uri.parse('$uri/admin/analytics'), headers: {
  //       'Content-Type': 'application/json; charset=UTF-8',
  //       'x-auth-token': userProvider.user.token,
  //     });

  //     httpErrorHandling(res, () {
  //       var response = jsonDecode(res.body);
  //       totalEarning = response['totalEarnings'];
  //       sales = [
  //         Sales('Mobiles', response['mobileEarnings']),
  //         Sales('Essentials', response['essentialEarnings']),
  //         Sales('Books', response['booksEarnings']),
  //         Sales('Appliances', response['applianceEarnings']),
  //         Sales('Fashion', response['fashionEarnings']),
  //       ];
  //     });
  //   } catch (e) {
  //     snackBar(e.toString());
  //   }
  //   return {
  //     'sales': sales,
  //     'totalEarnings': totalEarning,
  //   };
  // }
}
