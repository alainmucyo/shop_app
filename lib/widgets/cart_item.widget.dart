import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/cart.dart';

class CartItemWidget extends StatelessWidget {
  final String id;
  final String title;
  final double price;
  final int quantity;
  final String productId;

  const CartItemWidget(
      {Key key, this.id, this.title, this.price, this.quantity, this.productId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context, listen: false);
    return Dismissible(
      key: ValueKey(id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) {
        return showDialog(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              title: Text("Are you sure?"),
              content: Text("Do you want to remove item from cart?"),
              actions: [
                FlatButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      "No",
                      style: TextStyle(color: Colors.grey[800]),
                    )),
                FlatButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text("Yes")),
              ],
            );
          },
        );
      },
      onDismissed: (_) => cart.removeToCart(productId),
      background: Container(
        padding: EdgeInsets.only(right: 15),
        child: Icon(
          Icons.delete,
          size: 40,
          color: Colors.white,
        ),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Theme.of(context).errorColor,
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              radius: 23,
              child: FittedBox(child: Text('\$$price')),
            ),
            title: Text(title),
            subtitle: Text("Total: \$${price * quantity}"),
            trailing: Text('$quantity x'),
          ),
        ),
      ),
    );
  }
}
