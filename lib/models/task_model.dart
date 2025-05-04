class TaskModel {
  String? docId;
  String? id;
  String? text;
  bool? isDone;
  String? createBy;

  TaskModel();

  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel()
    ..id = json['id'] as String?
    ..text = json['text'] as String?
    ..isDone = json['isDone'] as bool?
    ..createBy = json['createBy'];

  Map<String, dynamic> toJson() {
    return {'id': id, 'text': text, 'isDone': isDone, 'createBy': createBy};
  }
}
