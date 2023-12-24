import 'package:flutter/material.dart';
import '../models/cart_item.dart';
class Cart with ChangeNotifier{
  Map<String,CartItem> _items = {};
  Map<String,CartItem> get items{
    return {..._items};
  }
  void addItem(String productId,double price,String title){
    if (_items.containsKey(productId)){
      _items.update(productId, (value) => CartItem(
        id: value.id,
        title: value.title,
        price: value.price,
        quantity: value.quantity + 1,
      ));
    }
    else{
      _items.putIfAbsent(productId, () => CartItem(
        id: DateTime.now().toString(),
        title: title,
        price: price,
        quantity: 1
      ));
    }
    notifyListeners();
  }
  void clear(){
    _items = {};
    notifyListeners();
  }
  int get itemCount{
    return _items.length;
  }
  double get totalAmount{
    double total = 0.0;
    _items.forEach((key, value) {
      total+= value.price * value.quantity;
    });
    return total;
  }
  void removeItem(String prodId){
    _items.remove(prodId);
    notifyListeners();
  }
  void removeSingleItem(String prodId){
    if(!_items.containsKey(prodId)){
      return;
    }
    else if (_items[prodId]!.quantity > 1){
      _items.update(prodId, (value) => CartItem(id: value.id, title: value.title, price: value.price, quantity: value.quantity - 1));
    }
    else {
      _items.remove(prodId);
    }
    notifyListeners();
  }
}