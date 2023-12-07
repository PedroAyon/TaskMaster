import 'package:flutter/material.dart';
import 'package:task_master/presentation/widgets/board_grid.dart';
import 'package:task_master/presentation/widgets/log_out_button.dart';
import 'package:task_master/presentation/widgets/member_management.dart';
import 'package:task_master/presentation/widgets/workspace_list.dart';

import '../../domain/model/board.dart';
import '../../domain/model/workspace.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late Widget? mainPanel;

  @override
  void initState() {
    super.initState();
    mainPanel = const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("TaskMaster"),
        actions: [logOutIconButton(context)],
      ),
      body: Center(
          child: Row(
        children: [
          Container(
              width: 400,
              color: const Color.fromRGBO(240, 240, 240, 1),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: WorkspaceList(
                  openWorkspacePanel: _workspacePanel,
                  openMemberManagementPanel: _workspaceManagementPanel,
                  clearMainPanel: _clearMainPanel,
                ),
              )),
          Expanded(child: mainPanel!)
        ],
      )),
    );
  }

  _workspacePanel(Workspace workspace) {
    setState(() {
      mainPanel = BoardGrid(workspace: workspace, onBoardClick: _boardPanel,);
    });
  }

  _workspaceManagementPanel(Workspace workspace) {
    setState(() {
      mainPanel = MemberManagement(workspace: workspace);
    });
  }

  _clearMainPanel() {
    setState(() {
      mainPanel = const SizedBox.shrink();
    });
  }

  _boardPanel(Board board) {
    Navigator.pushNamed(context, '/board', arguments: board);
  }

}
