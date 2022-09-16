import 'dart:convert';
import 'dart:io';

import 'package:test_ws/data/model.dart';
import 'package:http/http.dart' as http;

abstract class RepositoryApi {
  Future<List<Task>> fetchTasks(Uri uri);
  Future<Response> sendResults(Uri uri, List<Result> results);
}

class RepositoryImp implements RepositoryApi {
  @override
  Future<List<Task>> fetchTasks(Uri uri) async {
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body)['data'];
        return parsed.map<Task>((json) => Task.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Response> sendResults(Uri uri, List<Result> results) async {
    try {
      final response = await http.post(
        uri,
        headers: {
          HttpHeaders.acceptHeader: 'application/json',
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: jsonEncode(results.map((r) => r.toJson()).toList()),
      );

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        return Response.fromJson(parsed);
      } else {
        throw Exception('Failed');
      }
    } catch (e) {
      rethrow;
    }
  }
}
