import '../model/task.dart';
import '../model/member_details.dart';

abstract class TaskAssignmentRepository {
  Future<List<Task>> getTasksAssignedToMember(int userId, int workspaceId, int? boardId);
  Future<List<MemberDetails>> getMembersAssignedToTask(int taskId);
  Future<String?> assignTaskToMember(int taskId, int userId, int workspaceId);
  Future<String?> absolveTaskToMember(int taskId, int userId, int workspaceId);
}