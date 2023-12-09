import 'package:appflowy_board/appflowy_board.dart';
import 'package:flutter/material.dart';
import 'package:task_master/domain/model/board.dart';
import 'package:task_master/domain/model/task.dart';
import 'package:task_master/presentation/RepositoryManager.dart';
import 'package:task_master/presentation/widgets/not_found_page.dart';
import 'package:intl/intl.dart';

import '../../domain/model/board_list.dart';
import '../../domain/model/workspace.dart';
import '../../util/utils.dart';

class BoardView extends StatefulWidget {
  const BoardView({super.key});

  @override
  State<BoardView> createState() => _BoardViewState();
}

class _BoardViewState extends State<BoardView> {
  late Workspace? workspace;
  late Board? board;
  late final AppFlowyBoardController controller;
  late AppFlowyBoardScrollController boardScrollController;
  late Future<List<BoardList>> futureLists;
  late Future<List<Task>> futureTasks;
  Map<int, List<Task>> taskMap = {};
  final _newListFormKey = GlobalKey<FormState>();
  final TextEditingController _newListController = TextEditingController();
  final _newTaskFormKey = GlobalKey<FormState>();
  final TextEditingController _newTaskController = TextEditingController();
  bool filtered = false;

  @override
  void initState() {
    boardScrollController = AppFlowyBoardScrollController();
    controller = AppFlowyBoardController(
      onMoveGroup: (fromGroupId, fromIndex, toGroupId, toIndex) {
        debugPrint('Move item from $fromIndex to $toIndex');
      },
      onMoveGroupItem: (groupId, fromIndex, toIndex) async {
        debugPrint('Move $groupId:$fromIndex to $groupId:$toIndex');
      },
      onMoveGroupItemToGroup: _moveTaskToList,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as BoardViewArguments?;
    workspace = args?.workspace;
    board = args?.board;
    return board != null ? view() : const NotFoundPage();
  }

  Widget view() {
    futureLists = RepositoryManager().listRepository.getAllLists(board!.id!);
    futureTasks = RepositoryManager().taskRepository.getAllTasks(board!.id!);
    return Scaffold(
      appBar: AppBar(
        title: Text(board!.name),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(onPressed: () async {
            await RepositoryManager().boardRepository.deleteBoard(board!.id!);
            if (context.mounted) Navigator.pop(context); // Navigate back when button is pressed
          }, icon: const Icon(Icons.delete)),
          const SizedBox(width: 8,),
          InkWell(
            onTap: () {
              setState(() {
                filtered = !filtered;
              });
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(filtered ? 'Tareas asignadas a mí' : 'Todas las tareas'),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.filter_alt_outlined,
                    color: Colors.black,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
      body: Container(
          padding: const EdgeInsets.all(16),
          alignment: Alignment.topCenter,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [_boardBuilder()],
          )),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text('Nueva lista'),
        icon: const Icon(Icons.add),
        heroTag: "btn3",
        onPressed: () {
          _createListDialog();
        },
      ),
    );
  }

  Widget _boardBuilder() {
    return FutureBuilder(
        future: Future.wait([futureLists, futureTasks]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            throw snapshot.error!;
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.data != null) {
            return _board(snapshot.data![0] as List<BoardList>,
                snapshot.data![1] as List<Task>);
          }
          return const SizedBox.shrink();
        });
  }

  Widget _board(List<BoardList> lists, List<Task> tasks) {
    controller.clear();
    taskMap = {};
    for (BoardList list in lists) {
      List<Task> taskInList =
          tasks.where((element) => element.listId == list.id).toList();
      taskMap[list.id] = taskInList;
    }
    final config = AppFlowyBoardConfig(
      groupBackgroundColor: HexColor.fromHex('#F7F8FC'),
      stretchGroupHeight: false,
    );
    for (BoardList list in lists) {
      final group = AppFlowyGroupData(
          id: list.id.toString(),
          name: list.name,
          items: <AppFlowyGroupItem>[
            for (Task task in taskMap[list.id]!) RichTextItem(task: task)
          ]);
      controller.addGroup(group);
    }

    return AppFlowyBoard(
        controller: controller,
        cardBuilder: (context, group, groupItem) {
          return AppFlowyGroupCard(
            key: ValueKey(groupItem.id),
            child: _buildCard(groupItem),
          );
        },
        boardScrollController: boardScrollController,
        footerBuilder: (context, columnData) {
          return AppFlowyGroupFooter(
            icon: const Icon(Icons.add, size: 20),
            title: const Text('Nueva Tarea'),
            height: 50,
            margin: config.footerPadding,
            onAddButtonClick: () async {
              boardScrollController.scrollToBottom(columnData.id);
              _createTaskDialog(int.parse(columnData.id));
              _refreshBoard();
            },
          );
        },
        headerBuilder: (context, columnData) {
          return AppFlowyGroupHeader(
            icon: const Icon(Icons.list),
            moreIcon: InkWell(
              onTap: () {
                snackBar(context, 'Manten presionado para borrar');
              },
              onLongPress: () {
                _deleteList(int.parse(columnData.id));
              },
              child: Ink(
                child: const Icon(
                  Icons.delete,
                ),
              ),
            ),
            title: SizedBox(
              width: 150,
              child: TextField(
                controller: TextEditingController()
                  ..text = columnData.headerData.groupName,
                onSubmitted: (val) async {
                  await RepositoryManager()
                      .listRepository
                      .changeName(int.parse(columnData.id), val);
                  controller
                      .getGroupController(columnData.headerData.groupId)!
                      .updateGroupName(val);
                },
              ),
            ),
            height: 50,
            margin: config.headerPadding,
          );
        },
        groupConstraints: const BoxConstraints.tightFor(width: 280),
        config: config);
  }

  Widget _buildCard(AppFlowyGroupItem item) {
    if (item is RichTextItem) {
      return InkWell(
          onTap: () async {
            await Navigator.pushNamed(context, '/task',
                arguments: TaskViewArguments(workspace!, item.task));
            setState(() {});
          },
          child: RichTextCard(
            item: item,
          ));
    }
    throw UnimplementedError();
  }

  _createListDialog() {
    showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              content: Form(
                key: _newListFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _newListController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                          labelText: 'Nombre',
                          border: const OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2.0),
                          )),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                    textStyle: Theme.of(context).textTheme.labelLarge,
                  ),
                  child: const Text('Cancelar'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    textStyle: Theme.of(context).textTheme.labelLarge,
                  ),
                  onPressed: () async {
                    _createList();
                  },
                  child: const Text('Crear'),
                ),
              ],
            ));
  }

  _createTaskDialog(int listId) {
    showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              content: Form(
                key: _newTaskFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _newTaskController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                          labelText: 'Nombre',
                          border: const OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2.0),
                          )),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                    textStyle: Theme.of(context).textTheme.labelLarge,
                  ),
                  child: const Text('Cancelar'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    textStyle: Theme.of(context).textTheme.labelLarge,
                  ),
                  onPressed: () async {
                    _createTask(listId);
                  },
                  child: const Text('Crear'),
                ),
              ],
            ));
  }

  _createList() async {
    if (_newListFormKey.currentState!.validate()) {
      String? message = await RepositoryManager()
          .listRepository
          .createList(board!.id!, _newListController.text);
      if (context.mounted) {
        if (message != null) {
          snackBar(context, message);
        } else {
          snackBar(context, 'Lista creada exitosamente');
          _newListController.clear();
          _refreshBoard();
          Navigator.of(context).pop();
        }
      }
    }
  }

  _createTask(int listId) async {
    if (_newTaskFormKey.currentState!.validate()) {
      String? message = await RepositoryManager()
          .taskRepository
          .createTask(Task(listId: listId, title: _newTaskController.text));
      if (context.mounted) {
        if (message != null) {
          snackBar(context, message);
        } else {
          snackBar(context, 'Tarea creada exitosamente');
          _newTaskController.clear();
          _refreshBoard();
          Navigator.of(context).pop();
        }
      }
    }
  }

  _deleteList(int listId) async {
    String? message =
        await RepositoryManager().listRepository.deleteList(listId);
    if (context.mounted) {
      if (message != null) {
        snackBar(context, message);
      } else {
        snackBar(context, 'Tarea eliminada');
        _newTaskController.clear();
        _refreshBoard();
      }
    }
  }

  _refreshBoard() {
    setState(() {});
  }

  void _moveTaskToList(
      String fromGroupId, int fromIndex, String toGroupId, int toIndex) async {
    Task task = taskMap[int.parse(fromGroupId)]![fromIndex];
    debugPrint('${task.title} moved from $fromGroupId to $toGroupId:$toIndex');
    String? message = await RepositoryManager()
        .taskRepository
        .moveTaskToList(task.id!, int.parse(toGroupId));
    if (context.mounted && message != null) snackBar(context, message);
    _refreshBoard();
  }
}

class RichTextCard extends StatefulWidget {
  final RichTextItem item;

  const RichTextCard({
    required this.item,
    Key? key,
  }) : super(key: key);

  @override
  State<RichTextCard> createState() => _RichTextCardState();
}

class _RichTextCardState extends State<RichTextCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.item.task.title,
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.left,
            ),
            if (widget.item.task.dueDate != null) const SizedBox(height: 10),
            if (widget.item.task.dueDate != null)
              Text(
                formatter.format(widget.item.task.dueDate!),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              )
          ],
        ),
      ),
    );
  }
}

class TextItem extends AppFlowyGroupItem {
  final Task task;

  TextItem(this.task);

  @override
  String get id => task.id.toString();
}

class RichTextItem extends AppFlowyGroupItem {
  final Task task;

  RichTextItem({required this.task});

  @override
  String get id => task.title;
}
