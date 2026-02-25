import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'dart:io';

class EsewaGatewayScreen extends StatefulWidget {
  final double amount;

  const EsewaGatewayScreen({
    Key? key,
    required this.amount,
  }) : super(key: key);

  @override
  State<EsewaGatewayScreen> createState() => _EsewaGatewayScreenState();
}

class _EsewaGatewayScreenState extends State<EsewaGatewayScreen> {
  late final WebViewController _controller;

  bool _isLoading = true;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    try {
      if (Platform.isAndroid) {
        AndroidWebViewController.enableDebugging(true);
      }

      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.white)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (_) {
              setState(() {
                _isLoading = true;
                _isError = false;
              });
            },

            onPageFinished: (_) {
              // ⭐ Grace delay prevents fake failure detection
              Future.delayed(const Duration(seconds: 1), () {
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                  });
                }
              });
            },

            onWebResourceError: (_) {
              // ⭐ DO NOT show error immediately

              Future.delayed(const Duration(seconds: 5), () {
                if (mounted && _isLoading) {
                  setState(() {
                    _isLoading = false;
                    _isError = true;
                  });
                }
              });
            },
          ),
        );

      _loadGateway();
    } catch (e) {
      debugPrint("WebView init error: $e");

      setState(() {
        _isLoading = false;
        _isError = true;
      });
    }
  }

  Future<void> _loadGateway() async {
    try {
      final htmlContent =
          await rootBundle.loadString('assets/esewa_demo_gateway.html');

      final updatedHtml = htmlContent.replaceFirst(
        "const AMOUNT = 'Rs 2,450.00';",
        "const AMOUNT = 'Rs ${widget.amount.toStringAsFixed(2)}';",
      );

      await _controller.loadHtmlString(
        updatedHtml,
        baseUrl: 'https://jerseypasal.com/',
      );
    } catch (e) {
      debugPrint("HTML load error: $e");

      setState(() {
        _isLoading = false;
        _isError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("eSewa Payment"),
        backgroundColor: const Color(0xFF60BB46),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isError ? _buildErrorView() : _buildWebView(),
    );
  }

  Widget _buildWebView() {
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_isLoading) _buildLoader(),
      ],
    );
  }

  Widget _buildLoader() {
    return Container(
      color: Colors.white,
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            Color(0xFF60BB46),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Payment gateway failed to load',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isError = false;
                _isLoading = true;
              });

              _initializeWebView();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF60BB46),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}