import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/product.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/screens/edit_products_screen.dart';

class UserProductItem extends StatelessWidget {
  final Product product;

  const UserProductItem({Key key, this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold.of(context);
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(product.imageUrl),
      ),
      title: Text(product.title),
      trailing: Container(
        width: 100,
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).pushNamed(
                  EditProductsScreen.routeName,
                  arguments: product.id),
              icon: Icon(
                Icons.edit,
                color: Theme.of(context).primaryColor,
              ),
            ),
            IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (ctx) {
                      return AlertDialog(
                        title: Text("Are you sure?"),
                        content: Text("Delete this product?"),
                        actions: [
                          FlatButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(
                                "No",
                                style: TextStyle(color: Colors.black),
                              )),
                          FlatButton(
                            onPressed: () async {
                              Navigator.of(context).pop();
                              try {
                                await Provider.of<Products>(context,
                                        listen: false)
                                    .deleteProduct(product.id);
                              } catch (er) {
                                scaffold.showSnackBar(
                                  SnackBar(
                                    content: Text("Delete failed!"),
                                  ),
                                );
                              }
                            },
                            child: Text("Yes"),
                          ),
                        ],
                      );
                    });
              },
              icon: Icon(
                Icons.delete,
                color: Theme.of(context).errorColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
