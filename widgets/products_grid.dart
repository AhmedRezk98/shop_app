import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'product_item.dart';
import '../providers/products.dart';
class ProductsGrid extends StatelessWidget {
  final bool showFavs;
  const ProductsGrid({Key? key,required this.showFavs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    final loadedProducts = showFavs?productsData.favoriteItems:productsData.items;
    return GridView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: loadedProducts.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
        ),
        itemBuilder: (ctx, index) {
          return ChangeNotifierProvider.value(value : loadedProducts[index],
          child: const ProductItem());
        });
  }
}
