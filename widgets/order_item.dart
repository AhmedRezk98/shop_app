import 'dart:math';
import 'package:flutter/material.dart';
import '../models/order_item.dart' as ord;
class OrderItem extends StatefulWidget {
  final ord.OrderItem order;
  const OrderItem({Key? key,required this.order}) : super(key: key);

  @override
  State<OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  var _expanded = false;
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _expanded ? min(widget.order.products.length * 20.0 + 110, 200) : 95,
      child: Card(
        margin: const EdgeInsets.all(10),
        child: Column(
          children: [
            ListTile(
              title: Text('\$${widget.order.amount}'),
              subtitle: Text(widget.order.dateTime.toIso8601String()),
              trailing: IconButton(
                icon: Icon(_expanded? Icons.expand_less : Icons.expand_more),
                onPressed: (){
                  setState((){
                    _expanded = !_expanded;
                  });
                },
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 4,
              ),
              height: _expanded ? min(widget.order.products.length * 20.0 + 10, 100) : 0,
              child: ListView(
                children: widget.order.products.map((prod)=>Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   Text(prod.title,style: const TextStyle(
                     fontWeight: FontWeight.bold,
                     fontSize: 18
                   ),),
                   Text('${prod.price} x \$${prod.quantity}',style: const TextStyle(
                     fontSize: 18,
                     color: Colors.grey,
                   ),),
                 ],
                )
                ).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
