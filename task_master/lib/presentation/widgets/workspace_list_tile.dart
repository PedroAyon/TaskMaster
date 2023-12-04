import 'package:flutter/material.dart';

import '../../domain/model/user.dart';
import '../../domain/model/workspace.dart';
import '../../util/utils.dart';
import '../RepositoryManager.dart';

class WorkspaceListTile extends StatefulWidget {
  final Workspace workspace;
  final User user;
  final Function(Workspace) openWorkspacePanel;
  final Function(Workspace) openMemberManagementPanel;
  final Function() refreshWorkspaceList;

  const WorkspaceListTile({
    Key? key,
    required this.workspace,
    required this.user,
    required this.openWorkspacePanel,
    required this.openMemberManagementPanel,
    required this.refreshWorkspaceList,
  }) : super(key: key);

  @override
  State<WorkspaceListTile> createState() => _WorkspaceListTileState();
}

class _WorkspaceListTileState extends State<WorkspaceListTile> {
  late final Future<String> userRole;
  final _workspaceRenameFormKey = GlobalKey<FormState>();
  final TextEditingController _workspaceNameController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    userRole = RepositoryManager()
        .workspaceRepository
        .getUserRole(widget.workspace.id!, null);
  }

  @override
  Widget build(BuildContext context) {
    Workspace workspace = widget.workspace;
    return Column(
      children: [
        Container(
          color: Colors.white,
          child: ListTile(
            title: Text(workspace.name),
            trailing: _adminSettings(workspace),
            onTap: () {
              widget.openWorkspacePanel(workspace);
            },
            tileColor: Colors.blueGrey.shade50,
          ),
        ),
        const Divider(
          height: 1.0,
          indent: 1.0,
        ),
      ],
    );
  }

  Widget? _adminSettings(Workspace workspace) {
    return FutureBuilder(
        future: userRole,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox.shrink();
          } else if (snapshot.hasError) {
            debugPrint('ERROR ${snapshot.error}');
          } else if (snapshot.data == 'Normal') {
            return const SizedBox.shrink();
          } else if (snapshot.data == 'Admin') {
            return workspacePopupMenuButton();
          }
          return const SizedBox.shrink();
        });
  }

  Widget workspacePopupMenuButton() {
    return PopupMenuButton<String>(
      tooltip: '',
      icon: const Icon(Icons.more_vert),
      onSelected: (String item) async {
        switch (item) {
          case 'manage_members':
            widget.openMemberManagementPanel(widget.workspace);
          case 'rename':
            _workspaceRenameDialog(callbackAction: _renameWorkspace);
          case 'delete':
            await _deleteWorkspace();
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'rename',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text("Renombrar"), Icon(Icons.edit)],
          ),
        ),
        if (widget.user.id == widget.workspace.createdBy)
          const PopupMenuItem<String>(
              value: 'delete',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text("Borrar"), Icon(Icons.delete)],
              )),
        const PopupMenuItem<String>(
            value: 'manage_members',
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text("Administrar Miembros"), Icon(Icons.people)],
            )),
      ],
    );
  }

  _workspaceRenameDialog({required Function callbackAction}) {
    _workspaceNameController.text = widget.workspace.name;
    showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              content: Form(
                key: _workspaceRenameFormKey,
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
                    await callbackAction();
                  },
                  child: const Text('Renombrar'),
                ),
              ],
            ));
  }

  _renameWorkspace() async {
    if (_workspaceRenameFormKey.currentState!.validate()) {
      String? message = await RepositoryManager()
          .workspaceRepository
          .renameWorkspace(widget.workspace.id!, _workspaceNameController.text);
      if (context.mounted) {
        if (message == null) {
          snackBar(context, 'Renombrado exitosamente!');
          _workspaceNameController.clear();
          widget.refreshWorkspaceList();
          Navigator.of(context).pop();
        } else {
          snackBar(context, message);
        }
      }
    }
  }

  _deleteWorkspace() async {
    String? message = await RepositoryManager()
        .workspaceRepository
        .deleteWorkspace(widget.workspace.id!);
    if (context.mounted) {
      if (message == null) {
        snackBar(context, 'Espacio de trabajo eliminado.');
        widget.refreshWorkspaceList();
      } else {
        snackBar(context, message);
      }
    }
  }
}
