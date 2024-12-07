import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutTab extends StatefulWidget {
  const AboutTab({super.key});
  
  @override
  State<AboutTab> createState() => _AboutTabState();
}

class _AboutTabState extends State<AboutTab> {
  String _appName = 'Unknown';
  String _appVersion = 'Unknown';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAppInfo();
  }

  Future<void> _fetchAppInfo() async {
    try {
      final PackageInfo info = await PackageInfo.fromPlatform();
      setState(() {
        _appName = info.appName;
        _appVersion = info.version;
        _isLoading = false;
      });
    } on Exception {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_isLoading)
            const CircularProgressIndicator()
          else ...[
            Text(
              _appName,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 8),
            Text(
              _appVersion,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ],
      ),
    );
  }
}

