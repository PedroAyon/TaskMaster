import 'package:task_master/data/repository/auth_repository_impl.dart';
import 'package:task_master/data/repository/board_repository_impl.dart';
import 'package:task_master/data/repository/list_repository_impl.dart';
import 'package:task_master/data/repository/task_repository_impl.dart';
import 'package:task_master/data/repository/task_assignment_repository_impl.dart';
import 'package:task_master/data/repository/workspace_repository_impl.dart';
import 'package:task_master/domain/repository/auth_repository.dart';
import 'package:task_master/domain/repository/board_repository.dart';
import 'package:task_master/domain/repository/workspace_repository.dart';
import '../domain/repository/list_repository.dart';
import '../domain/repository/task_assignment_repository.dart';
import '../domain/repository/task_repository.dart';

class RepositoryManager {
  static final RepositoryManager _instance = RepositoryManager._internal();

  // Repository instances
  final AuthRepository authRepository = AuthRepositoryImpl();
  final WorkspaceRepository workspaceRepository = WorkspaceRepositoryImpl();
  final BoardRepository boardRepository = BoardRepositoryImpl();
  final ListRepository listRepository = ListRepositoryImpl();
  final TaskRepository taskRepository = TaskRepositoryImpl();
  final TaskAssignmentRepository taskAssignmentRepository =
      TaskAssignmentRepositoryImpl();

  factory RepositoryManager() {
    return _instance;
  }

  RepositoryManager._internal();
}
