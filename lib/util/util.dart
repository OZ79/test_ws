import 'package:test_ws/util/shortest_path.dart';

void printMatrix(List<List<int>> matrix) {
  int n = 0;
  matrix.forEach((i) {
    n++;
    print('$n $i');
  });
}

List<int> srtToList(String str) {
  return str.split('').map((i) {
    if (i == '.') return 0;
    return 1;
  }).toList();
}

List<List<int>> listStrToMatrix(List<dynamic> list) {
  return List.generate(list.length, (i) {
    return srtToList(list[i]);
  });
}

String listCellToPathStr(List<Cell> list) {
  String str = '';
  list.forEach((cell) {
    str = str + '(${cell.j},${cell.i})' + (list.last == cell ? '' : '->');
  });
  return str;
}
