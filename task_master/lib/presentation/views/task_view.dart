import 'dart:convert';

import 'package:flutter/material.dart';
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
        ModalRoute.of(context)!.settings.arguments as TaskViewArguments?;
    workspace = args?.workspace;
    task = args?.task;
    return task != null ? view() : const NotFoundPage();
  }

  Widget view() {
    return Scaffold(
      appBar: AppBar(
        title: Text(task!.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(onPressed: () async {
            await RepositoryManager().taskRepository.deleteTask(task!.id!);
            if (context.mounted) Navigator.pop(context); // Navigate back when button is pressed
          }, icon: const Icon(Icons.delete)),
          const SizedBox(width: 8,),
          AssignedMembersWidget(
              taskId: task!.id!,
              onTapCallback: () {
                Navigator.pushNamed(context, '/task_assignment',
                    arguments:
                        TaskAssignmentViewArguments(workspace!, task!));
              }),
          InkWell(
            onTap: () async {
              task?.description = json.encode(_editorState.document.toJson());
              print(_editorState.document.toJson());
              await RepositoryManager().taskRepository.updateTask(task!);
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
        ],
      ),
      body: Container(
        child: _editorWidget(),
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
}
