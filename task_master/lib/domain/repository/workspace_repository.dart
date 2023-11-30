import 'package:task_master/domain/model/member_details.dart';

import '../model/workspace.dart';

abstract class WorkspaceRepository {
  Future<List<Workspace>> getWorkspaceList();
  Future<bool> createWorkspace(Workspace workspace);
  Future<bool> deleteWorkspace(int workspaceId);
  Future<bool> addMemberToWorkspace(int workspaceId, String email, String role);
  Future<bool> removeMemberFromWorkspace(int workspaceId, String email);
  Future<bool> changeMemberRole(int workspaceId, String email, String role);
  Future<MemberDetails> getWorkspaceMembers(int workspaceId);
}