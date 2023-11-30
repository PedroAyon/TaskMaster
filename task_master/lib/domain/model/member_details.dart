class MemberDetails {
  int workspaceId;
  int userId;
  String name;
  String email;
  String role;

  MemberDetails(
      {required this.workspaceId,
      required this.userId,
      required this.email,
      required this.name,
      required this.role});

  factory MemberDetails.fromJson(Map<String, dynamic> json) {
    return MemberDetails(
      workspaceId: json['workspace_id'],
      userId: json['userId'],
      email: json['email'],
      name: json['name'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'workspace_id': workspaceId,
      'user_id': userId,
      'email': email,
      'name': name,
      'role': role,
    };
  }
}

class MemberRoles {
  static String get admin => "Admin";

  static String get normal => "Normal";
}
