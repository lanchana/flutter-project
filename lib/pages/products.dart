import 'package:flutter/material.dart';

import '../widgets/product/products.dart';
import '../models/product.dart';

import '../scoped-models/main.dart';
import 'package:scoped_model/scoped_model.dart';
import '../widgets/ui_elemente/logout_list_tile.dart';

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
          ),
          LogoutListTile(),
        ],
      ),
    );
  }

  Widget _buildProduct() {
    bool _ref = false;
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        Widget content = Center(
          child: Text('No Products Found!'),
        );
        if (model.displayedProduct.length > 0 && !model.isLoading) {
          content = Products();
        } else if (model.isLoading && !_ref) {
          content = Center(
            child: CircularProgressIndicator(),
          );
        }
        return RefreshIndicator(
            onRefresh:() {
              _ref = true;
              model.fetchProducts().then((_) {
              print('done');
            });},
            
            child: content);
      },
    );

    // return Products();
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
      body: _buildProduct(),
    );
  }
}
