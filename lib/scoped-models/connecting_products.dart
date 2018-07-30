import 'dart:convert';
import 'dart:async';
import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';

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

  Future<Null> fetchProducts({onlyForUser = false}) {
    _isLoading = true;
    notifyListeners();
    return http
        .get(
            'https://flutter-products-9738a.firebaseio.com/products.json?auth=${_authenticatedUser.token}')
        .then<Null>((http.Response response) {
      final List<Product> fetchedProductList = [];
      final Map<String, dynamic> fetchedList = json.decode(response.body);
      if (fetchedList == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }
      fetchedList.forEach((productId, dynamic productData) {
        final Product product = Product(
          id: productId,
          title: productData['title'],
          price: productData['price'],
          description: productData['description'],
          userEmail: productData['userEmail'],
          userId: productData['userId'],
          imageUrl: productData['imageUrl'],
          isFavorite: productData['wishListUsers'] == null
              ? false
              : (productData['wishListUsers'] as Map<String, dynamic>)
                  .containsKey(_authenticatedUser.id),
        );

        fetchedProductList.add(product);
      });
      print(_authenticatedUser.id);
      _productList = onlyForUser
          ? fetchedProductList.where((Product product) {
              return product.userId == _authenticatedUser.id;
            }).toList()
          : fetchedProductList;
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

  void toggleSelectedProductFavorite() async {
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

    http.Response response;
    if (currentFavorite) {
      response = await http.put(
          'https://flutter-products-9738a.firebaseio.com/products/${selectedProduct.id}/wishListUsers/${_authenticatedUser.id}.json?auth=${_authenticatedUser.token}', body: json.encode(true));
    } else {
      response = await http.delete(
          'https://flutter-products-9738a.firebaseio.com/products/${selectedProduct.id}/wishListUsers/${_authenticatedUser.id}.json?auth=${_authenticatedUser.token}');
    }

    print(json.decode(response.body));

    if (response.statusCode != 200 && response.statusCode != 201) {
      final Product _updatedProduct = Product(
          id: selectedProduct.id,
          title: selectedProduct.title,
          description: selectedProduct.description,
          imageUrl: selectedProduct.imageUrl,
          price: selectedProduct.price,
          userEmail: selectedProduct.userEmail,
          userId: selectedProduct.userId,
          isFavorite: !currentFavorite);
      _productList[selectedProductIndex] = _updatedProduct;
      notifyListeners();
    }
    selectProduct(null);

    // selectedProduct = null;
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
  Timer _expiryTime;
  final PublishSubject<bool> _userSubject = PublishSubject();

  User get authenticatedUser {
    return _authenticatedUser;
  }

  PublishSubject<bool> get userSubject {
    return _userSubject;
  }

  Future<Map<String, dynamic>> authMode(String email, String password,
      [AuthMode mode = AuthMode.Signin]) async {
    final _body = {
      'email': email,
      'password': password,
      'returnSecureToken': true
    };
    _isLoading = true;
    userSubject.add(false);
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
    print(firebaseResponse['expiresIn']);

    setTimeoutFunction(int.parse(firebaseResponse['expiresIn']));
    bool success = false;
    String message = 'Something went wrong';

    if (firebaseResponse.containsKey('idToken')) {
      success = true;
      _authenticatedUser = User(
          id: firebaseResponse['localId'],
          email: firebaseResponse['email'],
          token: firebaseResponse['idToken']);

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      _userSubject.add(true);
      prefs.setString('token', firebaseResponse['idToken']);
      prefs.setString('email', firebaseResponse['email']);
      prefs.setString('localId', firebaseResponse['localId']);
      final DateTime now = DateTime.now();
      final DateTime expiryTime = now
          .add(new Duration(seconds: int.parse(firebaseResponse['expiresIn'])));

      prefs.setString('expiryTime', expiryTime.toIso8601String());

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

  void setTimeoutFunction(int time) {
    print(time);
    _expiryTime = Timer(Duration(seconds: time), logout);
  }

  void autoAuthenticated() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token');

    final String expiryTime = prefs.get('expiryTime');

    if (token != null) {
      final DateTime now = DateTime.now();
      final DateTime parsedExpiryTime = DateTime.parse(expiryTime);
      if (parsedExpiryTime.isBefore(now)) {
        print('in isbefore');
        _authenticatedUser = null;
        _userSubject.add(false);
        notifyListeners();
        return;
      }
      _userSubject.add(true);
      final String email = prefs.getString('email');
      final String id = prefs.getString('localId');
      final remainingExpiryTime = parsedExpiryTime.difference(now).inSeconds;
      setTimeoutFunction(remainingExpiryTime);
      _authenticatedUser = User(
        token: token,
        email: email,
        id: id,
      );
      notifyListeners();
    }
  }

  void logout() async {
    _authenticatedUser = null;
    _expiryTime.cancel();
    _userSubject.add(false);
    print('logout');
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
