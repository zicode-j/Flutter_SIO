
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_sio/data/network/api_endpoint.dart';
import 'package:flutter_sio/data/models/product.dart';
import 'package:flutter_sio/data/responses/get_product.dart';
import 'package:flutter_sio/modules/home/widgets/product_card.dart';
import 'package:http/http.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  static const routeName = '/home-screen';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  
  //Skip kelipatan 10 berdasarkan https://dummyjson.com/products
  int skip = 0;
  String querySearch = '';
  List<Product> products = [];

  final RefreshController _refreshController =
      RefreshController(initialRefresh: true);
  final TextEditingController _inputSearch = TextEditingController();

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
        ApiEndpoint.products,
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
        ApiEndpoint.products,
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

  void _onSearch(String value) async {
    querySearch = value;

    await _refreshController.requestRefresh();
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        title: TextFormField(
          controller: _inputSearch,
          textInputAction: TextInputAction.search,
          onFieldSubmitted: _onSearch,
          decoration: const InputDecoration(
            hintText: 'Cari Produk',
            icon: Icon(Icons.search),
          ),
        ),
      ),
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