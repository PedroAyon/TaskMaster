import 'package:flutter/material.dart';
import 'package:task_master/domain/model/member_details.dart';

Widget memberAvatar(MemberDetails memberDetails) {
  return CircleAvatar(
    child: Text(memberDetails.name.toUpperCase()[0],),
    //style: TextStyle(
    //               color: Theme.of(context).colorScheme.onBackground,
    //               fontSize: 40,
    //             ),
  );
}