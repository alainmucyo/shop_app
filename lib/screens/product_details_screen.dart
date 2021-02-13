import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/providers/products.dart';

class ProductDetailsScreen extends StatelessWidget {
  static const routeName = "/product-details";

  @override
  Widget build(BuildContext context) {
    final productId = (ModalRoute.of(context).settings.arguments as String);
    final product =
        Provider.of<Products>(context, listen: false).findById(productId);
    final cart = Provider.of<Cart>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text(product.title),
      ),
      body: Card(
        margin: EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              children: [
                Container(
                  height: 300,
                  width: double.infinity,
                  child: Hero(
                    tag: 'image-${product.id}',
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  '\$${product.price}',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(product.description, softWrap: true),
                SizedBox(height: 10),
                Builder(builder: (ctx) {
                  return FlatButton(
                    onPressed: () {
                      cart.addToCart(product.id, product.title, product.price);
                      Scaffold.of(ctx).hideCurrentSnackBar();
                      Scaffold.of(ctx).showSnackBar(
                        SnackBar(
                          content: Text("Product added to cart!"),
                          action: SnackBarAction(
                            onPressed: () => cart.removeProduct(product.id),
                            label: "UNDO",
                          ),
                        ),
                      );
                    },
                    child: Text("ADD TO CART",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    color: Theme.of(context).primaryColor,
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
