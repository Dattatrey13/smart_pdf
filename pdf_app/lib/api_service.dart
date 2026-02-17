import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class ApiService {
  // CONFIGURATION: Change this based on your setup
  // 
  // For Android Emulator:
    // static const String baseUrl = 'http://10.0.2.2:8000';
  //
  // For Physical Device on WiFi:
  //   This is set to: 10.110.86.166 (your PC's WiFi IP)
  //   Make sure your Android phone is on the same WiFi network
  //
  static const String baseUrl = 'http://10.110.86.166:8000'; // ← Physical Android device on WiFi
  
  // Make sure backend is running: python app.py

  static const Duration timeoutDuration = Duration(seconds: 60);

  String? _docId;

  String? get docId => _docId;

  // Test connection to backend
  Future<bool> testConnection() async {
    try {
      print('Testing connection to backend...');
      print('Backend URL: $baseUrl');
      
      final response = await http
          .get(Uri.parse('$baseUrl/'))
          .timeout(timeoutDuration, onTimeout: () {
        throw TimeoutException('Connection timeout - backend not responding');
      });

      if (response.statusCode == 200) {
        print('✓ Connection successful!');
        return true;
      } else {
        print('✗ Backend responded with status ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('✗ Connection failed: $e');
      print('');
      print('TROUBLESHOOTING:');
      print('1. Is the backend running? (python app.py)');
      print('2. Is it running on port 8000?');
      print('3. For Android emulator: backend should be at http://10.0.2.2:8000');
      print('4. For physical device: use your PC IP address instead');
      print('5. Check Windows Firewall allows port 8000');
      return false;
    }
  }

  Future<String> uploadPdf(File file) async {
    final uri = Uri.parse('$baseUrl/upload');
    print('API Request: POST $uri');
    print('Timeout: ${timeoutDuration.inSeconds} seconds');
    
    final request = http.MultipartRequest('POST', uri);

    request.files.add(
      await http.MultipartFile.fromPath('file', file.path),
    );

    try {
      print('Sending multipart request...');
      final streamed = await request.send().timeout(
        timeoutDuration,
        onTimeout: () {
          throw TimeoutException(
            'Upload timeout - backend took too long to respond',
          );
        },
      );
      
      final response = await http.Response.fromStream(streamed);

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _docId = data['doc_id'] as String;
        print('✓ Upload successful. Doc ID: $_docId');
        return _docId!;
      } else {
        print('✗ Upload failed with status code: ${response.statusCode}');
        throw Exception('Upload failed: ${response.body}');
      }
    } on TimeoutException catch (e) {
      print('✗ TIMEOUT ERROR: $e');
      print('');
      print('POSSIBLE CAUSES:');
      print('1. Backend server is not running');
      print('2. Backend server is not accessible at $baseUrl');
      print('3. Network/firewall blocking connection');
      print('4. Large file taking too long (increased timeout might help)');
      throw Exception('Connection timeout - $e');
    } catch (e) {
      print('✗ Upload error: ${e.runtimeType} - $e');
      throw Exception('Upload failed: $e');
    }
  }

  Future<String> askQuestion(String question) async {
    if (_docId == null) {
      throw Exception('No document uploaded');
    }
    final uri = Uri.parse('$baseUrl/ask');
    print('API Request: POST $uri');
    print('Question: $question');
    
    try {
      final resp = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'doc_id': _docId,
              'question': question,
            }),
          )
          .timeout(timeoutDuration);

      print('Response status code: ${resp.statusCode}');

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        print('✓ Answer received successfully');
        return data['answer'] as String;
      } else {
        print('✗ Ask failed with status code: ${resp.statusCode}');
        print('Response body: ${resp.body}');
        throw Exception('Ask failed: ${resp.body}');
      }
    } on TimeoutException catch (e) {
      print('✗ TIMEOUT: Backend not responding');
      throw Exception('Request timeout: $e');
    } catch (e) {
      print('✗ Error: $e');
      throw Exception('Ask failed: $e');
    }
  }

  Future<String> getSummary() async {
    if (_docId == null) {
      throw Exception('No document uploaded');
    }
    final uri = Uri.parse('$baseUrl/summary');
    print('API Request: POST $uri');
    print('Doc ID: $_docId');
    
    try {
      final resp = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'doc_id': _docId}),
          )
          .timeout(timeoutDuration);

      print('Response status code: ${resp.statusCode}');

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        print('✓ Summary received successfully');
        return data['summary'] as String;
      } else {
        print('✗ Summary failed with status code: ${resp.statusCode}');
        print('Response body: ${resp.body}');
        throw Exception('Summary failed: ${resp.body}');
      }
    } on TimeoutException catch (e) {
      print('✗ TIMEOUT: Backend not responding');
      throw Exception('Request timeout: $e');
    } catch (e) {
      print('✗ Error: $e');
      throw Exception('Summary failed: $e');
    }
  }

  Future<List<Map<String, dynamic>>> quickSearch(String query) async {
    if (_docId == null) {
      throw Exception('No document uploaded');
    }
    final uri = Uri.parse('$baseUrl/search');
    print('API Request: POST $uri');
    print('Query: $query');
    print('Doc ID: $_docId');
    
    try {
      final resp = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'doc_id': _docId, 'query': query}),
          )
          .timeout(timeoutDuration);

      print('Response status code: ${resp.statusCode}');

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final hits = (data['hits'] as List)
            .map((e) => {
                  'text': e['text'],
                  'score': e['score'],
                })
            .toList();
        print('✓ Search returned ${hits.length} results');
        return hits;
      } else {
        print('✗ Search failed with status code: ${resp.statusCode}');
        print('Response body: ${resp.body}');
        throw Exception('Search failed: ${resp.body}');
      }
    } on TimeoutException catch (e) {
      print('✗ TIMEOUT: Backend not responding');
      throw Exception('Request timeout: $e');
    } catch (e) {
      print('✗ Error: $e');
      throw Exception('Search failed: $e');
    }
  }
}