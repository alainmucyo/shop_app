import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/auth.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/providers/product.dart';
import 'package:shop_app/screens/product_details_screen.dart';

class ProductItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context);
    final cart = Provider.of<Cart>(context, listen: false);
    final scaffold = Scaffold.of(context);
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: GridTile(
          child: InkWell(
            onTap: () => Navigator.of(context).pushNamed(
              ProductDetailsScreen.routeName,
              arguments: product.id,
            ),
            child: Hero(
              tag: 'image-${product.id}',
              child: FadeInImage(
                placeholder: AssetImage("assets/images/product-placeholder.png"),
                image: NetworkImage(product.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          footer: GridTileBar(
            backgroundColor: Colors.black87,
            leading: IconButton(
              icon: Icon(
                product.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: Theme.of(context).accentColor,
              ),
              onPressed: () async {
                try {
                  final authData =
                      Provider.of<AuthProvider>(context, listen: false);
                  await product.toggleFavorite(authData.token, authData.userId);
                } catch (err) {
                  scaffold
                      .showSnackBar(SnackBar(content: Text(err.toString())));
                }
              },
            ),
            title: Text(
              product.title,
              textAlign: TextAlign.center,
            ),
            trailing: IconButton(
                icon: Icon(
                  Icons.shopping_cart,
                  color: Theme.of(context).accentColor,
                ),
                onPressed: () {
                  cart.addToCart(product.id, product.title, product.price);
                  Scaffold.of(context).hideCurrentSnackBar();
                  Scaffold.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Product added to cart!"),
                      action: SnackBarAction(
                        onPressed: () => cart.removeProduct(product.id),
                        label: "UNDO",
                      ),
                    ),
                  );
                }),
          ),
        ),
      ),
    );
  }
}
