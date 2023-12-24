import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'product.dart';
import '../models/http_exception.dart';
class Products with ChangeNotifier{
  List<Product> _items = [
    /*Product(id: 's1', title: 'shirt', description: 'a yellow shirt', price: 20.95, imageUrl: 'gh'),
    Product(id: 's2', title: 't-shirt', description: 'a red t-shirt', price: 25.5, imageUrl: 'ss'),
    Product(id: 's3', title: 'skirt', description: 'a nice skirt', price: 20.95, imageUrl: 'bb'),
    Product(id: 's4', title: 'jacket', description: 'a blue jacket', price: 28.9, imageUrl: 'nn'),*/
  ];
  final String? authToken;
  final String? userId;
  Products(this.authToken,this.userId,this._items);
  List<Product> get items{

      return [..._items];
  }
  List<Product> get favoriteItems{
    return [..._items].where((element) => element.isFavorite).toList();
  }
Product findById(String id){
    return _items.firstWhere((prod)=> prod.id == id);
}
Future<void> addProduct(Product product) async {
    final dynamic url = 'https://shop-project-2f3d1-default-rtdb.firebaseio.com/products.json?auth=$authToken';
    try {
      final response = await http.post(url, body: json.encode({
        'title': product.title,
        'description': product.description,
        'imageUrl': product.imageUrl,
        'price': product.price,
        'creatorId' : userId,
      }));
      final newProduct = Product(
        id: json.decode(response.body)['name'],
        title: product.title,
        price: product.price,
        description: product.description,
        imageUrl: product.imageUrl,
      );
      _items.add(newProduct);
      notifyListeners();
    }
      catch(error){
        rethrow;
      }
    }
Future<void> fetchProducts([bool filterByUser = false]) async{
    final filterString = filterByUser? 'orderBy = "creatorId"&equalTo = $userId' : '';
  dynamic url = 'https://shop-project-2f3d1-default-rtdb.firebaseio.com/products.json?token=$authToken&$filterString';
  try{
    final response = await http.get(url);
    final extractedData = json.decode(response.body) as Map<String,dynamic>;
    if(extractedData == null){
      return;
    }
    url = 'https://shop-project-2f3d1-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$authToken';
    final favoriteResponse = await http.get(url);
    final favoriteData = json.decode(favoriteResponse.body);
    final List<Product> loadedProducts = [];
    extractedData.forEach((prodId, prodData) {
      loadedProducts.add(Product(
        id: prodId,
        title: prodData['title'],
        imageUrl: prodData['imageUrl'],
        description: prodData['description'],
        price: prodData['price'],
        isFavorite: favoriteData == null? false : favoriteData[prodId]??false,
      ));
    });
    _items = loadedProducts;
    notifyListeners();
  }
  catch(error){
    rethrow;
  }
}

Future<void> updateProduct(String id,Product newProduct) async {
    final prodIndex = _items.indexWhere((element) => element.id == id);
    if(prodIndex >= 0){
      final dynamic url = 'https://shop-project-2f3d1-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken';
      try {
        await http.patch(url,body: json.encode({
          'title' : newProduct.title,
          'description' : newProduct.description,
          'imageUrl' : newProduct.imageUrl,
          'price' : newProduct.price,
        }));
        _items[prodIndex] = newProduct;
        notifyListeners();
      }
      catch (error){
        rethrow;
      }
    }
}
Future<void> deleteProduct(String id) async {
  final dynamic url = 'https://shop-project-2f3d1-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken';
  final existingProductIndex = _items.indexWhere((element) => element.id == id);
  dynamic existingProduct = _items[existingProductIndex];
  _items.removeAt(existingProductIndex);
  notifyListeners();
   final response = await http.delete(url);
      if(response.statusCode >=400){
        _items.insert(existingProductIndex, existingProduct);
        notifyListeners();
        throw HttpException('could not delete product');
      }
      existingProduct = null;
    }
}
