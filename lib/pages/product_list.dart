import 'package:flutter/material.dart';

import './edit_product.dart';

import '../widgets/ui_elemente/alertBox.dart';

import 'package:scoped_model/scoped_model.dart';
import '../scoped-models/main.dart';

class ProductList extends StatefulWidget {
  final MainModel model;

  ProductList(this.model);

  @override
  State<StatefulWidget> createState() {
    return _ProductsListState();
  }
}

class _ProductsListState extends State<ProductList> {
  
  @override
  void initState() {
    widget.model.fetchProducts(onlyForUser: true);
    super.initState();
  }

  Widget _buildEditButton(BuildContext context, int index, MainModel model) {
    return IconButton(
      icon: Icon(Icons.edit),
      onPressed: () {
        model.selectProduct(model.getProductList[index].id);
        print('list id: ${model.selectedProductId}');
        Navigator
            .of(context)
            .push(MaterialPageRoute(
                builder: (BuildContext context) => EditProducts()))
            .then((_) {
          model.selectProduct(null);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return Dismissible(
              key: Key(model.getProductList[index].title),
              background: Container(color: Colors.red),
              onDismissed: (DismissDirection direction) {
                if (direction == DismissDirection.endToStart) {
                  model.selectProduct(model.getProductList[index].id);

                  model.deleteProduct().then((success){
                    if(!success) {
                      alertDialogueBox(context);
                    }
                  });
                }
              },
              child: Column(children: [
                ListTile(
                  contentPadding: EdgeInsets.all(10.0),
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                      model.getProductList[index].imageUrl,
                    ),
                  ),
                  title: Text(model.getProductList[index].title),
                  subtitle:
                      Text('\$${model.getProductList[index].price.toString()}'),
                  trailing: _buildEditButton(context, index, model),
                ),
                Divider(),
              ]),
            );
          },
          itemCount: model.getProductList.length,
        );
      },
    );
  }
}
