import 'package:flutter/material.dart';
import './price_tag.dart';
import './address_tag.dart';
import '../ui_elemente/title_default.dart';
import 'package:scoped_model/scoped_model.dart';
import '../../scoped-models/main.dart';
import '../../models/product.dart';

class ProductCard extends StatelessWidget {
  final int index;

  final Product product;

  ProductCard(this.product, this.index);

  Widget _buildActionsButton(BuildContext context) {
    return ButtonBar(
      alignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () {
            Navigator.pushNamed<bool>(context, '/product/' + index.toString());
          },
          icon: Icon(
            Icons.info,
            color: Theme.of(context).primaryColor,
          ),
        ),
        ScopedModelDescendant<MainModel>(
          builder: (BuildContext context, Widget child, MainModel model) {
            return IconButton(
              icon: Icon(
                model.getProductList[index].isFavorite ? Icons.favorite : Icons.favorite_border,
                color: Colors.redAccent,
              ),
              onPressed: () {
                model.selectProduct(index);
                model.toggleSelectedProductFavorite();
                //  Navigator.pushNamed<bool>(
                //     context, '/product/' + index.toString());
              },
            );
          },
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          Image.network(product.imageUrl),
          Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TitleDefault(product.title),
                  SizedBox(
                    width: 10.0,
                  ),
                  PriceTag('\$' + product.price.toString()),
                ],
              )),
          AddressTag('Ponce city market, Atlanta'),
          Text(product.userEmail),
          _buildActionsButton(context),
        ],
      ),
      margin: EdgeInsets.all(15.0),
    );
  }
}
