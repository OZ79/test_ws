import 'package:test_ws/util/shortest_path.dart';

class Task {
  final String id;
  final List<dynamic> field;
  final Map<String, dynamic> start;
  final Map<String, dynamic> end;

  const Task({
    required this.id,
    required this.field,
    required this.start,
    required this.end,
  });

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'],
        field: json['field'],
        start: json['start'],
        end: json['end'],
      );

  @override
  String toString() {
    return 'Task(id: $id, field: $field, start: $start, end: $end)';
  }
}

class Result {
  final String id;
  final List<Cell> path;
  final String pathStr;

  const Result({
    required this.id,
    required this.path,
    required this.pathStr,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        "result": {
          "steps": path.map((cell) => {"x": cell.j, "y": cell.i}).toList(),
          "path": pathStr
        }
      };

  @override
  String toString() {
    return 'Result(id: $id, path: $pathStr,)';
  }
}

class Response {
  final bool error;
  final String message;

  const Response({
    required this.error,
    required this.message,
  });

  factory Response.fromJson(Map<String, dynamic> json) => Response(
        error: json['error'],
        message: json['message'],
      );

  @override
  String toString() {
    return 'Response(error: $error, message: $message)';
  }
}
