import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './screens/products_overview_screen.dart';
import './screens/product_detail_screen.dart';
import './providers/products.dart';
import './providers/cart.dart';
import './screens/cart_screen.dart';
import './providers/orders.dart';
import './screens/order_screen.dart';
import './screens/user_products_screen.dart';
import './screens/edit_product_screen.dart';
import './screens/auth_screen.dart';
import './providers/auth.dart';
import './helpers/custom_route.dart';
import 'screens/splash_screen.dart';
void main() => runApp(const MyApp());
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider.value(
        value: Auth(),
      ),
      ChangeNotifierProxyProvider<Auth,Products>(
        //builder: (ctx,auth,prevProds) => Products(auth.token, prevProds.items==null?[]:prevProds.items),
        create: (_) => Products(null,null,[]),
        update: (ctx,auth,previousProducts) => Products(auth.token,auth.userId,previousProducts == null?[] : previousProducts.items),
      ),
      ChangeNotifierProvider.value(
        value: Cart(),),
      ChangeNotifierProxyProvider<Auth,Orders>(
        create: (_) => Orders(null,null,[]),
        update: (ctx,auth,previousOrders) => Orders(auth.token,auth.userId,previousOrders == null?[] : previousOrders.orders),
      ),
    ],
      child: Consumer<Auth>(builder: (ctx,auth,_)=>
          MaterialApp(
            title: 'My Shop',
            theme: ThemeData(
              pageTransitionsTheme: PageTransitionsTheme(
                builders: {
                  TargetPlatform.iOS : CustomPageTransitionBuilder(),
                  TargetPlatform.android : CustomPageTransitionBuilder(),
                }),
              fontFamily: 'OpenSans',
              colorScheme: ColorScheme.fromSwatch(
                primarySwatch: Colors.blue,
                accentColor: Colors.deepOrange,
              ),
            ),
            home: auth.isAuth? const ProductsOverviewScreen() : FutureBuilder(
              future: auth.tryAutoLogin(),
              builder: (ctx,authResult)=>authResult.connectionState == ConnectionState.waiting? const SplashScreen(): const AuthScreen(),
            ),
            routes: {
              ProductDetailScreen.routeName : (ctx) => const ProductDetailScreen(),
              CartScreen.routeName : (ctx) => const CartScreen(),
              OrderScreen.routeName : (ctx) => const OrderScreen(),
              UserProductsScreen.routeName : (ctx) => const UserProductsScreen(),
              EditProductScreen.routeName : (ctx) => const EditProductScreen(),
            },
          ),
        )
    );
  }
}


