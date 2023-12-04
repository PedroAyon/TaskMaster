import 'package:flutter/material.dart';

snackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

extension HttpStatus on int {
  bool isStatusOk() {
    return this >= 200 && this < 300;
  }
}