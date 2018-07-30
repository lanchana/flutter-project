import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';

import './models/product.dart';
import './models/user.dart';

import 'package:scoped_model/scoped_model.dart';
import './scoped-models/main.dart';

import './pages/auth.dart';
import './pages/product_admin.dart';
import './pages/products.dart';

import './pages/product.dart';

void main() {
  // debugPaintSizeEnabled = true;
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  final MainModel _model = MainModel();
  bool _isAuthenticated = false;

  @override
  void initState() {
    _model.autoAuthenticated();
    _model.userSubject.listen((bool data) {
      print(data);
      setState(() {
        _isAuthenticated = data;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<MainModel>(
      model: _model,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.teal,
          buttonColor: Colors.teal,
        ),
        routes: {
          // '/': (BuildContext context) => AuthPage(),
          '/': (BuildContext context) =>  _isAuthenticated ? ProductsPage(_model) : AuthPage(),
          // '/products': (BuildContext context) => ProductsPage(_model),
          '/admin': (BuildContext context) =>
              _isAuthenticated ? ProductAdmin(_model) : AuthPage(),
        },
        onGenerateRoute: (RouteSettings settings) {
          final List<String> pathElements = settings.name.split('/');

          if (!_isAuthenticated) {
            AuthPage();
          }
          // pathElements will be '', 'products', '2'->index
          print(pathElements);
          if (pathElements[0] != '') {
            return null;
          }

          if (pathElements[1] == 'product') {
            final String id = pathElements[2];
            Product product =
                _model.getProductList.firstWhere((Product product) {
              return product.id == id;
            });

            return MaterialPageRoute<bool>(
              builder: (BuildContext context) => _isAuthenticated ? ProductPage(product) : AuthPage(),
            );
          }
          return null;
        },
        onUnknownRoute: (RouteSettings settings) {
          return MaterialPageRoute(
              builder: (BuildContext context) =>
                  _isAuthenticated ? ProductsPage(_model) : AuthPage());
        },
      ),
    );
  }
}
