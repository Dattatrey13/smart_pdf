import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'api_service.dart';
import 'chat_screen.dart';
import 'core/theme/app_theme.dart';
import 'features/summary/summary_tab.dart';
import 'features/search/quick_search_tab.dart';
import 'features/upload/upload_panel.dart';

void main() {
  runApp(const SmartPdfApp());
}

class SmartPdfApp extends StatelessWidget {
  const SmartPdfApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart PDF',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final ApiService _api = ApiService();
  File? _selectedFile;
  bool _uploading = false;
  bool _uploaded = false;
  String? _status;
  String? _summary;
  bool _summaryLoading = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
        _status = null;
      });
    }
  }

  Future<void> _testConnection() async {
    setState(() => _status = 'Testing connection...');
    final connected = await _api.testConnection();
    setState(() {
      _status = connected ? '✓ Backend is online!' : '✗ Cannot reach backend';
    });
  }

  Future<void> _upload() async {
    if (_selectedFile == null) return;
    setState(() {
      _uploading = true;
      _status = 'Uploading & indexing PDF...';
    });
    try {
      final docId = await _api.uploadPdf(_selectedFile!);
      setState(() {
        _uploaded = true;
        _status = '✓ Ready — Doc ID: $docId';
      });
    } catch (e) {
      setState(() => _status = 'Upload error: ${e.toString()}');
    } finally {
      setState(() => _uploading = false);
    }
  }

  Future<void> _loadSummary() async {
    if (!_uploaded) return;
    setState(() {
      _summaryLoading = true;
      _summary = null;
    });
    try {
      final s = await _api.getSummary();
      setState(() => _summary = s);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Summary failed: ${e.toString()}'),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() => _summaryLoading = false);
    }
  }

  Future<List<Map<String, dynamic>>> _runSearch(String query) async {
    return await _api.quickSearch(query);
  }

  @override
  Widget build(BuildContext context) {
    final canUse = _uploaded && !_uploading;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: Column(
        children: [
          // Custom app bar
          _AppHeader(),
          // Upload panel
          UploadPanel(
            selectedFile: _selectedFile,
            uploading: _uploading,
            uploaded: _uploaded,
            status: _status,
            onPickPdf: _pickPdf,
            onUpload: _upload,
            onTestConnection: _testConnection,
          ),
          // Tabs
          Expanded(
            child: Column(
              children: [
                Container(
                  color: AppTheme.surface,
                  child: TabBar(
                    controller: _tabController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    indicator: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    splashBorderRadius: BorderRadius.circular(10),
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(
                        height: 44,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble_rounded, size: 16),
                            SizedBox(width: 6),
                            Text('Ask AI'),
                          ],
                        ),
                      ),
                      Tab(
                        height: 44,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.auto_awesome_rounded, size: 16),
                            SizedBox(width: 6),
                            Text('Summary'),
                          ],
                        ),
                      ),
                      Tab(
                        height: 44,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.manage_search_rounded, size: 16),
                            SizedBox(width: 6),
                            Text('Search'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Ask AI
                      canUse
                          ? ChatScreen(api: _api)
                          : _LockedTab(
                              icon: Icons.chat_bubble_rounded,
                              title: 'Ask AI',
                              message: 'Upload a PDF to start chatting with AI',
                            ),
                      // Summary
                      canUse
                          ? SummaryTab(
                              summary: _summary,
                              onGenerate: _loadSummary,
                              isLoading: _summaryLoading,
                            )
                          : _LockedTab(
                              icon: Icons.auto_awesome_rounded,
                              title: 'Summary',
                              message: 'Upload a PDF to generate an AI summary',
                            ),
                      // Search
                      canUse
                          ? QuickSearchTab(onSearch: _runSearch)
                          : _LockedTab(
                              icon: Icons.manage_search_rounded,
                              title: 'Search',
                              message: 'Upload a PDF to search within it',
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AppHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.fromLTRB(20, top + 14, 20, 14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.primary.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Logo
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.picture_as_pdf_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Smart PDF',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.onSurface,
                  fontFamily: 'Outfit',
                  letterSpacing: 0.3,
                ),
              ),
              Text(
                'AI-Powered Document Intelligence',
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.onSurfaceMuted,
                  fontFamily: 'Outfit',
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.primary.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppTheme.success,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.success.withOpacity(0.8),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 5),
                const Text(
                  'Claude AI',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                    fontFamily: 'Outfit',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LockedTab extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _LockedTab({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: AppTheme.surfaceCard,
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF2A2A4A),
                  width: 1.5,
                ),
              ),
              child: Icon(icon, color: AppTheme.onSurfaceMuted, size: 30),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.onSurface,
                fontFamily: 'Outfit',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.onSurfaceMuted,
                fontFamily: 'Outfit',
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.primary.withOpacity(0.25),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_upward_rounded,
                      color: AppTheme.primary, size: 14),
                  SizedBox(width: 6),
                  Text(
                    'Upload a PDF above to unlock',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.primary,
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}