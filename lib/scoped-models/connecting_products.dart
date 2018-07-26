import 'dart:convert';
import 'dart:async';
import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;

import '../models/product.dart';
import '../models/user.dart';

class ConnectingProductsModel extends Model {
  List<Product> _productList = [];
  User _authenticatedUser;
  String _selProductId;
  bool isLoading = false;

  Future<bool> addProduct(
      String title, String description, String imageUrl, double price) {
    final Map<String, dynamic> postProductBody = {
      'title': title,
      'imageUrl':
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT-SumtZ11y2MUjp_2Ps82xXLuCNWBmIChrFWma2-NfQAbVw6phJA',
      'description': description,
      'price': price,
      'userEmail': _authenticatedUser.email,
      'userId': _authenticatedUser.id,
    };

    isLoading = true;
    notifyListeners();
    return http
        .post('https://flutter-products-9738a.firebaseio.com/products.json',
            body: json.encode(postProductBody))
        .then((http.Response response) {
      if (response.statusCode != 200 && response.statusCode != 201) {
        isLoading = false;
        notifyListeners();
        return false;
      }

      Map<String, dynamic> responseData = json.decode(response.body);
      // print(responseData['name']);
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
      isLoading = false;
      notifyListeners();
      return true;
    });
  }
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
    isLoading = true;
    notifyListeners();
    return http
        .get('https://flutter-products-9738a.firebaseio.com/products.json')
        .then((http.Response response) {
      print(json.decode(response.body));
      final List<Product> fetchedProductList = [];
      final Map<String, dynamic> fetchedList = json.decode(response.body);
      if (fetchedList == null) {
        isLoading = false;
        notifyListeners();
        return;
      }
      print('inside if comndition');
      fetchedList.forEach((String productId, dynamic productData) {
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
      isLoading = false;
      notifyListeners();
    });
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

  void deleteProduct() {
    isLoading = true;
    final deletedProduct = selectedProductId;
    _productList.removeAt(selectedProductIndex);

    notifyListeners();
    http
        .delete(
            'https://flutter-products-9738a.firebaseio.com/products/${deletedProduct}.json')
        .then((http.Response response) {
      _selProductId = null;
      isLoading = false;
      notifyListeners();
    });
  }

  Future<Null> updateProduct(
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
    isLoading = true;
    notifyListeners();
    return http
        .put(
            'https://flutter-products-9738a.firebaseio.com/products/${selectedProduct.id}.json',
            body: json.encode(postProductBody))
        .then((http.Response response) {
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
      isLoading = false;
      notifyListeners();
    });
  }

  void selectProduct(String id) {
    _selProductId = id;
  }
}

class UserModel extends ConnectingProductsModel {
  void login(String email, String password) {
    _authenticatedUser = User(id: 'abc123', email: email, password: password);
  }
}

class UtilityModel extends ConnectingProductsModel {
  bool get loading {
    return isLoading;
  }
}
