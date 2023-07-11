import 'dart:convert';

import 'package:flutter_sio/data/models/product.dart';

GetProducts getProductsFromJson(String str) =>
    GetProducts.fromJson(json.decode(str));

String getProductsToJson(GetProducts data) => json.encode(data.toJson());

class GetProducts {
  final List<Product> products;
  final int total;
  final int skip;
  final int limit;

  GetProducts({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
  });

  factory GetProducts.fromJson(Map<String, dynamic> json) => GetProducts(
        products: List<Product>.from(
            json["products"].map((x) => Product.fromJson(x))),
        total: json["total"],
        skip: json["skip"],
        limit: json["limit"],
      );

  Map<String, dynamic> toJson() => {
        "products": List<dynamic>.from(products.map((x) => x.toJson())),
        "total": total,
        "skip": skip,
        "limit": limit,
      };
}
