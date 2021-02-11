import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/orders.dart';
import 'package:shop_app/widgets/app_drawer.dart';
import 'package:shop_app/widgets/order_item.widget.dart';

class OrdersScreen extends StatelessWidget {
  static const routeName = "/orders";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Your Orders")),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: Provider.of<Orders>(context, listen: false).fetchAndSave(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          else {
            if (snapshot.hasError)
              return Center(child: Text("Error occurred"));
            else {
              return RefreshIndicator(
                onRefresh: () async =>
                    await Provider.of<Orders>(context, listen: false)
                        .fetchAndSave(),
                child: Consumer<Orders>(builder: (ctx, orderData, child) {
                  return _OrderWidget(ordersData: orderData);
                }),
              );
            }
          }
        },
      ),
    );
  }
}

class _OrderWidget extends StatelessWidget {
  const _OrderWidget({
    Key key,
    @required this.ordersData,
  }) : super(key: key);

  final Orders ordersData;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return OrderItemWidget(
              key: ValueKey(ordersData.orders[index].id),
              order: ordersData.orders[index]);
        },
        itemCount: ordersData.orders.length,
      ),
    );
  }
}

/*
*/
