import 'package:flutter/material.dart';
import 'package:shop_app/screens/orders_screen.dart';

class AppDrawer extends StatelessWidget {
  Widget _menuItem(IconData icon, String title, Function tapedHandler) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title, style: TextStyle(fontSize: 20),),
      onTap: tapedHandler,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AppBar(
            title: Text("Hello Friend!"),
            automaticallyImplyLeading: false,
          ),
          SizedBox(height: 10),
          _menuItem(Icons.shop, "Shop",
              () => Navigator.of(context).pushReplacementNamed("/"),),
          Divider(),
          _menuItem(
            Icons.payment,
            "Orders",
            () => Navigator.of(context)
                .pushReplacementNamed(OrdersScreen.routeName),
          )
        ],
      ),
    );
  }
}
