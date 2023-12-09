import 'package:flutter/material.dart';
import 'package:task_master/presentation/RepositoryManager.dart';

import '../../domain/model/member_details.dart';
import 'member_avatar.dart';

class AssignedMembersWidget extends StatefulWidget {
  final Function onTapCallback;
  final int taskId;

  const AssignedMembersWidget(
      {super.key, required this.taskId, required this.onTapCallback});

  @override
  State<AssignedMembersWidget> createState() => _AssignedMembersWidgetState();
}

class _AssignedMembersWidgetState extends State<AssignedMembersWidget> {
  late Future<List<MemberDetails>> memberListFuture;

  @override
  Widget build(BuildContext context) {
    memberListFuture = RepositoryManager()
        .taskAssignmentRepository
        .getMembersAssignedToTask(widget.taskId);
    return FutureBuilder(
        future: memberListFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return _avatars(snapshot.data);
          } else if (snapshot.hasError) {
            return const Row(children: [
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              Text('Error al cargar miembros asignados')
            ]);
          } else {
            return const SizedBox.shrink();
          }
        });
  }

  Widget _avatars(List<MemberDetails>? members) {
    return InkWell(
      onTap: () {
        widget.onTapCallback();
        _refresh();
      },
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      child: Row(
        children: [
          const Icon(Icons.group),
          const SizedBox(
            width: 8,
          ),
          if (members != null)
            for (int i = 0; i < members.length && i < 4; i++)
              memberAvatar(members[i]),
          if (members!.isNotEmpty)
            const CircleAvatar(
              child: Icon(Icons.manage_accounts),
            )
          else
            const CircleAvatar(
              child: Icon(Icons.add),
            )
        ],
      ),
    );
  }

  _refresh() {
    setState(() {
      // memberListFuture = RepositoryManager()
      //     .taskAssignmentRepository
      //     .getMembersAssignedToTask(widget.taskId);
    });
  }
}
