import 'package:flutter/material.dart';
import 'package:task_master/domain/model/member_details.dart';
import 'package:task_master/presentation/RepositoryManager.dart';
import 'package:task_master/presentation/widgets/member_avatar.dart';
import 'package:task_master/util/utils.dart';

class MemberListTile extends StatefulWidget {
  final MemberDetails memberDetails;
  final VoidCallback refreshTable;

  const MemberListTile({super.key, required this.memberDetails, required this.refreshTable});

  @override
  State<MemberListTile> createState() => _MemberListTileState();
}

class _MemberListTileState extends State<MemberListTile> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: memberAvatar(widget.memberDetails),
      title: Row(
        children: [
          Expanded(flex: 2, child: Text(widget.memberDetails.name),),
          Expanded(flex: 2, child: Text(widget.memberDetails.email),),
          Expanded(
              child: Row(
            children: [
              PopupMenuButton<String>(
                tooltip: '',
                icon: const Icon(Icons.edit),
                onSelected: (String item) async {
                  switch (item) {
                    case 'change_member_role':
                      await _changeMemberRole();
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'change_member_role',
                    child: Text(
                        "Cambiar rol a: ${widget.memberDetails.role == 'Admin' ? 'Normal' : 'Admin'}"),
                  ),
                ],
              ),
              Text(widget.memberDetails.role),
            ],
          )),
          IconButton(
            onPressed: _removeMember,
            icon: const Icon(Icons.remove_circle_outline),
          )
        ],
      ),
    );
  }

  _changeMemberRole() async {
    String? message = await RepositoryManager()
        .workspaceRepository
        .changeMemberRole(
            widget.memberDetails.workspaceId,
            widget.memberDetails.userId,
            widget.memberDetails.role == 'Admin' ? 'Normal' : 'Admin');
    if (context.mounted) {
      if (message == null) {
        snackBar(context, 'Rol modificado correctamente');
        widget.refreshTable();
      } else {
        snackBar(context, message);
      }
    }
  }

  _removeMember() async {
    String? message = await RepositoryManager()
        .workspaceRepository
        .removeMemberFromWorkspace(
            widget.memberDetails.workspaceId, widget.memberDetails.userId);
    if (context.mounted) {
      if (message == null) {
        snackBar(context, 'Eliminado correctamente');
        widget.refreshTable();
      } else {
        snackBar(context, message);
      }
    }
  }
}
