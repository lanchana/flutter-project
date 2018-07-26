import 'package:flutter/material.dart';

import '../widgets/helpers/ensure-visible.dart';
import '../models/product.dart';

import 'package:scoped_model/scoped_model.dart';
import '../scoped-models/main.dart';

class EditProducts extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _EditProductsState();
  }
}

class _EditProductsState extends State<EditProducts> {
  Map<String, dynamic> _formData = {
    'title': null,
    'description': null,
    'price': null,
    'imageUrl': 'food.jpg'
  };

  final _titleFocusNode = FocusNode();
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // @override
  // void initState() {
  //   super.initState();
  // }

  Widget _buildTitleTextField(Product editProduct) {
    return EnsureVisibleWhenFocused(
      focusNode: _titleFocusNode,
      child: TextFormField(
        focusNode: _titleFocusNode,
        decoration: InputDecoration(labelText: 'Product Title'),
        initialValue: editProduct == null ? '' : editProduct.title,
        validator: (String value) {
          print(value);
          if (value.isEmpty) {
            return 'Title is required';
          }
        },
        onSaved: (String value) {
          _formData['title'] = value;
        },
      ),
    );
  }

  Widget _buildDescriptionTextField(Product editProduct) {
    return EnsureVisibleWhenFocused(
      focusNode: _descriptionFocusNode,
      child: TextFormField(
        focusNode: _descriptionFocusNode,
        maxLines: 5,
        decoration: InputDecoration(labelText: 'Product description'),
        initialValue: editProduct == null ? '' : editProduct.description,
        validator: (String value) {
          if (value.isEmpty || value.length < 10) {
            return 'Description is required and should be 10+ characters long.';
          }
        },
        onSaved: (String value) {
          _formData['description'] = value;
        },
      ),
    );
  }

  Widget _buildPriceTextField(Product editProduct) {
    return EnsureVisibleWhenFocused(
      focusNode: _priceFocusNode,
      child: TextFormField(
        focusNode: _priceFocusNode,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: 'Product Price'),
        initialValue: editProduct == null ? '' : editProduct.price.toString(),
        validator: (String value) {
          if (value.isEmpty ||
              !RegExp(r'^[1-9]([0-9]{1,2})?(\.[1-9])?$').hasMatch(value)) {
            return 'Price is required and should be a number';
          }
        },
        onSaved: (String value) {
          _formData['price'] =
              double.parse(value.replaceFirst(RegExp(r','), '.'));
        },
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return model.isLoading
            ? Center(child: CircularProgressIndicator())
            : RaisedButton(
                child: Text(
                  'Save',
                  style: TextStyle(color: Colors.white, fontSize: 20.0),
                ),
                onPressed: () {
                  _submitForm(model.addProduct, model.updateProduct,
                      model.selectedProduct, model.selectedProductIndex);
                },
              );
      },
    );
  }

  Widget _buildPageContent(BuildContext context, Product editProduct) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.95;
    final double targetPadding = deviceWidth - targetWidth;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Container(
        margin: EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: targetPadding / 2),
            children: <Widget>[
              _buildTitleTextField(editProduct),
              _buildDescriptionTextField(editProduct),
              _buildPriceTextField(editProduct),
              Container(
                margin: EdgeInsets.only(top: 10.0),
                child: _buildSubmitButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm(
      Function addProduct, Function updateProduct, setSelectedProduct,
      [int selectedProductIndex]) {
    print(selectedProductIndex);
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
    if (selectedProductIndex == -1) {
      addProduct(_formData['title'], _formData['description'],
          _formData['imageUrl'], _formData['price']).then((success) {
        if (success) {
          Navigator
              .pushNamed(context, '/products')
              .then((_) => setSelectedProduct(null));
        } else {
          showDialog(context: context, builder: (BuildContext context){
            return AlertDialog(
              title: Text('Something went wrong!'),
              content: Text('Do want to try again?'),
              actions: <Widget>[
                FlatButton(
                  child: Text('Try again'),
                  onPressed: () => Navigator.of(context).pop(),
                )
              ],
            );
          });
        }
      });
    } else {
      updateProduct(_formData['title'], _formData['description'],
              _formData['imageUrl'], _formData['price'])
          .then((_) => Navigator
              .pushNamed(context, '/products')
              .then((_) => setSelectedProduct(null)));
    }

    // Navigator
    //     .pushNamed(context, '/products')
    //     .then((_) => setSelectedProduct(null));
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        // edit
        final Widget _pageContent =
            _buildPageContent(context, model.selectedProduct);
        return model.selectedProductIndex == -1
            ? _pageContent
            : Scaffold(
                appBar: AppBar(
                  title: Text('Edit Product'),
                ),
                body: _pageContent,
              );
      },
    );
  }
}
