import 'package:flutter/material.dart';
import 'package:task_master/domain/model/member_details.dart';

final _colors = <Color>[
  Colors.tealAccent,
  Colors.blue,
  Colors.green,
  Colors.purple,
  Colors.orange,
  Colors.greenAccent,
  Colors.red,
  Colors.amber,
];

Widget memberAvatar(MemberDetails memberDetails) {
  String initial = memberDetails.name.toUpperCase()[0];
  int asciiValue = initial.codeUnitAt(0);
  return Tooltip(
    message: memberDetails.name,
    child: CircleAvatar(
      backgroundColor: _colors[asciiValue % _colors.length],
      //backgroundColor: Colors.blue,
      child: Text(
        initial,
      ),
    ),
  );
}
