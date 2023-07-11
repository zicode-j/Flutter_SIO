
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:http/http.dart' as http;

import '../../data/network/api_endpoint.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home-screen';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  
  //Skip kelipatan 10 berdasarkan https://dummyjson.com/products
  int skip = 0;

  final RefreshController _refreshController =
      RefreshController(initialRefresh: true);
  final TextEditingController _inputSearch = TextEditingController();

  void _onRefresh() async {
    skip = 0;

    Map<String, String> queryParameters = {
      'q': '',
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
        log(response.body);

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
        child: ListView.builder(
          itemCount: 10,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text('Item ke $index'),
            );
          },
        ),
      ),
    );
  }

  
}