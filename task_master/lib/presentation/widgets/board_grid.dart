import 'package:flutter/material.dart';
import 'package:task_master/domain/model/board.dart';
import 'package:task_master/domain/model/workspace.dart';
import 'package:task_master/presentation/RepositoryManager.dart';
import 'package:task_master/util/utils.dart';

class BoardGrid extends StatefulWidget {
  final Workspace workspace;
  final Function(Board board) onBoardClick;

  const BoardGrid(
      {super.key, required this.workspace, required this.onBoardClick});

  @override
  State<BoardGrid> createState() => _BoardGridState();
}

class _BoardGridState extends State<BoardGrid> {
  late Future<List<Board>> boards;
  final TextEditingController _newBoardNameController = TextEditingController();
  final _newBoardFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    boards =
        RepositoryManager().boardRepository.getAllBoards(widget.workspace.id!);
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            alignment: Alignment.center,
            child: Text(
              widget.workspace.name,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
                fontSize: 40,
              ),
            ),
          ),
          Expanded(child: _grid())
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text('Nuevo tablero'),
        icon: const Icon(Icons.add),
        heroTag: "btn2",
        onPressed: () {
          _createBoardDialog();
        },
      ),
    );
  }

  Widget _grid() {
    return FutureBuilder(
        future: boards,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }
          if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text('Something went wrong'));
          }
          return GridView.count(
              crossAxisCount: 5,
              children: [for (Board board in snapshot.data!) boardCard(board)]);
        });
  }

  Widget boardCard(Board board) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: InkWell(
          onTap: () {
            widget.onBoardClick(board);
          },
          child: Center(
            child: Text(
              board.name,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  _createBoardDialog() {
    showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              content: Form(
                key: _newBoardFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _newBoardNameController,
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
                    _createBoard();
                  },
                  child: const Text('Crear'),
                ),
              ],
            ));
  }

  _createBoard() async {
    if (_newBoardFormKey.currentState!.validate()) {
      String? message = await RepositoryManager()
          .boardRepository
          .createBoard(widget.workspace.id!, _newBoardNameController.text);
      if (context.mounted) {
        if (message != null) {
          snackBar(context, message);
        } else {
          snackBar(context, 'Tablero creado exitosamente');
          _newBoardNameController.clear();
          _refreshGrid();
          Navigator.of(context).pop();
        }
      }
    }
  }

  _refreshGrid() {
    setState(() {
      // boards = RepositoryManager()
      //     .boardRepository
      //     .getAllBoards(widget.workspace.id!);
    });
  }
}
