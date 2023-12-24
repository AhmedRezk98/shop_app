import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/cart_item.dart';
import '../models/order_item.dart';
class Orders with ChangeNotifier{
  List<OrderItem> _orders = [];
  final String? authToken;
  final String? userId;
  Orders(this.authToken,this.userId,this._orders);
  List<OrderItem> get orders{
    return [..._orders];
  }
  Future<void> fetchOrders() async{
    final  dynamic url = 'https://shop-project-2f3d1-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken';
    final response = await http.get(url);
    final extractedData = json.decode(response.body) as Map<String,dynamic>;
    List<OrderItem> loadedOrders = [];
    if(extractedData == null){
      return;
    }
    extractedData.forEach((orderId, orderData) {
      OrderItem(
        id: orderId,
        amount: orderData['amount'],
        dateTime: DateTime.parse(orderData['datetime']),
        products: (orderData['products'] as List<dynamic>).map((item)=>
          CartItem(
            id: item['id'],
            title: item['title'],
            quantity: item['quantity'],
            price: item['price'],
          )
        ).toList(),
      );
    });
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }
  Future<void> addOrder(List<CartItem> cartProds,double total) async {
    final  dynamic url = 'https://shop-project-2f3d1-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken';
    final response = await http.post(url,body: json.encode({
      'amount' : total,
      'datetime' : DateTime.now().toIso8601String(),
      'products' : cartProds.map((cp) => {
        'id' : cp.id,
        'title' : cp.title,
        'quantity' : cp.quantity,
        'price' : cp.price,
      }).toList(),
    }));
    _orders.insert(0, OrderItem(
      id: json.decode(response.body)['name'],
      amount: total,
      products: cartProds,
      dateTime: DateTime.now(),
    ));
    notifyListeners();
  }
}