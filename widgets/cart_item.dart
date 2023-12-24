import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart';
class CartItem extends StatelessWidget {
  final String id;
  final String prodId;
  final String title;
  final int quantity;
  final double price;
  const CartItem({Key? key,required this.id,required this.prodId,required this.title,required this.quantity,required this.price}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(id),
      background: Container(
        color: Theme.of(context).errorColor,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 4,
        ),
        child: const Icon(Icons.delete,color: Colors.white,size: 40),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (dir){
        return showDialog(context: context, builder: (ctx) => AlertDialog(
          title: const Text('Are You Sure?'),
          content: const Text('do you want to remove the item from the cart'),
          actions: [
            TextButton(onPressed: (){
              Navigator.of(ctx).pop(false);
            },
                child: const Text('YES')),
            TextButton(onPressed: (){
              Navigator.of(ctx).pop(true);
            },
                child: const Text('NO')),
          ],
        ),);
      },
      onDismissed: (dir){
        Provider.of<Cart>(context,listen: false).removeItem(prodId);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 4,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: ListTile(
            leading: CircleAvatar(
              child: FittedBox(
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Text('\$$price'),
                ),
              ),
            ),
            title: Text(title),
            subtitle: Text('\$${price * quantity}'),
            trailing: Text('$quantity x'),
          ),
        ),
      ),
    );
  }
}
