class AttachedFile {
  int taskId;
  String url;
  String fileName;

  AttachedFile({required this.taskId, required this.url, required this.fileName});

  factory AttachedFile.fromJson(Map<String, dynamic> json) {
    return AttachedFile(
      taskId: json['task_id'],
      url: json['url'],
      fileName: json['fileName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'task_id': taskId,
      'url': url,
      'fileName': fileName,
    };
  }
}
