import 'dart:async';

import 'package:flutter/material.dart';

import '../widgets/ui_elemente/title_default.dart';
import 'package:scoped_model/scoped_model.dart';
import '../scoped-models/main.dart';
import '../models/product.dart';

class ProductPage extends StatelessWidget {
  final int index;

  ProductPage(this.index);

  Widget _buildProductTitlteAndPriceRow(BuildContext context, title, price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TitleDefault(title),
        Container(
            margin: EdgeInsets.symmetric(horizontal: 10.0),
            child: Text(
              '|',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 26.0,
              ),
            )),
        Padding(
          padding: EdgeInsets.only(top: 4.0),
          child: Text(
            '\$' + price.toString(),
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: 20.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductAddress() {
    return Container(
      padding: EdgeInsets.only(top: 10.0),
      child: Text('Ponce city market, Atlanta'),
    );
  }

  Widget _buildProductDescription(description) {
    return Container(
      margin: EdgeInsets.all(10.0),
      child: Text(
        description,
        softWrap: true,
        textAlign: TextAlign.justify,
        style: TextStyle(
          fontSize: 20.0,
        ),
      ),
    );
  }

  BoxDecoration _borderBottom() {
    return BoxDecoration(
      border: Border(
        bottom: BorderSide(width: 1.0, color: Colors.teal),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, false);
        return Future.value(false);
      },
      child: ScopedModelDescendant<MainModel>(builder: (BuildContext context, Widget child, MainModel model){
        Product product = model.getProductList[index];

        return Scaffold(
        appBar: AppBar(
          title: Text(product.title),
        ),
        body: Center(
          child: Column(children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
              child: Image.asset(
                'assets/' + product.imageUrl,
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            Container(
              decoration: _borderBottom(),
              padding: EdgeInsets.only(bottom: 10.0),
              child: _buildProductTitlteAndPriceRow(context, product.title, product.price),
            ),
            _buildProductAddress(),
            _buildProductDescription(product.description),
          ]),
        ),
      );
      },),
       
    );
  }
}
