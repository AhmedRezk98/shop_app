import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
class Product with ChangeNotifier{
  final String? id;
  final String title;
  final String description;
  final String imageUrl;
  final double price;
  bool isFavorite;
  Product({required this.id,required this.title,required this.description,required this.price,this.isFavorite = false,required this.imageUrl});
  void _setFavValue(bool newValue){
    isFavorite = newValue;
    notifyListeners();
  }
  Future<void> toggleFavoriteStatus(String token,String userId) async{
    final dynamic url = 'https://shop-project-2f3d1-default-rtdb.firebaseio.com/userFavorites/$userId/$id.json?auth=$token';
    final oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    try{
      final response = await http.put(url,body: json.encode(isFavorite,));
      if(response.statusCode >= 400){
        _setFavValue(oldStatus);
      }
    }
    catch (error){
      _setFavValue(oldStatus);
    }
  }
}