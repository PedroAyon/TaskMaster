import 'package:flutter/material.dart';
import 'package:task_master/domain/model/workspace.dart';
import 'package:task_master/presentation/RepositoryManager.dart';
import 'package:task_master/presentation/widgets/member_list_tile.dart';
import 'package:task_master/util/constants.dart';
import 'package:task_master/util/utils.dart';

import '../../domain/model/member_details.dart';

class MemberManagement extends StatefulWidget {
  final Workspace workspace;

  const MemberManagement({super.key, required this.workspace});

  @override
  State<MemberManagement> createState() => _MemberManagementState();
}

class _MemberManagementState extends State<MemberManagement> {
  late Future<List<MemberDetails>> members;
  final _newMemberEmailFormKey = GlobalKey<FormState>();
  final TextEditingController _newMemberEmailController =
      TextEditingController();
  String _newMemberRole = memberRoles.first;

  @override
  Widget build(BuildContext context) {
    members = RepositoryManager()
        .workspaceRepository
        .getWorkspaceMembers(widget.workspace.id!);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Text(
            widget.workspace.name,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onBackground,
              fontSize: 40,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Text(
            'Agregar Miembro',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onBackground,
              fontSize: 20,
            ),
          ),
        ),
        _addMemberForm(),
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            alignment: Alignment.centerLeft,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Lista de Miembros',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground,
                      fontSize: 20,
                    )),
                const SizedBox(height: 16),
                _memberListTable()
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _addMemberForm() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
          key: _newMemberEmailFormKey,
          child: Row(
            children: [
              SizedBox(
                width: 300,
                child: TextFormField(
                  controller: _newMemberEmailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                      labelText: 'email',
                      border: OutlineInputBorder(),
                      hintText: 'example@domain.com'),
                ),
              ),
              const SizedBox(width: 32),
              SizedBox(
                width: 300,
                child: DropdownButtonFormField(
                  decoration:
                      const InputDecoration(border: OutlineInputBorder()),
                  value: memberRoles.first,
                  onChanged: (String? value) {
                    setState(() {
                      _newMemberRole = value!;
                    });
                  },
                  items:
                      memberRoles.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(width: 32),
              ElevatedButton.icon(
                icon: Icon(
                  Icons.add,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      Theme.of(context).colorScheme.primary),
                ),
                onPressed: _addMember,
                label: Text(
                  'Agregar',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                ),
              ),
            ],
          )),
    );
  }

  Widget _memberListTable() {
    return FutureBuilder(
        future: members,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text('Something went wrong'));
          }
          return ListView(
              shrinkWrap: true,
              children: [
            for (MemberDetails member in snapshot.data!)
              MemberListTile(memberDetails: member, refreshTable: _refreshMembers,)
          ]);
        });
  }

  _addMember() async {
    if (_newMemberEmailFormKey.currentState!.validate()) {
      String email = _newMemberEmailController.text;
      String? message = await RepositoryManager()
          .workspaceRepository
          .addMemberToWorkspace(widget.workspace.id!, email, _newMemberRole);
      if (context.mounted) {
        if (message != null) {
          snackBar(context, message);
        } else {
          snackBar(context, 'Miembro agregado correctamente');
          _newMemberEmailController.clear();
          _refreshMembers();
        }
      }
    }
  }

  _refreshMembers() {
    setState(() {
      // members = RepositoryManager()
      //     .workspaceRepository
      //     .getWorkspaceMembers(widget.workspace.id!);
    });
  }
}
