import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:test_ws/data/model.dart';
import 'package:test_ws/providers/providers.dart';
import 'package:test_ws/util/util.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final style =
        ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));
    final controller = ref.read(textEditingControllerProvider);
    final error = useState(false);
    final loading = useState(false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 25),
            const Text("Set valid Api base Url in order to continue"),
            const SizedBox(height: 25),
            TextField(
                controller: controller,
                onChanged: (_) {
                  if (error.value) error.value = false;
                }),
            const SizedBox(height: 10),
            if (error.value)
              const Text(
                "* URL is not valid",
                style: TextStyle(color: Colors.red),
              ),
            if (loading.value) const Spacer(),
            if (loading.value) const Center(child: CircularProgressIndicator()),
            const Spacer(),
            ElevatedButton(
              style: style,
              onPressed: loading.value
                  ? null
                  : () async {
                      if (Uri.tryParse(controller.text) == null ||
                          !Uri.tryParse(controller.text)!.hasAbsolutePath) {
                        error.value = true;
                        return;
                      }
                      loading.value = true;
                      await ref.read(tasksServiceProvider).load();
                      loading.value = false;
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) {
                          return const ProScreen();
                        }),
                      );
                    },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 15),
                child: Text('Start counting process'),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class ProScreen extends HookConsumerWidget {
  const ProScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final style =
        ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));
    final tasksService = ref.watch(tasksServiceProvider);
    final persent = tasksService.persent;
    final loading = useState(false);
    Response? response;

    useEffect(
      () {
        ref.read(tasksServiceProvider).startCalculate();
        return null;
      },
      [null],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Process screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 100),
            Center(
                child: Text(
              persent == 100
                  ? "All calculations has finished, you can sendyour results to server"
                  : "Calculating ...",
              style: const TextStyle(fontSize: 23),
              textAlign: TextAlign.center,
            )),
            const SizedBox(height: 200),
            Center(
                child: Text(
              "$persent %",
              style: const TextStyle(fontSize: 30),
            )),
            if (loading.value) const Spacer(),
            if (loading.value) const Center(child: CircularProgressIndicator()),
            if (response != null && response.error) const SizedBox(height: 100),
            if (response != null && response.error)
              const Center(
                child: Text(
                  'response.message',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            const Spacer(),
            ElevatedButton(
              style: style,
              onPressed: persent == 100 && !loading.value
                  ? () async {
                      loading.value = true;
                      response = await ref.read(repositoryProvider).sendResults(
                          ref.read(uriProvider), tasksService.results);
                      loading.value = false;

                      if (response != null && !response!.error) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) {
                            return const ResultListScreen();
                          }),
                        );
                      }
                    }
                  : null,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 15),
                child: Text('Send results to server'),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class ResultListScreen extends HookConsumerWidget {
  const ResultListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(tasksServiceProvider).results;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Result list screen'),
      ),
      body: ListView.builder(
        itemCount: results.length,
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  return PreviewScreen(index: index);
                }),
              );
            },
            child: Container(
              child: Center(child: Text(results[index].pathStr)),
              height: 50,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.black.withOpacity(0.15)),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class PreviewScreen extends HookConsumerWidget {
  final int index;
  const PreviewScreen({Key? key, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksService = ref.watch(tasksServiceProvider);
    final task = tasksService.tasks![index];
    final result = tasksService.results[index];
    final taskMatrix = listStrToMatrix(task.field);
    final R = taskMatrix.length;
    final C = taskMatrix[0].length;

    int i = -1;
    int j = 0;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview screen'),
      ),
      body: Column(
        children: [
          GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: C,
              ),
              itemCount: R * C,
              itemBuilder: (BuildContext context, int index) {
                if (i == C - 1) {
                  i = -1;
                  j++;
                }
                i++;

                Color color = Colors.white;
                if (taskMatrix[j][i] == 1) {
                  color = Colors.black;
                }
                result.path.forEach((cell) {
                  if (cell.i == j && cell.j == i) {
                    color = const Color(0xFF4CAF50);
                  }
                  if (result.path.first.i == j && result.path.first.j == i) {
                    color = const Color(0xFF64FFDA);
                  }
                  if (result.path.last.i == j && result.path.last.j == i) {
                    color = const Color(0xFF009688);
                  }
                });
                return Card(
                  color: color,
                  child: Center(child: Text('($i,$j)')),
                );
              }),
          Text(result.pathStr),
        ],
      ),
    );
  }
}
