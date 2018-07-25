import 'package:flutter/material.dart';

class PriceTag extends StatelessWidget {
  final String price;

  PriceTag(this.price);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.5),
      margin: EdgeInsets.only(bottom: 13.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          color: Theme.of(context).primaryColor),
      child: Text(
        '$price',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
