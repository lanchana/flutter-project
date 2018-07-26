import 'package:flutter/material.dart';

alertDialogueBox(BuildContext context) {
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Something went wrong!'),
          content: Text('Do want to try again?'),
          actions: <Widget>[
            FlatButton(
              child: Text('Try again'),
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        );
      });
}
