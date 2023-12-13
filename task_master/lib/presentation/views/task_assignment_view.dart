import 'package:flutter/material.dart';
import 'package:task_master/presentation/RepositoryManager.dart';
import 'package:task_master/util/utils.dart';

import '../../domain/model/member_details.dart';
import '../../domain/model/task.dart';
import '../../domain/model/workspace.dart';
import '../widgets/log_out_button.dart';
import '../widgets/member_avatar.dart';
import '../widgets/member_list_tile.dart';
import '../widgets/not_found_page.dart';

class TaskAssignmentView extends StatefulWidget {
  const TaskAssignmentView({super.key});

  @override
  State<TaskAssignmentView> createState() => _TaskAssignmentViewState();
}

class _TaskAssignmentViewState extends State<TaskAssignmentView> {
  late Workspace? workspace;
  late Task? task;
  late Future<List<MemberDetails>> assignedMembersFuture;
  late Future<List<MemberDetails>> workspaceMembersFuture;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments
        as TaskAssignmentViewArguments?;
    workspace = args?.workspace;
    task = args?.task;
    return workspace != null ? view() : const NotFoundPage();
  }

  Widget view() {
    assignedMembersFuture = RepositoryManager()
        .taskAssignmentRepository
        .getMembersAssignedToTask(task!.id!);
    workspaceMembersFuture = RepositoryManager()
        .workspaceRepository
        .getWorkspaceMembers(workspace!.id!);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(task!.title),
        ),
        body: FutureBuilder(
            future:
                Future.wait([assignedMembersFuture, workspaceMembersFuture]),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<MemberDetails> assignedMembers = snapshot.data![0];
                List<int> assignedMemberIds =
                    assignedMembers.map((e) => e.userId).toList();
                List<MemberDetails> workspaceMembers = snapshot.data![1]
                    .where((element) =>
                        !assignedMemberIds.contains(element.userId))
                    .toList();
                return _body(assignedMembers, workspaceMembers);
              } else if (snapshot.hasError) {
                return const Center(child: Text('Something went wrong'));
              }
              return const Center(child: CircularProgressIndicator());
            }));
  }

  Widget _body(List<MemberDetails> assignedMembers,
      List<MemberDetails> workspaceMembers) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Text(
            'Personas asignadas',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onBackground,
              fontSize: 20,
            ),
          ),
        ),
        ListView(shrinkWrap: true, children: [
          for (MemberDetails member in assignedMembers)
            _memberListTile(member, true)
        ]),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Text(
            'Miembros del espacio de trabajo',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onBackground,
              fontSize: 20,
            ),
          ),
        ),
        Expanded(
            child: ListView(shrinkWrap: true, children: [
          for (MemberDetails member in workspaceMembers)
            _memberListTile(member, false)
        ])),
      ],
    );
  }

  Widget _memberListTile(MemberDetails member, bool assigned) {
    return ListTile(
      leading: memberAvatar(member),
      title: Row(
        children: [
          Expanded(child: Text(member.name)),
          Expanded(child: Text(member.email)),
          Expanded(
              child: IconButton(
            onPressed: () async {
              String? message;
              if (assigned) {
                message = await RepositoryManager()
                    .taskAssignmentRepository
                    .absolveTaskToMember(
                        task!.id!, member.userId, workspace!.id!);
              } else {
                message = await RepositoryManager()
                    .taskAssignmentRepository
                    .assignTaskToMember(
                        task!.id!, member.userId, workspace!.id!);
              }
              if (context.mounted && message != null) {
                snackBar(context, message);
              }
              _refresh();
            },
            icon: Icon(assigned ? Icons.remove_circle_outline : Icons.add),
          ))
        ],
      ),
    );
  }

  _refresh() {
    setState(() {});
  }
}
