import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products.dart';

import 'product_item.dart';

class ProductsGrid extends StatelessWidget {
  final bool isFav;

  ProductsGrid(this.isFav);

  @override
  Widget build(BuildContext context) {
    final productData = Provider.of<Products>(context);
    final loadedProducts =
        isFav ? productData.favoritesItem : productData.items;
    return GridView.builder(
      // padding: const EdgeInsets.all(4),
      itemBuilder: (ctx, i) {
        return ChangeNotifierProvider.value(
          value: loadedProducts[i],
          child: ProductItem(),
        );
      },
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.7 / 2,
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
      ),
      itemCount: loadedProducts.length,
    );
  }
}
