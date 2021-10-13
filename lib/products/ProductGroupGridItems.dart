import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:grocery/constrant.dart';
import 'package:grocery/home/BottomNavBar.dart';
import 'package:grocery/product/ProductCard.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class ProductGroupGridItems extends StatelessWidget {
  static final routeName = '/allProductByCategory';

  final String title;
  final String categoryId;

  Future<List<ProductCard>>? productFuture;

  ProductGroupGridItems({required this.title, required this.categoryId});

  factory ProductGroupGridItems.fromJson(Map<String, dynamic> json) {
    return new ProductGroupGridItems(
        title: json['category'], categoryId: json['id']);
  }

  Future<List<ProductCard>> fetchProduct() async {
    final response = await http
        .get(Uri.parse("$HTTPBASEURL/product/category/${this.categoryId}"));
    if (response.statusCode == 200) {
      List<dynamic> responseList = jsonDecode(response.body)['response'];
      List<ProductCard> productList = responseList
          .map((e) => ProductCard.fromJson(
                e,
                margin: kDefaultPadding / 4,
              ))
          .toList();
      return productList;
    } else {
      throw Exception("failed laod product by category");
    }
  }

  @override
  Widget build(BuildContext context) {
    productFuture = this.fetchProduct();
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          // LabelWithActionButton(
          //     title: this.title, actionButtonTitle: '', press: () {}),
          FutureBuilder<List<ProductCard>>(
            future: productFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return StaggeredGridView.countBuilder(
                  crossAxisCount: 2,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (BuildContext context, int index) =>
                      snapshot.data![index],
                  staggeredTileBuilder: (int index) => new StaggeredTile.fit(1),
                  mainAxisSpacing: kDefaultPadding / 2,
                  // crossAxisSpacing: kDefaultPadding,
                );
              }

              if (snapshot.hasError) {
                return Text("failed load product by category");
              }

              return Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
          BottomNavBar(active: ProductGroupGridItems.routeName)
        ],
      ),
    );
  }
}

class ProductGroupGridItemsArgs {
  final String title;
  final String categoryId;

  const ProductGroupGridItemsArgs(
      {required this.title, required this.categoryId});
}