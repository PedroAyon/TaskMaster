import 'package:task_master/domain/model/member_details.dart';

import '../model/workspace.dart';

abstract class WorkspaceRepository {
  Future<List<Workspace>> getWorkspaceList();
  Future<String?> createWorkspace(String name);
  Future<String?> deleteWorkspace(int workspaceId);
  Future<String?> addMemberToWorkspace(int workspaceId, String email, String role);
  Future<String?> removeMemberFromWorkspace(int workspaceId, int userId);
  Future<String?> changeMemberRole(int workspaceId, int userId, String role);
  Future<List<MemberDetails>> getWorkspaceMembers(int workspaceId);
  Future<String> getUserRole(int workspaceId, int? userId);
  Future<String?> renameWorkspace(int workspaceId, String newName);
}