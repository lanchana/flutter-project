import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import './models/product.dart';

import 'package:scoped_model/scoped_model.dart';
import './scoped-models/main.dart';

import './pages/auth.dart';
import './pages/product_admin.dart';
// import './pages/product_list.dart';
// import './pages/create_product.dart';
import './pages/products.dart';

import './pages/product.dart';

void main() {
  // debugPaintSizeEnabled = true;
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    MainModel model = MainModel();
    return ScopedModel<MainModel>(
      model: model,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.teal,
          buttonColor: Colors.teal,
        ),

        // home: AuthPage(),
        routes: {
          '/': (BuildContext context) => AuthPage(),
          '/products': (BuildContext context) => ProductsPage(model),
          '/admin': (BuildContext context) => ProductAdmin(model),
        },
        onGenerateRoute: (RouteSettings settings) {
          final List<String> pathElements = settings.name.split('/');
          // pathElements will be '', 'products', '2'->index
          print(pathElements);
          if (pathElements[0] != '') {
            return null;
          }

          if (pathElements[1] == 'product') {
            final index = int.parse(pathElements[2]);
            return MaterialPageRoute<bool>(
              builder: (BuildContext context) =>
                  ProductPage(index),
            );
          }
          return null;
        },
        onUnknownRoute: (RouteSettings settings) {
          return MaterialPageRoute(
              builder: (BuildContext context) => ProductsPage(model));
        },
      ),
    );
  }
}
