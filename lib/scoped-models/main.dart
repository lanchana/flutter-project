import 'package:scoped_model/scoped_model.dart';

import './connecting_products.dart';

class MainModel extends Model with ConnectingProductsModel, UserModel, ProductModel, UtilityModel {}