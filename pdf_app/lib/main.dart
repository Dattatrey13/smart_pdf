import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'api_service.dart';
import 'chat_screen.dart';

void main() {
  runApp(const SmartPdfApp());
}

class SmartPdfApp extends StatelessWidget {
  const SmartPdfApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart PDF',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _api = ApiService();
  File? _selectedFile;
  bool _uploading = false;
  bool _uploaded = false;
  String? _status;
  String? _summary;
  String _searchQuery = '';
  List<Map<String, dynamic>> _searchResults = [];

  Future<void> _pickPdf() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (res != null && res.files.single.path != null) {
      setState(() {
        _selectedFile = File(res.files.single.path!);
        _uploaded = false;
        _summary = null;
        _searchResults = [];
        _status = null;
      });
    }
  }

  Future<void> _upload() async {
    if (_selectedFile == null) return;
    setState(() {
      _uploading = true;
      _status = 'Uploading...';
    });

    try {
      final docId = await _api.uploadPdf(_selectedFile!);
      setState(() {
        _uploaded = true;
        _status = 'Uploaded. Doc ID: $docId';
      });
    } catch (e) {
      setState(() {
        _status = 'Upload error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _uploading = false;
      });
    }
  }

  Future<void> _loadSummary() async {
    if (!_uploaded) return;
    setState(() {
      _status = 'Generating summary...';
      _summary = null;
    });
    try {
      final s = await _api.getSummary();
      setState(() {
        _summary = s;
        _status = 'Summary ready';
      });
    } catch (e) {
      setState(() {
        _status = 'Summary error: ${e.toString()}';
      });
    }
  }

  Future<void> _runSearch() async {
    if (!_uploaded || _searchQuery.trim().isEmpty) return;
    setState(() {
      _status = 'Searching...';
      _searchResults = [];
    });
    try {
      final hits = await _api.quickSearch(_searchQuery.trim());
      setState(() {
        _searchResults = hits;
        _status = 'Search complete (${hits.length} hits)';
      });
    } catch (e) {
      setState(() {
        _status = 'Search error: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final canUse = _uploaded && !_uploading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart PDF'),
      ),
      body: Column(
        children: [
          Material(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedFile != null
                              ? 'Selected: ${_selectedFile!.path.split(Platform.pathSeparator).last}'
                              : 'No PDF selected',
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.picture_as_pdf),
                        label: const Text('Pick PDF'),
                        onPressed: _uploading ? null : _pickPdf,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        icon: _uploading
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.cloud_upload),
                        label: const Text('Upload & Index'),
                        onPressed:
                            _selectedFile != null && !_uploading ? _upload : null,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _status ?? '',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(icon: Icon(Icons.chat), text: 'Ask AI'),
                      Tab(icon: Icon(Icons.summarize), text: 'Summary'),
                      Tab(icon: Icon(Icons.search), text: 'Quick Search'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Ask AI
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: canUse
                              ? ChatScreen(api: _api)
                              : const Center(
                                  child: Text('Upload a PDF first.'),
                                ),
                        ),
                        // Summary
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: canUse
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    ElevatedButton.icon(
                                      icon: const Icon(Icons.summarize),
                                      label: const Text('Generate Summary'),
                                      onPressed: _loadSummary,
                                    ),
                                    const SizedBox(height: 12),
                                    Expanded(
                                      child: SingleChildScrollView(
                                        child: Text(
                                          _summary ??
                                              'No summary yet. Tap "Generate Summary".',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : const Center(
                                  child: Text('Upload a PDF first.'),
                                ),
                        ),
                        // Quick Search
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: canUse
                              ? Column(
                                  children: [
                                    TextField(
                                      decoration: const InputDecoration(
                                        labelText: 'Search phrase...',
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged: (v) {
                                        _searchQuery = v;
                                      },
                                      onSubmitted: (_) => _runSearch(),
                                    ),
                                    const SizedBox(height: 8),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: ElevatedButton.icon(
                                        icon: const Icon(Icons.search),
                                        label: const Text('Search'),
                                        onPressed: _runSearch,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Expanded(
                                      child: _searchResults.isEmpty
                                          ? const Center(
                                              child: Text(
                                                  'No results. Run a search.'),
                                            )
                                          : ListView.builder(
                                              itemCount: _searchResults.length,
                                              itemBuilder: (context, index) {
                                                final hit =
                                                    _searchResults[index];
                                                return Card(
                                                  child: ListTile(
                                                    title: Text(
                                                      hit['text'] as String,
                                                      maxLines: 5,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    subtitle: Text(
                                                      'Score: ${(hit['score'] as num).toStringAsFixed(3)}',
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                    ),
                                  ],
                                )
                              : const Center(
                                  child: Text('Upload a PDF first.'),
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}