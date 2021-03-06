import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/screens/cart_screen.dart';
import 'package:shop_app/widgets/app_drawer.dart';
import 'package:shop_app/widgets/badge.dart';
import 'package:shop_app/widgets/product_grid.dart';

enum MenuItems {
  Favorites,
  All,
}

class ProductOverviewScreen extends StatefulWidget {
  @override
  _ProductOverviewScreenState createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  bool isFav = false;
  bool _initState = true;
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    if (!_initState) return;
    setState(() {
      _isLoading = true;
    });
    Provider.of<Products>(context).fetchAndSet().then((_) {
      setState(() {
        _isLoading = false;
      });
    });
    _initState = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Shop App"),
        actions: [
          PopupMenuButton(
            icon: Icon(Icons.more_vert),
            onSelected: (MenuItems item) {
              setState(() {
                if (item == MenuItems.Favorites)
                  isFav = true;
                else
                  isFav = false;
              });
            },
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  child: Text("Favorites Only"),
                  value: MenuItems.Favorites,
                ),
                PopupMenuItem(
                  child: Text("Show All"),
                  value: MenuItems.All,
                ),
              ];
            },
          ),
          Consumer<Cart>(
            builder: (_, cart, widget) => Badge(
              child: widget,
              value: cart.itemsCount.toString(),
            ),
            child: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () =>
                  Navigator.of(context).pushNamed(CartScreen.routeName),
            ),
          )
        ],
      ),
      drawer: AppDrawer(),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async =>
                 await Provider.of<Products>(context, listen: false).fetchAndSet(),
              child: ProductsGrid(isFav),
            ),
    );
  }
}
