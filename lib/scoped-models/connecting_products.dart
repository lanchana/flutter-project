import 'dart:convert';
import 'dart:async';
import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;

 import 'package:shared_preferences/shared_preferences.dart';

import '../models/product.dart';
import '../models/user.dart';

import '../models/auth.dart';

class ConnectingProductsModel extends Model {
  List<Product> _productList = [];
  User _authenticatedUser;
  String _selProductId;
  bool _isLoading = false;
}

class ProductModel extends ConnectingProductsModel {
  bool showFavorites = false;

  List<Product> get getProductList {
    return List.from(_productList);
  }

  String get selectedProductId {
    return _selProductId;
  }

  Product get selectedProduct {
    if (selectedProductId == null) {
      return null;
    }
    return _productList.firstWhere((Product product) {
      return product.id == selectedProductId;
    });
  }

  int get selectedProductIndex {
    return _productList.indexWhere((Product product) {
      return product.id == _selProductId;
    });
  }

  bool get displayFavorites {
    return showFavorites;
  }

  List<Product> get displayedProduct {
    if (showFavorites) {
      return _productList
          .where((Product product) => product.isFavorite == true)
          .toList();
    }
    return List.from(_productList);
  }

  void toggleShowFavorite() {
    showFavorites = !showFavorites;
    _selProductId = null;
    notifyListeners();
  }

  Future<Null> fetchProducts() {
    print('fetch products');
    _isLoading = true;
    notifyListeners();
    return http
        .get(
            'https://flutter-products-9738a.firebaseio.com/products.json?auth=${_authenticatedUser.token}')
        .then<Null>((http.Response response) {
      print(json.decode(response.body));
      final List<Product> fetchedProductList = [];
      final Map<String, dynamic> fetchedList = json.decode(response.body);
      if (fetchedList == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }
      print('inside if comndition');
      fetchedList.forEach((productId, dynamic productData) {
        print('inside foreach');
        final Product product = Product(
            id: productId,
            title: productData['title'],
            price: productData['price'],
            description: productData['description'],
            userEmail: productData['userEmail'],
            userId: productData['userId'],
            imageUrl: productData['imageUrl']);

        fetchedProductList.add(product);
      });

      print(fetchedProductList);
      _productList = fetchedProductList;
      _isLoading = false;
      notifyListeners();
    }).catchError((onError) {
      _isLoading = false;
      notifyListeners();
      return;
    });
  }

