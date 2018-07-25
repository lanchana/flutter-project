import 'dart:convert';
import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;

import '../models/product.dart';
import '../models/user.dart';

class ConnectingProductsModel extends Model {
  List<Product> _productList = [];
  User _authenticatedUser;
  int _selProductIndex;

  void addProduct(
      String title, String description, String imageUrl, double price) {
    final Map<String, dynamic> postProductBody = {
      'title': title,
      'imageUrl':
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT-SumtZ11y2MUjp_2Ps82xXLuCNWBmIChrFWma2-NfQAbVw6phJA',
      'description': description,
      'price': price
    };

    http
        .post('https://flutter-products-9738a.firebaseio.com/products.json',
            body: json.encode(postProductBody))
        .then((http.Response response) {
      Map<String, dynamic> responseData =  json.decode(response.body);
      print(responseData);
      // final Product newProduct = Product(
      //     id:
      //     title: title,
      //     description: description,
      //     imageUrl: imageUrl,
      //     price: price,
      //     userEmail: _authenticatedUser.email,
      //     userId: _authenticatedUser.id
      //   );

      //   _productList.add(newProduct);
      //   _selProductIndex = null;
      //   notifyListeners();
    });
  }
}

class ProductModel extends ConnectingProductsModel {
  bool showFavorites = false;

  List<Product> get getProductList {
    return List.from(_productList);
  }

  int get selectedProductIndex {
    return _selProductIndex;
  }

  Product get selectedProduct {
    if (selectedProductIndex == null) {
      return null;
    }
    return _productList[selectedProductIndex];
  }

  bool get displayFavorites {
    return showFavorites;
    // notifyListeners();
  }

  void toggleShowFavorite() {
    showFavorites = !showFavorites;
    _selProductIndex = null;
    notifyListeners();
  }

  List<Product> get displayedProduct {
    if (showFavorites) {
      return _productList
          .where((Product product) => product.isFavorite == true)
          .toList();
    }
    return List.from(_productList);
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
    _productList.removeAt(selectedProductIndex);
    notifyListeners();
  }

  void updateProduct(
      String title, String description, String imageUrl, double price) {
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
    notifyListeners();
  }

  void selectProduct(int index) {
    _selProductIndex = index;
  }
}

class UserModel extends ConnectingProductsModel {
  void login(String email, String password) {
    _authenticatedUser = User(id: 'abc123', email: email, password: password);
  }
}
