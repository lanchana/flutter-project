import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';
import './product_card.dart';
import '../../scoped-models/main.dart';

class Products extends StatelessWidget {
  Widget _buildProductList(productList) {
    Widget returnProductList;
    if (productList.length > 0) {
      returnProductList = ListView.builder(
          itemBuilder: (BuildContext context, int index) =>
              ProductCard(productList[index], index),
          itemCount: productList.length);
    } else {
      returnProductList = Center(
        child: Text(
          'No images, please add some.',
          style: new TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
        ),
      );
    }
    return returnProductList;
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) =>
            _buildProductList(model.displayedProduct));
  }
}
