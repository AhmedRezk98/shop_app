import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products.dart';
import '../providers/product.dart';
class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';
  const EditProductScreen({Key? key}) : super(key: key);

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  var _editedProduct = Product(id: null, title: '', description: '', price: 0.0, imageUrl: '');
  final _form = GlobalKey<FormState>();

  bool _isInit = true;
  bool _isLoading = false;
  var _initValues = {
    'title' : '',
    'price' : '',
    'imageUrl' : '',
    'description' : '',
  };
  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }
  @override
  void didChangeDependencies() {
    if(_isInit){
      final prodId = ModalRoute.of(context)!.settings.arguments as String;
      if(prodId != null){
        _editedProduct = Provider.of<Products>(context,listen: false).findById(prodId);
        _initValues = {
          'title' : _editedProduct.title,
          'description' : _editedProduct.description,
          'imageUrl' : '',
          'price' : _editedProduct.price.toString(),
        };
        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }
  @override
  void dispose() {
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    super.dispose();
  }
  void _updateImageUrl(){
    if(!_imageUrlFocusNode.hasFocus){
      if((_imageUrlController.text.startsWith('http')&& _imageUrlController.text.startsWith('https'))||
          (_imageUrlController.text.endsWith('.jpg') && _imageUrlController.text.endsWith('jpeg') && _imageUrlController.text.endsWith('.png'))){
        return;
      }
      setState((){});
    }
  }
  Future<void> _saveForm() async {
    final ctx = Navigator.of(context);
    final isValid = _form.currentState!.validate();
    if(!isValid){
      return;
    }
  _form.currentState!.save();
    setState((){
      _isLoading = true;
    });
    if(_editedProduct.id != null) {
      await Provider.of<Products>(context).updateProduct(
          _editedProduct.id!, _editedProduct);}

    else {
      try{
     await Provider.of<Products>(context, listen: false).addProduct(_editedProduct);
      }catch(error){
       await showDialog(context: context, builder: (ctx) => AlertDialog(
          title: const Text('an error occured'),
          content: const Text('something went wrong'),
          actions: [
            TextButton(
              onPressed: (){
                Navigator.of(ctx).pop();
              },
              child: const Text('Okay'),
            )
          ],
        ));
      }
      /*finally{
        setState((){
          _isLoading = false;
        });
        Navigator.of(context).pop();
      }*/

    }
    setState((){
      _isLoading = false;
    });
    ctx.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveForm,
          )
        ],
      ),
      body: _isLoading? const Center(
        child: CircularProgressIndicator(),
      ) : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _form,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _initValues['title'],
                decoration: const InputDecoration(labelText: 'Title',),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_){
                  FocusScope.of(context).requestFocus(_priceFocusNode);
                },
                onSaved: (value){
                  _editedProduct = Product(
                    id: _editedProduct.id,
                    title: value!,
                    price: _editedProduct.price,
                    description: _editedProduct.description,
                    imageUrl: _editedProduct.imageUrl,
                    isFavorite: _editedProduct.isFavorite,
                  );
                },
                validator: (value){
                  if(value!.isEmpty){
                    return 'Please Enter the title';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: _initValues['price'],
                decoration: const InputDecoration(labelText: 'Price',),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                focusNode: _priceFocusNode,
                  onFieldSubmitted: (_){
                    FocusScope.of(context).requestFocus(_descriptionFocusNode);
                  },
                onSaved: (value){
                  _editedProduct = Product(
                      id: _editedProduct.id,
                      title: _editedProduct.title,
                      price: double.parse(value!),
                      description: _editedProduct.description,
                      imageUrl: _editedProduct.imageUrl,
                    isFavorite: _editedProduct.isFavorite,
                  );
                },
                validator: (value){
                  if(value!.isEmpty){
                    return 'Please Enter The Price';
                  }
                  if(double.tryParse(value) == null){
                    return 'Please Enter a Valid Number';
                  }
                  if(double.parse(value) <= 0){
                    return 'Please Enter value greater than zero';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: _initValues['description'],
                decoration: const InputDecoration(labelText: 'Description',),
                keyboardType: TextInputType.multiline,
                maxLines: 3,
                focusNode: _descriptionFocusNode,
                onSaved: (value){
                  _editedProduct = Product(
                      id: _editedProduct.id,
                      title: _editedProduct.title,
                      price: _editedProduct.price,
                      description: value!,
                      imageUrl: _editedProduct.imageUrl,
                    isFavorite: _editedProduct.isFavorite,
                  );
                },
                validator: (value){
                  if(value!.isEmpty){
                    return 'Please Enter the Description';
                  }
                  if(value.length < 10){
                    return 'description should be at least 10 characters';
                  }
                  return null;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    height: 100,
                    width: 100,
                    margin: const EdgeInsets.only(top: 8,right: 10,),
                    decoration: BoxDecoration(
                      border: Border.all(width: 1,color: Colors.grey),
                    ),
                    child: _imageUrlController.text.isEmpty? const Text('Enter a Url') : 
                    FittedBox(child: Image.network(_imageUrlController.text,fit: BoxFit.cover,),),
                  ),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Image URL',
                      ),
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.done,
                      controller: _imageUrlController,
                      focusNode: _imageUrlFocusNode,
                      onFieldSubmitted: (_){_saveForm();},
                      onSaved: (value){
                        _editedProduct = Product(
                            id: _editedProduct.id,
                            title: _editedProduct.title,
                            price: _editedProduct.price,
                            description: _editedProduct.description,
                            imageUrl: value!,
                            isFavorite: _editedProduct.isFavorite,
                        );
                      },
                      validator: (value){
                        if(value!.isEmpty){
                          return 'Please Enter an Image';
                        }
                        if(!value.startsWith('http')|| !value.startsWith('https')){
                          return 'please enter a valid image url';
                        }
                        if(!value.endsWith('.jpg')|| !value.endsWith('jpeg') || !value.endsWith('.png')){
                          return 'please enter a valid image url';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
