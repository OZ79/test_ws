import 'dart:collection';

import 'package:test_ws/util/util.dart';

const MAX_DIST = 100000000;

class Cell {
  int i;
  int j;
  int dist;
  Cell(this.i, this.j, this.dist);

  @override
  String toString() {
    return '($i,$j | $dist)';
  }
}

bool _isValid(List<List<int>> mat, List<List<bool>> visited, int row, int col) {
  final R = mat.length;
  final C = mat[0].length;

  return (row >= 0) &&
      (row < R) &&
      (col >= 0) &&
      (col < C) &&
      mat[row][col] == 0 &&
      !visited[row][col];
}

List<List<int>>? bfs(List<List<int>> mat, int i, int j, int x, int y) {
  int minDist = MAX_DIST;

  final R = mat.length;
  final C = mat[0].length;

  //final row = [-1, 0, 0, 1];
  //final col = [0, -1, 1, 0];

  final row = [-1, 1, 1, -1, -1, 0, 0, 1];
  final col = [-1, 1, -1, 1, 0, -1, 1, 0];

  final List<List<int>> matDist = List.generate(R, (i) => List.filled(C, 0));

  final List<List<bool>> visited =
      List.generate(R, (i) => List.filled(C, false));

  final q = Queue<Cell>();

  visited[i][j] = true;
  q.add(Cell(i, j, 0));

  while (q.isNotEmpty) {
    Cell cell = q.removeFirst();

    i = cell.i;
    j = cell.j;
    int dist = cell.dist;

    matDist[i][j] = dist;

    if (i == x && j == y) {
      minDist = dist;
      break;
    }

    for (int k = 0; k < 8; k++) {
      if (_isValid(mat, visited, i + row[k], j + col[k])) {
        visited[i + row[k]][j + col[k]] = true;
        final cell = Cell(i + row[k], j + col[k], dist + (k < 4 ? 2 : 1));
        q.add(cell);
        matDist[cell.i][cell.j] = cell.dist;
      }
    }
  }
  //printMatrix(matDist);
  if (minDist != MAX_DIST) {
    //print("Shortest path length: $minDist");
  } else {
    print("Destination can't be reached");
    return null;
  }

  return matDist;
}

bool _isValidMove(List<List<int>> mat, int row, int col) {
  final R = mat.length;
  final C = mat[0].length;

  return (row >= 0) &&
      (row < R) &&
      (col >= 0) &&
      (col < C) &&
      mat[row][col] != 0;
}

List<Cell> _getShortestPath(
    List<List<int>> matDist, int i, int j, int x, int y) {
  final List<Cell> path = [];

  final row = [-1, 1, 1, -1, -1, 0, 0, 1];
  final col = [-1, 1, -1, 1, 0, -1, 1, 0];

  Cell cell = Cell(x, y, matDist[x][y]);
  path.add(Cell(cell.i, cell.j, cell.dist));

  while (cell.i != i || cell.j != j) {
    Cell next = Cell(0, 0, MAX_DIST);
    for (int k = 0; k < 8; k++) {
      final im = cell.i + row[k];
      final jm = cell.j + col[k];

      if (i == im && j == jm) {
        next = Cell(im, jm, matDist[im][jm]);
        break;
      } else if (_isValidMove(matDist, im, jm)) {
        int dist = matDist[im][jm];
        if (dist <= cell.dist && dist <= next.dist) {
          next = Cell(im, jm, dist);
        }
      }
    }
    cell = next;
    path.add(cell);
  }

  return path.reversed.toList();
}

List<Cell>? buidShortestPath(List<List<int>> mat, int i, int j, int x, int y) {
  final matDist = bfs(mat, i, j, x, y);
  if (matDist == null) return null;
  return _getShortestPath(matDist, i, j, x, y);
}

List<Cell>? buidShortestPathCompute(List<dynamic> params) {
  return buidShortestPath(
      params[0], params[1], params[2], params[3], params[4]);
}
