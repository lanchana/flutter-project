import 'package:flutter/material.dart';

import '../widgets/product/products.dart';
import '../models/product.dart';

import '../scoped-models/main.dart';
import 'package:scoped_model/scoped_model.dart';

class ProductsPage extends StatefulWidget {
  final MainModel model;

  ProductsPage(this.model);

  @override
  State<StatefulWidget> createState() {
    return _ProductsPageState();
  }
}

class _ProductsPageState extends State<ProductsPage> {
  Widget _buildSideDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AppBar(
            automaticallyImplyLeading: false,
            title: Text('Choose'),
          ),
          ListTile(
            leading: Icon(Icons.create),
            title: Text('Product Manager'),
            onTap: () {
              // Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/admin');
            },
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    widget.model.fetchProducts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildSideDrawer(context),
      appBar: AppBar(
        title: Text('EasyList'),
        actions: <Widget>[
          ScopedModelDescendant<MainModel>(
            builder: (BuildContext context, Widget child, MainModel model) {
              return IconButton(
                icon: Icon(
                  Icons.favorite,
                  color: model.displayFavorites ? Colors.red : Colors.white,
                ),
                onPressed: () {
                  model.toggleShowFavorite();
                },
              );
            },
          )
        ],
      ),
      body: Products(),
    );
  }
}
