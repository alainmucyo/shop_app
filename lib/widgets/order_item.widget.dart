import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shop_app/providers/orders.dart';

class OrderItemWidget extends StatefulWidget {
  final OrderItem order;

  const OrderItemWidget({Key key, this.order}) : super(key: key);

  @override
  _OrderItemWidgetState createState() => _OrderItemWidgetState();
}

class _OrderItemWidgetState extends State<OrderItemWidget> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            key: widget.key,
            title: Text('\$${widget.order.amount}'),
            subtitle: Text(DateFormat.yMMMd().format(widget.order.dateTime)),
            trailing: IconButton(
              icon: Icon(_expanded?Icons.expand_less:Icons.expand_more),
              onPressed: () {
                setState(() {
                  _expanded = !_expanded;
                });
              },
            ),
          ),
          //
          if(_expanded)
          Container(
            height: min(widget.order.products.length * 20.0 + 10, 180),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
            child: ListView(
              children: [
                ...widget.order.products.map((e) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 3),
                    child: Row(
                      children: [
                        Text(e.title,
                            style: TextStyle(color: Colors.grey[700])),
                        Spacer(),
                        Text(
                          '${e.quantity} x \$${e.price}',
                          style: TextStyle(color: Colors.grey[500]),
                        )
                      ],
                    ),
                  );
                }).toList()
              ],
            ),
          )
        ],
      ),
    );
  }
}
