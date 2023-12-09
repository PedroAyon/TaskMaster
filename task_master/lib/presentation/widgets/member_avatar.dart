import 'dart:math';

import 'package:flutter/material.dart';
import 'package:task_master/domain/model/member_details.dart';

final _colors = <Color>[
  Colors.red,
  Colors.blue,
  Colors.yellow,
  Colors.green,
  Colors.purple,
  Colors.orange,
  Colors.greenAccent,
];

final _random = Random();

Widget memberAvatar(MemberDetails memberDetails) {
  return CircleAvatar(
    backgroundColor: _colors[_random.nextInt(_colors.length)],
    child: Text(
      memberDetails.name.toUpperCase()[0],
    ),
  );
}
