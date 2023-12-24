import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/orders.dart';
import '../widgets/app_drawer.dart';
import '../widgets/order_item.dart';
class OrderScreen extends StatelessWidget {
  static const routeName = '/orders';
  const OrderScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Orders'),
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder(
        future: Provider.of<Orders>(context,listen: false).fetchOrders(),
        builder: (ctx,dataSnapshot) {
          if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(),);
          }
          else if (dataSnapshot.error != null) {
            return const Center(
              child: Text('an error occured'),
            );
          }
          else {
            return Consumer<Orders>(builder: (ctx,orderData,child)=>
              ListView.builder(
                itemCount: orderData.orders.length,
                itemBuilder: (ctx, i) => OrderItem(order: orderData.orders[i]),
              )
            );
          }
        })
    );
  }
}
