import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:task_master/domain/model/task.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:task_master/domain/model/workspace.dart';
import 'package:task_master/presentation/RepositoryManager.dart';
import 'package:task_master/presentation/widgets/assigned_members_widget.dart';
import 'package:task_master/presentation/widgets/log_out_button.dart';
import 'package:task_master/util/utils.dart';

import '../widgets/not_found_page.dart';

class TaskView extends StatefulWidget {
  const TaskView({super.key});

  @override
  State<TaskView> createState() => _TaskViewState();
}

class _TaskViewState extends State<TaskView> {
  late Workspace? workspace;
  late Task? task;
  late EditorState _editorState;

  @override
  Widget build(BuildContext context) {
    final args =
    ModalRoute
        .of(context)!
        .settings
        .arguments as TaskViewArguments?;
    workspace = args?.workspace;
    task = args?.task;
    return task != null ? view() : const NotFoundPage();
  }

  Widget view() {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: TextEditingController()..text = task!.title,
          onSubmitted: (val) async {
            val = val.trim();
            if (val.isNotEmpty) {
              task!.title = val;
              _updateTask();
            }
          },
        ),
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .inversePrimary,
        actions: [
          const SizedBox(
            width: 8,
          ),
          AssignedMembersWidget(
              taskId: task!.id!,
              onTapCallback: () async {
                await Navigator.pushNamed(context, '/task_assignment',
                    arguments: TaskAssignmentViewArguments(workspace!, task!));
                await _updateTask();
              }),
          InkWell(
            onTap: () async {
              _showDatePicker();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month),
                  const SizedBox(width: 8),
                  Text(
                      'Fecha límite: ${task!.dueDate == null
                          ? 'Sin fecha'
                          : dateFormatted(task!.dueDate!)}')
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () async {
              await _updateTask();
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.save),
                  SizedBox(width: 8),
                  Text('Guardar Cambios')
                ],
              ),
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          InkWell(
            onTap: () {
              snackBar(context, 'Manten presionado para borrar');
            },
            onLongPress: () async {
              await RepositoryManager().taskRepository.deleteTask(task!.id!);
              if (context.mounted)
                Navigator.pop(context); // Navigate back when button is pressed
            },
            child: Ink(
              child: const Icon(
                Icons.delete,
              ),
            ),
          ),
          const SizedBox(
            width: 8,
          ),
        ],
      ),
      body: Container(
        child: Row(
          children: [
            Expanded(flex: 1, child: Container(color: Colors.grey,)),
            Expanded(flex: 8, child: _editorWidget()),
            Expanded(flex: 1, child: Container(color: Colors.grey,)),
          ],
        ),
      ),
    );
  }

  Widget _editorWidget() {
    if (task!.description == null) {
      _editorState =
          EditorState.blank(withInitialText: true); // with an empty paragraph
    } else {
      final json = jsonDecode(task!.description!);
      _editorState = EditorState(document: Document.fromJson(json));
    }
    final editor = AppFlowyEditor(
      editorState: _editorState,
    );
    return editor;
  }

  _updateTask() async {
    task?.description = json.encode(_editorState.document.toJson());
    String? message =
    await RepositoryManager().taskRepository.updateTask(task!);
    if (context.mounted && message == null) {
      snackBar(context, 'Cambios guardados');
    } else {
      print(message);
    }
    setState(() {});
  }

  _showDatePicker() {
    showDialog<String>(
        context: context,
        builder: (BuildContext context) =>
            AlertDialog(
              content: Container(
                width: 400,
                child: SfDateRangePicker(
                  view: DateRangePickerView.month,
                  selectionMode: DateRangePickerSelectionMode.single,
                  minDate: DateTime.now(),
                  onSelectionChanged: (
                      DateRangePickerSelectionChangedArgs selection) async {
                    if (selection.value is DateTime) {
                      task!.dueDate = selection.value;
                      _updateTask();
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    }
                  },
                ),
              ),
              actions: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                    textStyle: Theme
                        .of(context)
                        .textTheme
                        .labelLarge,
                  ),
                  child: const Text('Cancelar'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    textStyle: Theme
                        .of(context)
                        .textTheme
                        .labelLarge,
                  ),
                  onPressed: () async {
                    task!.dueDate = null;
                    _updateTask();
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Borrar fecha limite',
                    style: TextStyle(color: Colors.red),),
                ),
              ],
            ));
  }
}
