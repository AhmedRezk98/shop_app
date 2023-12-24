import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
class Auth with ChangeNotifier{
  String? _token;
  DateTime? _expiryDate;
  String? _userId;
  Timer? _timer;
  bool get isAuth{
    return token != null;
  }
  String? get token{
    if(_expiryDate != null && _expiryDate!.isAfter(DateTime.now()) && _token != null){
      return _token;
    }
    return null;
  }
  String get userId{
    return _userId!;
  }
  Future<void> _authenticate(String? email,String? password,String? urlSegment)async{
    final dynamic url = 'https://www.googleapis.com/identitytoolkit/v3/relyingparty/$urlSegment?key=2hfjfjkgk';
    try{
      final response = await http.post(url,body:json.encode({
        'email' : email,
        'password' : password,
        'returnSecureToken' : true,
      }));
      final responseData = json.decode(response.body);
      if(responseData['error'] != null){
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(Duration(seconds: int.parse(responseData['expiresIn'])));
      _autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token' : _token,
        'userId' : _userId,
        'expiryDate' : _expiryDate!.toIso8601String(),
      });
      prefs.setString('userData', userData);
    }
    catch (error){
      rethrow;
    }
  }
  Future<void> signup(String? email,String? password)async{
    return _authenticate(email, password, 'signupNewUser');
  }
  Future<void> login(String? email,String? password)async{
    return _authenticate(email, password, 'verifyPassword');
  }
  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if(_timer != null){
      _timer!.cancel();
      _timer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    //prefs.remove('userData');
    prefs.clear();
  }
  void _autoLogout(){
    if(_timer != null){
      _timer!.cancel();
    }
    final timeToExpiry = _expiryDate!.difference(DateTime.now()).inSeconds;
    Timer(Duration(seconds: timeToExpiry),logout);
}
Future<bool> tryAutoLogin() async{
    final prefs = await SharedPreferences.getInstance();
    if(!prefs.containsKey('userData')){
      return false;
    }
    final extractedData = json.decode(prefs.getString('userData')!) as Map<String,dynamic>;
    final expiryDate = DateTime.parse(extractedData['expiryDate']);
    if(expiryDate.isBefore(DateTime.now())){
      return false;
    }
    _token = extractedData['token'];
    _userId = extractedData['userId'];
    _expiryDate = expiryDate;
    notifyListeners();
    _autoLogout();
    return true;
}
}