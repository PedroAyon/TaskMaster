import 'package:flutter/material.dart';
import 'package:task_master/domain/model/board.dart';
import 'package:task_master/domain/model/workspace.dart';

import '../domain/model/task.dart';

snackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

extension HttpStatus on int {
  bool isStatusOk() {
    return this >= 200 && this < 300;
  }
}

extension HexColor on Color {
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

String dateFormatted(DateTime date) {
  return '${date.year}-${date.month}-${date.day}';
}

extension DateOnlyCompare on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}

class BoardViewArguments {
  final Workspace workspace;
  final Board board;

  BoardViewArguments(this.workspace, this.board);
}

class TaskViewArguments {
  final Workspace workspace;
  final Task task;

  TaskViewArguments(this.workspace, this.task);
}

class TaskAssignmentViewArguments {
  final Workspace workspace;
  final Task task;

  TaskAssignmentViewArguments(this.workspace, this.task);
}
