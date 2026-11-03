import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../domain/entities/booking.dart';
import '../widgets/checkout_form.dart';

class PaymentCheckoutPage extends StatefulWidget {
  final PaymentCheckout checkout;
  const PaymentCheckoutPage({super.key, required this.checkout});

  @override
  State<PaymentCheckoutPage> createState() => _PaymentCheckoutPageState();
}

class _PaymentCheckoutPageState extends State<PaymentCheckoutPage> {
  WebViewController? _controller;
  String? _error;
  bool _loading = true;
  bool _returned = false;

  @override
  void initState() {
    super.initState();
    _open();
  }

  Future<void> _open() async {
    try {
      final html = checkoutForm(widget.checkout);
      final controller = WebViewController();
      await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      await controller.setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            if (request.isMainFrame &&
                isCheckoutReturn(request.url, widget.checkout)) {
              if (mounted && !_returned) {
                _returned = true;
                Navigator.of(context).pop();
              }
              return NavigationDecision.prevent;
            }
            final scheme = Uri.tryParse(request.url)?.scheme;
            return ['https', 'about', 'data'].contains(scheme)
                ? NavigationDecision.navigate
                : NavigationDecision.prevent;
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
          onWebResourceError: (error) {
            if (mounted && error.isForMainFrame == true) {
              setState(() {
                _error = 'Không mở được trang thanh toán. Quay lại để thử lại.';
                _loading = false;
              });
            }
          },
        ),
      );
      if (!mounted) return;
      setState(() => _controller = controller);
      await controller.loadHtmlString(html);
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Không mở được thanh toán. Vui lòng quay lại và thử lại.';
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Thanh toán SePay')),
    body: _error != null
        ? Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_error!),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Quay lại kiểm tra thanh toán'),
                  ),
                ],
              ),
            ),
          )
        : Stack(
            children: [
              if (_controller != null) WebViewWidget(controller: _controller!),
              if (_loading) const LinearProgressIndicator(),
            ],
          ),
  );
}
