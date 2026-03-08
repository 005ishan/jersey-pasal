import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

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
  bool _isLoading = true;

  // ─── eSewa v2 UAT credentials ─────────────────────────────────────────────
  // 🔴 UAT / Testing — switch URLs + productCode + secretKey for production
  static const String _esewaUrl =
      'https://rc-epay.esewa.com.np/api/epay/main/v2/form';
  static const String _productCode = 'EPAYTEST';
  static const String _secretKey = '8gBm/:&EnhH.1/q';
  static const String _successUrl = 'https://developer.esewa.com.np/success';
  static const String _failureUrl = 'https://developer.esewa.com.np/failure';

  // ─── Generate HMAC-SHA256 signature ──────────────────────────────────────
  // eSewa v2 requires: sign("total_amount=X,transaction_uuid=Y,product_code=Z")
  String _generateSignature({
    required String totalAmount,
    required String transactionUuid,
    required String productCode,
  }) {
    final message =
        'total_amount=$totalAmount,transaction_uuid=$transactionUuid,product_code=$productCode';
    final key = utf8.encode(_secretKey);
    final bytes = utf8.encode(message);
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(bytes);
    return base64.encode(digest.bytes);
  }

  // ─── Build auto-submitting HTML form ─────────────────────────────────────
  String _buildEsewaForm() {
    final transactionUuid =
        'JP-${DateTime.now().millisecondsSinceEpoch}';
    final totalAmount = widget.amount.toStringAsFixed(2);
    final signature = _generateSignature(
      totalAmount: totalAmount,
      transactionUuid: transactionUuid,
      productCode: _productCode,
    );

    return '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <style>
    body { display:flex; align-items:center; justify-content:center;
           min-height:100vh; margin:0; background:#f5f9f4; font-family:sans-serif; }
    .msg { text-align:center; color:#3a7a28; }
    .spinner {
      width:40px; height:40px; margin:16px auto;
      border:4px solid rgba(96,187,70,0.2);
      border-top-color:#60BB46; border-radius:50%;
      animation:spin 0.8s linear infinite;
    }
    @keyframes spin { to { transform:rotate(360deg); } }
  </style>
</head>
<body>
  <div class="msg">
    <div class="spinner"></div>
    <p>Redirecting to eSewa...</p>
  </div>
  <form id="esewaForm" action="$_esewaUrl" method="POST">
    <input type="hidden" name="amount"                   value="${widget.amount.toStringAsFixed(2)}"/>
    <input type="hidden" name="tax_amount"               value="0"/>
    <input type="hidden" name="total_amount"             value="$totalAmount"/>
    <input type="hidden" name="transaction_uuid"         value="$transactionUuid"/>
    <input type="hidden" name="product_code"             value="$_productCode"/>
    <input type="hidden" name="product_service_charge"   value="0"/>
    <input type="hidden" name="product_delivery_charge"  value="0"/>
    <input type="hidden" name="success_url"              value="$_successUrl"/>
    <input type="hidden" name="failure_url"              value="$_failureUrl"/>
    <input type="hidden" name="signed_field_names"       value="total_amount,transaction_uuid,product_code"/>
    <input type="hidden" name="signature"                value="$signature"/>
  </form>
  <script>
    window.onload = function() {
      document.getElementById('esewaForm').submit();
    };
  </script>
</body>
</html>
''';
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
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialData: InAppWebViewInitialData(
              data: _buildEsewaForm(),
              baseUrl: WebUri('https://rc-epay.esewa.com.np'),
            ),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              domStorageEnabled: true,
              useHybridComposition: true,
              clearCache: true,
            ),
            onLoadStart: (controller, url) {
              setState(() => _isLoading = true);
              final urlStr = url.toString();
              debugPrint("🌐 Loading: $urlStr");

              // ✅ Success — eSewa redirects to success_url with ?data= param
              if (urlStr.contains('developer.esewa.com.np/success') ||
                  urlStr.contains('transaction_uuid') && urlStr.contains('status=COMPLETE')) {
                debugPrint("✅ eSewa Payment Success");
                Navigator.pop(context, true);
              }

              // ❌ Failure
              if (urlStr.contains('developer.esewa.com.np/failure') ||
                  urlStr.contains('status=FAILED') ||
                  urlStr.contains('status=CANCELED')) {
                debugPrint("❌ eSewa Payment Failed/Cancelled");
                Navigator.pop(context, false);
              }
            },
            onLoadStop: (controller, url) {
              setState(() => _isLoading = false);
            },
            onReceivedError: (controller, request, error) {
              debugPrint("❌ WebView error: ${error.description}");
              setState(() => _isLoading = false);
            },
          ),

          if (_isLoading)
            Container(
              color: Colors.white,
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Color(0xFF60BB46)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}