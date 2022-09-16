import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:test_ws/data/model.dart';
import 'package:test_ws/data/repository.dart';
import 'package:test_ws/util/util.dart';

import '../util/shortest_path.dart';

final textEditingControllerProvider = Provider<TextEditingController>(
  (ref) {
    return TextEditingController();
  },
);

final uriProvider = Provider<Uri>(
  (ref) {
    return Uri.parse(ref.read(textEditingControllerProvider).text);
  },
);

final repositoryProvider = Provider<RepositoryApi>(
  (ref) => RepositoryImp(),
);

final loadTasksProvider = FutureProvider<List<Task>>(
  (ref) async {
    return ref
        .read(repositoryProvider)
        .fetchTasks(ref.watch(uriProvider))
        .catchError((error) => <Task>[]);
  },
);

final resultProvider = FutureProvider.family<Result, int>(
  (ref, n) async {
    final tasks = await ref.read(loadTasksProvider.future);
    final task = tasks[n];
    final i = task.start['y'];
    final j = task.start['x'];
    final x = task.end['y'];
    final y = task.end['x'];
    List<Cell>? path =
        buidShortestPath(listStrToMatrix(task.field), i, j, x, y);
    if (path == null) return Result(id: task.id, path: [], pathStr: '---');
    return Result(id: task.id, path: path, pathStr: listCellToPathStr(path));
  },
);

class TasksService extends ChangeNotifier {
  final Ref ref;
  int calculated = 0;
  List<Task>? tasks;
  List<Result> results = [];

  TasksService({required this.ref});

  Future<void> load() async {
    tasks = await ref.read(loadTasksProvider.future);
  }

  Future<void> startCalculate() async {
    calculated = 0;
    results = [];
    for (int n = 0; n < tasks!.length; n++) {
      final result = await ref.read(resultProvider(n).future);
      results.add(result);
      await Future.delayed(const Duration(milliseconds: 200));
      calculated++;
      notifyListeners();
    }
  }

  num get persent => 100 * calculated / tasks!.length;
}

final tasksServiceProvider = ChangeNotifierProvider<TasksService>(
  (ref) {
    return TasksService(
      ref: ref,
    );
  },
);
