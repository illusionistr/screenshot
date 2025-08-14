import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../../config/dependency_injection.dart';
import '../../../core/services/storage_service.dart';

/// Debug panel to help diagnose Firebase Storage issues
/// Remove this widget in production
class StorageDebugPanel extends StatefulWidget {
  const StorageDebugPanel({super.key});

  @override
  State<StorageDebugPanel> createState() => _StorageDebugPanelState();
}

class _StorageDebugPanelState extends State<StorageDebugPanel> {
  final StorageService _storageService = serviceLocator<StorageService>();
  String _status = 'Not tested';
  bool _isLoading = false;
  Map<String, dynamic> _diagnostics = {};

  @override
  void initState() {
    super.initState();
    _runDiagnostics();
  }

  Future<void> _runDiagnostics() async {
    setState(() {
      _isLoading = true;
      _status = 'Running diagnostics...';
    });

    final diagnostics = <String, dynamic>{};

    // Firebase configuration
    diagnostics['Project ID'] = Firebase.app().options.projectId;
    diagnostics['Storage Bucket'] = FirebaseStorage.instance.bucket;
    
    // Storage connection test
    try {
      final connected = await _storageService.testStorageConnection();
      diagnostics['Storage Connection'] = connected ? '✅ Connected' : '❌ Failed';
      
      if (connected) {
        _status = '✅ Firebase Storage is working';
      } else {
        _status = '❌ Storage connection failed';
      }
    } catch (e) {
      diagnostics['Storage Connection'] = '❌ Error: $e';
      _status = '❌ Storage test failed';
    }

    // Storage rules status
    try {
      final ref = FirebaseStorage.instance.ref('test/connectivity-check.txt');
      await ref.putString('test');
      await ref.delete();
      diagnostics['Storage Rules'] = '✅ Upload allowed';
    } on FirebaseException catch (e) {
      if (e.code == 'storage/unauthorized') {
        diagnostics['Storage Rules'] = '❌ Rules block uploads';
      } else if (e.code == 'storage/unknown') {
        diagnostics['Storage Rules'] = '❌ Storage not enabled';
      } else {
        diagnostics['Storage Rules'] = '❌ ${e.code}: ${e.message}';
      }
    } catch (e) {
      diagnostics['Storage Rules'] = '❌ Error: $e';
    }

    setState(() {
      _diagnostics = diagnostics;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bug_report, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  'Storage Debug Panel',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _runDiagnostics,
                    tooltip: 'Refresh diagnostics',
                  ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Status
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _status.startsWith('✅') ? Colors.green[50] : Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _status.startsWith('✅') ? Colors.green : Colors.red,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _status.startsWith('✅') ? Icons.check_circle : Icons.error,
                    color: _status.startsWith('✅') ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _status,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: _status.startsWith('✅') ? Colors.green[800] : Colors.red[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Diagnostics details
            const Text(
              'Diagnostics',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            ..._diagnostics.entries.map((entry) {
              final isError = entry.value.toString().startsWith('❌');
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 140,
                      child: Text(
                        '${entry.key}:',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        entry.value.toString(),
                        style: TextStyle(
                          color: isError ? Colors.red[700] : Colors.green[700],
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            
            if (_diagnostics['Storage Rules']?.toString().contains('Storage not enabled') == true) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.warning, color: Colors.orange),
                        const SizedBox(width: 8),
                        Text(
                          'Action Required',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '1. Go to Firebase Console\n'
                      '2. Navigate to Storage section\n'
                      '3. Click "Get Started" to enable Storage\n'
                      '4. Refresh this panel to test again',
                      style: TextStyle(color: Colors.orange[800]),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () => _launchFirebaseConsole(),
                      icon: const Icon(Icons.open_in_new, size: 16),
                      label: const Text('Open Firebase Console'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _launchFirebaseConsole() {
    final projectId = Firebase.app().options.projectId;
    final url = 'https://console.firebase.google.com/project/$projectId/storage';
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Firebase Console URL copied to debug output:\n$url'),
        duration: const Duration(seconds: 3),
      ),
    );
    
    // Print URL to debug console for easy access
    print('🔗 Firebase Storage Console: $url');
  }
}