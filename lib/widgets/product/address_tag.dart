import 'package:flutter/material.dart';

class AddressTag extends StatelessWidget {
  final String address;

  AddressTag(this.address);

  @override
    Widget build(BuildContext context) {
      return Container(
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
            margin: EdgeInsets.only(top: 5.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                border: Border.all(
                    style: BorderStyle.solid, color: Colors.teal, width: 1.0)),
            child: Text(this.address),
          );
    }
}