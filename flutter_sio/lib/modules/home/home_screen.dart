import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

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
        controller: _refreshController,
        enablePullUp: true,
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