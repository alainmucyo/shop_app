import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/product.dart';
import 'package:shop_app/providers/products.dart';

class EditProductsScreen extends StatefulWidget {
  static const routeName = "/edit-product";

  @override
  _EditProductsScreenState createState() => _EditProductsScreenState();
}

class _EditProductsScreenState extends State<EditProductsScreen> {
  bool isLoading = false;
  String _imageUrl = "";
  var _formKey = GlobalKey<FormState>();
  bool _initState = true;
  bool _editMode = false;
  var _editedProduct =
      Product(id: null, title: "", description: "", imageUrl: "", price: 0.0);
  var _initialProduct =
      Product(id: null, title: "", description: "", imageUrl: "", price: 0.0);

  Future<void> _submitForm() async {
    setState(() {
      isLoading = true;
    });
    var isValid = _formKey.currentState.validate();
    if (!isValid) return;
    _formKey.currentState.save();
    try {
      if (_editMode) {
        _editedProduct.id = _initialProduct.id;
        _editedProduct.isFavorite = _initialProduct.isFavorite;
        await Provider.of<Products>(context, listen: false)
            .updateProduct(_editedProduct.id, _editedProduct);
      } else {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editedProduct);
      }
    }catch (err) {
      await showDialog(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              title: Text("Error occurred."),
              content: Text("Something went wrong"),
              actions: [
                FlatButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text("Okay"))
              ],
            );
          });
    } finally {
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pop();
    }
  }

  @override
  void didChangeDependencies() {
    if (!_initState) return;
    final _productId = ModalRoute.of(context).settings.arguments as String;
    if (_productId != null && _productId.trim().isNotEmpty) {
      _editMode = true;
      _initialProduct =
          Provider.of<Products>(context, listen: false).findById(_productId);
      _imageUrl = _initialProduct.imageUrl;
    }
    _initState = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editMode ? "Edit product" : "Add product"),
        actions: [IconButton(icon: Icon(Icons.save), onPressed: _submitForm)],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(10.0),
              child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      TextFormField(
                        initialValue: _initialProduct.title,
                        decoration: InputDecoration(labelText: "Title"),
                        textInputAction: TextInputAction.next,
                        onSaved: (value) {
                          _editedProduct.title = value;
                        },
                        validator: (value) {
                          if (value.isEmpty) return "Please, provide a value";
                          return null;
                        },
                      ),
                      TextFormField(
                        initialValue: _initialProduct.price.toString(),
                        decoration: InputDecoration(labelText: "Price"),
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        onSaved: (value) =>
                            _editedProduct.price = double.parse(value),
                        validator: (value) {
                          if (value.isEmpty) return "Please enter price";
                          if (double.tryParse(value) == null)
                            return "Please enter valid price";
                          if (double.parse(value) <= 0)
                            return "Price can't be less or equal to zero";
                          return null;
                        },
                      ),
                      TextFormField(
                        initialValue: _initialProduct.description,
                        decoration: InputDecoration(labelText: "Description"),
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.next,
                        maxLines: 3,
                        onSaved: (value) => _editedProduct.description = value,
                        validator: (value) {
                          if (value.isEmpty)
                            return "Please, provide description";
                          return null;
                        },
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 12, top: 10),
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(_imageUrl),
                              radius: 35,
                              child: _imageUrl.isEmpty
                                  ? FittedBox(
                                      child: Text(
                                        "Image",
                                        softWrap: true,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                          Expanded(
                            child: TextFormField(
                              initialValue: _initialProduct.imageUrl,
                              decoration:
                                  InputDecoration(labelText: "Image URL"),
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.done,
                              onChanged: (value) {
                                setState(() {
                                  _imageUrl = value;
                                });
                              },
                              validator: (value) {
                                if (value.isEmpty)
                                  return "Please, provide an image URL";
                                return null;
                              },
                              onSaved: (value) =>
                                  _editedProduct.imageUrl = value,
                            ),
                          )
                        ],
                      )
                    ],
                  ))),
    );
  }
}
