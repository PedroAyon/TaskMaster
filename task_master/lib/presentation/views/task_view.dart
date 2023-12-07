import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:task_master/domain/model/task.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:task_master/presentation/RepositoryManager.dart';

import '../widgets/not_found_page.dart';

class TaskView extends StatefulWidget {
  const TaskView({super.key});

  @override
  State<TaskView> createState() => _TaskViewState();
}

class _TaskViewState extends State<TaskView> {
  late Task? task;
  late EditorState _editorState;

  @override
  Widget build(BuildContext context) {
    task = ModalRoute.of(context)!.settings.arguments as Task?;
    return task != null ? view() : const NotFoundPage();
  }

  Widget view() {
    return Scaffold(
      appBar: AppBar(
        title: Text(task!.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
              onPressed: () async {
                task?.description = json.encode(_editorState.document.toJson());
                print(_editorState.document.toJson());
                await RepositoryManager().taskRepository.updateTask(task!);
              },
              icon: const Icon(Icons.save))
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
      print("XD ${task!.description}");
      final json = jsonDecode(task!.description!);
      _editorState = EditorState(document: Document.fromJson(json));
    }
    final editor = AppFlowyEditor(
      editorState: _editorState,
    );
    return editor;
  }
}
