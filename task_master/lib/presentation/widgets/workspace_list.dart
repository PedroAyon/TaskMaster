import 'package:flutter/material.dart';
import 'package:task_master/domain/model/workspace.dart';
import 'package:task_master/presentation/RepositoryManager.dart';
import 'package:task_master/presentation/widgets/workspace_list_tile.dart';
import 'package:task_master/util/utils.dart';

import '../../domain/model/user.dart';

class WorkspaceList extends StatefulWidget {
  final Function(Workspace) openWorkspacePanel;
  final Function(Workspace) openMemberManagementPanel;
  final Function() clearMainPanel;

  const WorkspaceList({
    Key? key,
    required this.openWorkspacePanel,
    required this.openMemberManagementPanel,
    required this.clearMainPanel,
  }) : super(key: key);

  @override
  State<WorkspaceList> createState() => _WorkspaceListState();
}

class _WorkspaceListState extends State<WorkspaceList> {
  final _workspaceNameFormKey = GlobalKey<FormState>();
  final TextEditingController _workspaceNameController =
      TextEditingController();
  late Future<List<Workspace>> workspaceList;
  late Future<User?> user;

  @override
  Widget build(BuildContext context) {
    workspaceList = RepositoryManager().workspaceRepository.getWorkspaceList();
    user = RepositoryManager().authRepository.getUser();
    return Scaffold(
      backgroundColor: const Color.fromRGBO(240, 240, 240, 1),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              "Espacios de Trabajo",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: FutureBuilder(
                future: Future.wait([workspaceList, user]),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator(),);
                  }
                  if (snapshot.hasError || snapshot.data == null) {
                    return const Center(child: Text('Something went wrong'));
                  }
                  List<Workspace> workspaces =
                      snapshot.data![0] as List<Workspace>;
                  User? user = snapshot.data![1] as User;
                  return ListView.builder(
                    itemCount: workspaces.length,
                    itemBuilder: (context, index) {
                      Workspace workspace = workspaces[index];
                      return WorkspaceListTile(
                        workspace: workspace,
                        user: user,
                        openWorkspacePanel: widget.openWorkspacePanel,
                        openMemberManagementPanel:
                            widget.openMemberManagementPanel,
                        refreshWorkspaceList: _refreshWorkspaceList,
                      );
                    },
                  );
                }),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        heroTag: "btn1",
        onPressed: () {
          _workspaceNameDialog(callbackAction: _createWorkspace);
        },
      ),
    );
  }

  _workspaceNameDialog({required Function callbackAction}) {
    showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              content: Form(
                key: _workspaceNameFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _workspaceNameController,
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
                    callbackAction();
                  },
                  child: const Text('Crear'),
                ),
              ],
            ));
  }

  _createWorkspace() async {
    if (_workspaceNameFormKey.currentState!.validate()) {
      String? message = await RepositoryManager()
          .workspaceRepository
          .createWorkspace(_workspaceNameController.text);
      if (context.mounted) {
        if (message == null) {
          snackBar(context, 'Espacio de trabajo creado!');
          _workspaceNameController.clear();
          _refreshWorkspaceList();
          Navigator.of(context).pop();
        } else {
          snackBar(context, message);
        }
      }
    }
  }

  _refreshWorkspaceList() {
    setState(() {
      // workspaceList =
      //     RepositoryManager().workspaceRepository.getWorkspaceList();
    });
    widget.clearMainPanel();
  }
}