  Future<bool> addProduct(
      String title, String description, String imageUrl, double price) async {
    final Map<String, dynamic> postProductBody = {
      'title': title,
      'imageUrl':
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT-SumtZ11y2MUjp_2Ps82xXLuCNWBmIChrFWma2-NfQAbVw6phJA',
      'description': description,
      'price': price,
      'userEmail': _authenticatedUser.email,
      'userId': _authenticatedUser.id,
    };

    _isLoading = true;
    notifyListeners();
    try {
      final http.Response response = await http.post(
          'https://flutter-products-9738a.firebaseio.com/products.json?auth=${_authenticatedUser.token}',
          body: json.encode(postProductBody));
      if (response.statusCode != 200 && response.statusCode != 201) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      Map<String, dynamic> responseData = json.decode(response.body);
      final Product newProduct = Product(
          id: responseData['name'],
          title: title,
          description: description,
          imageUrl: imageUrl,
          price: price,
          userEmail: _authenticatedUser.email,
          userId: _authenticatedUser.id);

      _productList.add(newProduct);
      _selProductId = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void toggleSelectedProductFavorite() {
    final bool selectedProductFavorite = selectedProduct.isFavorite;
    final bool currentFavorite = !selectedProductFavorite;
    final Product _updatedProduct = Product(
        id: selectedProduct.id,
        title: selectedProduct.title,
        description: selectedProduct.description,
        imageUrl: selectedProduct.imageUrl,
        price: selectedProduct.price,
        userEmail: selectedProduct.userEmail,
        userId: selectedProduct.userId,
        isFavorite: currentFavorite);
    _productList[selectedProductIndex] = _updatedProduct;
    notifyListeners();
  }

  Future<bool> deleteProduct() {
    _isLoading = true;
    final deletedProduct = selectedProductId;
    _productList.removeAt(selectedProductIndex);

    notifyListeners();
    return http
        .delete(
            'https://flutter-products-9738a.firebaseio.com/products/${deletedProduct}.json?auth=${_authenticatedUser.token}')
        .then((http.Response response) {
      _isLoading = false;
      notifyListeners();
      _selProductId = null;

      if (response.statusCode != 200 && response.statusCode != 201) {
        return false;
      }
      return true;
    }).catchError((onError) {
      _isLoading = false;
      notifyListeners();
      return false;
    });
  }

  Future<bool> updateProduct(
      String title, String description, String imageUrl, double price) {
    final Map<String, dynamic> postProductBody = {
      'title': title,
      'imageUrl':
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT-SumtZ11y2MUjp_2Ps82xXLuCNWBmIChrFWma2-NfQAbVw6phJA',
      'description': description,
      'price': price,
      'userEmail': selectedProduct.userEmail,
      'userId': selectedProduct.userId,
      'id': selectedProduct.id
    };
    _isLoading = true;
    notifyListeners();
    return http
        .put(
            'https://flutter-products-9738a.firebaseio.com/products/${selectedProduct.id}.json?auth=${_authenticatedUser.token}',
            body: json.encode(postProductBody))
        .then((http.Response response) {
      if (response.statusCode != 200 && response.statusCode != 201) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
      final Product _updatedProduct = Product(
          id: selectedProduct.id,
          title: title,
          description: description,
          imageUrl: imageUrl,
          price: price,
          userEmail: selectedProduct.userEmail,
          userId: selectedProduct.userId,
          isFavorite: selectedProduct.isFavorite);
      _productList[selectedProductIndex] = _updatedProduct;
      _isLoading = false;
      notifyListeners();
      return true;
    }).catchError((onError) {
      _isLoading = false;
      notifyListeners();
      return false;
    });
  }

  void selectProduct(String id) {
    _selProductId = id;
  }
}

class UserModel extends ConnectingProductsModel {
  User get authenticatedUser {
    return _authenticatedUser;
  }

  Future<Map<String, dynamic>> authMode(String email, String password,
      [AuthMode mode = AuthMode.Signin]) async {
    final _body = {
      'email': email,
      'password': password,
      'returnSecureToken': true
    };
    _isLoading = true;
    notifyListeners();
    http.Response response;
    if (mode == AuthMode.Signup) {
      response = await http.post(
          'https://www.googleapis.com/identitytoolkit/v3/relyingparty/signupNewUser?key=AIzaSyC-NY6AXUikWAhhHxlT72aySvWSjJ93lNc',
          body: json.encode(_body));
    } else {
      response = await http.post(
          'https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=AIzaSyC-NY6AXUikWAhhHxlT72aySvWSjJ93lNc',
          body: json.encode(_body));
    }

    final Map<String, dynamic> firebaseResponse = json.decode(response.body);
    print(firebaseResponse);
    // _authenticatedUser{email: email}

    bool success = false;
    String message = 'Something went wrong';

    if (firebaseResponse.containsKey('idToken')) {
      success = true;
      _authenticatedUser = User(
          id: firebaseResponse['localId'],
          email: firebaseResponse['email'],
          token: firebaseResponse['idToken']);

       final SharedPreferences prefs = await SharedPreferences.getInstance();
       prefs.setString('token', firebaseResponse['idToken']);
       prefs.setString('email', firebaseResponse['email']);
       prefs.setString('localId', firebaseResponse['localId']);

      message = 'Authentication Success';
    } else if (firebaseResponse['error']['message'] == 'EMAIL_NOT_FOUND') {
      message = 'Email is not registered';
    } else if (firebaseResponse['error']['message'] == 'INVALID_PASSWORD') {
      message = 'Invalid password';
    } else if (firebaseResponse['error']['message'] == 'USER_DISABLED') {
      message = 'User is disabled';
    } else if (firebaseResponse['error']['message'] == 'EMAIL_EXISTS') {
      message = 'Email address already registered';
    }

    _isLoading = false;
    notifyListeners();
    return {'success': success, 'message': message};
  }

   void isAuthenticated() async {
     final SharedPreferences prefs = await SharedPreferences.getInstance();
     final String token = prefs.getString('token');
     if (token != null) {
       final String email = prefs.getString('email');
       final String id = prefs.getString('localId');
       _authenticatedUser = User(
         token: token,
         email: email,
         id: id,
       );
     }
   }

   void logout() async {
     _authenticatedUser = null;
     final SharedPreferences prefs = await SharedPreferences.getInstance();
     prefs.remove('token');
     prefs.remove('email');
     prefs.remove('localId');
   }
}

class UtilityModel extends ConnectingProductsModel {
  bool get isLoading {
    return _isLoading;
  }
}
