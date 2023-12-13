import 'package:flutter/material.dart';
import 'package:task_master/presentation/RepositoryManager.dart';

import '../../domain/model/member_details.dart';
import 'member_avatar.dart';

class AssignedMembersWidget extends StatefulWidget {
  final Function onTapCallback;
  final int taskId;
  final bool cardView;

  const AssignedMembersWidget(
      {super.key,
      required this.taskId,
      required this.onTapCallback,
      this.cardView = false});

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
            if (widget.cardView) return _body(snapshot.data);
            return _inkWell(_body(snapshot.data));
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

  Widget _inkWell(Widget body) {
    return InkWell(
      onTap: () {
        widget.onTapCallback();
        _refresh();
      },
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      child: body,
    );
  }

  Widget _body(List<MemberDetails>? members) {
    return Row(
      children: [
        if (!widget.cardView || members!.isEmpty)
          Row(
            children: [
              Icon(members!.isNotEmpty ? Icons.group : Icons.group_off),
              const SizedBox(
                width: 8,
              ),
            ],
          ),
        for (int i = 0;
            i < members.length && i < (widget.cardView ? 3 : 4);
            i++)
          memberAvatar(members[i]),
        if ((members.length > 3 && widget.cardView) || (members.length > 4 && !widget.cardView))
          const CircleAvatar(
            child: Icon(Icons.more_horiz),
          ),

        if (members.isNotEmpty && !widget.cardView)
          const Tooltip(
            message: 'Administrar asignaciones',
            child: CircleAvatar(
              child: Icon(Icons.manage_accounts),
            ),
          )
        else if (!widget.cardView)
          const CircleAvatar(
            child: Icon(Icons.add),
          )
      ],
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
