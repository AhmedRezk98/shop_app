import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart';
import '../widgets/cart_item.dart';
import '../providers/orders.dart';
class CartScreen extends StatelessWidget {
  static const routeName = '/cart';
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(15),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total',style: TextStyle(fontSize: 20),),
                  const Spacer(),
                  Chip(label: Text('\$${cart.totalAmount.toStringAsFixed(2)}',style: TextStyle(
                    color: Theme.of(context).primaryTextTheme.titleLarge!.color,
                  ),),
                  backgroundColor: Theme.of(context).primaryColor,
                  ),

                ],
              ),
            ),
          ),
          const SizedBox(height: 10,),
          Expanded(
            child: ListView.builder(
              itemCount: cart.itemCount,
              itemBuilder: (ctx,i)=>CartItem(
                id: cart.items.values.toList()[i].id,
                prodId: cart.items.keys.toList()[i],
                title: cart.items.values.toList()[i].title,
                price: cart.items.values.toList()[i].price,
                quantity: cart.items.values.toList()[i].quantity,
              ),
            ),
          ),
          OrderButton(cart: cart),
        ],
      ),
    );
  }
}
class OrderButton extends StatefulWidget {
  final Cart cart;
  const OrderButton({Key? key,required this.cart}) : super(key: key);

  @override
  State<OrderButton> createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return TextButton(onPressed: (widget.cart.totalAmount <= 0 || _isLoading) ? null : ()async{
      setState((){
        _isLoading = true;
      });
      await Provider.of<Orders>(context,listen: false).addOrder(widget.cart.items.values.toList(), widget.cart.totalAmount);
      widget.cart.clear();
      setState((){
        _isLoading = true;
      });
    },
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all<Color>(Theme.of(context).primaryColor),
      ),
      child:_isLoading?const CircularProgressIndicator() :  const Text('Order Now'),
    );
  }
}

