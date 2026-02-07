import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class ApiService {
  // Adjust for your backend IP/port
  static const String baseUrl = 'http://10.0.2.2:8000'; // Android emulator
  // On real device use your PC IP address.

  String? _docId;

  String? get docId => _docId;

  Future<String> uploadPdf(File file) async {
    final uri = Uri.parse('$baseUrl/upload');
    final request = http.MultipartRequest('POST', uri);

    request.files.add(
      await http.MultipartFile.fromPath('file', file.path),
    );

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _docId = data['doc_id'] as String;
      return _docId!;
    } else {
      throw Exception('Upload failed: ${response.body}');
    }
  }

  Future<String> askQuestion(String question) async {
    if (_docId == null) {
      throw Exception('No document uploaded');
    }
    final uri = Uri.parse('$baseUrl/ask');
    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'doc_id': _docId,
        'question': question,
      }),
    );
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      return data['answer'] as String;
    } else {
      throw Exception('Ask failed: ${resp.body}');
    }
  }

  Future<String> getSummary() async {
    if (_docId == null) {
      throw Exception('No document uploaded');
    }
    final uri = Uri.parse('$baseUrl/summary');
    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'doc_id': _docId}),
    );
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      return data['summary'] as String;
    } else {
      throw Exception('Summary failed: ${resp.body}');
    }
  }

  Future<List<Map<String, dynamic>>> quickSearch(String query) async {
    if (_docId == null) {
      throw Exception('No document uploaded');
    }
    final uri = Uri.parse('$baseUrl/search');
    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'doc_id': _docId, 'query': query}),
    );
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      final hits = (data['hits'] as List)
          .map((e) => {
                'text': e['text'],
                'score': e['score'],
              })
          .toList();
      return hits;
    } else {
      throw Exception('Search failed: ${resp.body}');
    }
  }
}