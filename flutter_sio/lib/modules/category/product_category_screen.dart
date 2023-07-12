import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_sio/data/models/product.dart';
import 'package:flutter_sio/data/network/api_endpoint.dart';
import 'package:flutter_sio/data/responses/get_products.dart';
import 'package:flutter_sio/modules/home/widgets/product_card.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ProductCategoryScreen extends StatefulWidget {
  static const routeName = '/product-category-screen';

  const ProductCategoryScreen({super.key});

  @override
  State<ProductCategoryScreen> createState() => _ProductCategoryScreenState();
}

class _ProductCategoryScreenState extends State<ProductCategoryScreen> {
  String category = '';
  int skip = 0;
  String querySearch = '';
  List<Product> products = [];

  final RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  void _onRefresh() async {
    skip = 0;

    Map<String, String> queryParameters = {
      'q': querySearch,
      'limit': '10',
      'skip': skip.toString(),
    };

    try {
      Uri uri = Uri.https(
        ApiEndpoint.baseUrl,
        ApiEndpoint.productOfCategories(category),
        queryParameters,
      );

      Response response = await http.get(uri);

      if (response.statusCode == 200) {
        // convert to json
        final responseJson = json.decode(response.body);

        // convert to model
        final result = GetProducts.fromJson(responseJson);

        // update list
        setState(() {
          products = result.products;
        });

        _refreshController.refreshCompleted();
      } else {
        log(response.body);

        _refreshController.refreshFailed();
      }
    } catch (e) {
      log(e.toString(), name: 'ERROR FETCH DATA');

      _refreshController.refreshFailed();
    }
  }

  void _onLoading() async {
    skip += 10;

    Map<String, String> queryParameters = {
      'q': querySearch,
      'limit': '10',
      'skip': skip.toString(),
    };

    try {
      Uri uri = Uri.https(
        ApiEndpoint.baseUrl,
        ApiEndpoint.productOfCategories(category),
        queryParameters,
      );

      Response response = await http.get(uri);

      if (response.statusCode == 200) {
        // convert to json
        final responseJson = json.decode(response.body);

        // convert to model
        final result = GetProducts.fromJson(responseJson);

        if (result.products.isEmpty) {
          _refreshController.loadNoData();
        } else {
          // update list
          setState(() {
            products.addAll(result.products);
          });

          _refreshController.loadComplete();
        }
      } else {
        log(response.body);

        _refreshController.loadFailed();
      }
    } catch (e) {
      log(e.toString(), name: 'ERROR FETCH DATA');

      _refreshController.loadFailed();
    }
  }

  initialLoad() async {
    await Future.delayed(const Duration(milliseconds: 200));

    _refreshController.requestRefresh();
  }

  @override
  void initState() {
    super.initState();

    initialLoad();
  }

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    category = arguments['category'] ?? '';

    return Scaffold(
      appBar: AppBar(title: Text(category)),
      body: SmartRefresher(
        enablePullUp: true,
        controller: _refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: GridView.builder(
          itemCount: products.length,
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            childAspectRatio: 3 / 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
            Product product = products[index];

            return ProductCard(
              title: product.title,
              price: product.price,
              rating: product.rating,
              discountPercentage: product.discountPercentage,
              stock: product.stock,
              brand: product.brand,
              thumbnail: product.thumbnail,
            );
          },
        ),
      ),
    );
  }
}
