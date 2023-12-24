import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/products_grid.dart';
import '../widgets/badge.dart';
import '../providers/cart.dart';
import './cart_screen.dart';
import '../widgets/app_drawer.dart';
import '../providers/products.dart';
enum FilterOptions{
  favorites,
  all,
}
class ProductsOverviewScreen extends StatefulWidget {
  const ProductsOverviewScreen({Key? key}) : super(key: key);

  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var _showFavorites = false;
  bool _isInit = true;
  bool _isLoading = false;
  @override
  void didChangeDependencies() {
    if(_isInit){
      setState((){
        _isLoading = true;
      });
      Provider.of<Products>(context).fetchProducts().then((_){
        setState((){
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Shop'),
        actions: [
          PopupMenuButton(
            itemBuilder: (_) => [
              const PopupMenuItem(value: FilterOptions.favorites,child: Text('Only Favorites'),),
              const PopupMenuItem(value: FilterOptions.all,child: Text('show All products'),),
            ],
            onSelected: (FilterOptions selectedValue){
              setState((){
                if(selectedValue == FilterOptions.favorites){
                  _showFavorites = true;
                }
                else{
                  _showFavorites = false;
                }
              });
            },
            icon: const Icon(Icons.more_vert),
          ),
          Consumer<Cart>(builder: (_,cart,child)=>MyBadge(
            value: cart.itemCount.toString(),
            child: child!,
          ),
          child: IconButton(icon: const Icon(Icons.shopping_cart),onPressed: (){
            Navigator.of(context).pushNamed(CartScreen.routeName);
          },),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: _isLoading?const Center(
        child: CircularProgressIndicator(),
      ):ProductsGrid(showFavs: _showFavorites,),
    );
  }
}
