import 'dart:convert';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/booking.dart';

/// Only signed fields from the BE are submitted; the app never receives a key.
String checkoutForm(PaymentCheckout checkout) {
  final uri = Uri.tryParse(checkout.checkoutUrl ?? '');
  if (uri == null ||
      uri.scheme != 'https' ||
      uri.userInfo.isNotEmpty ||
      uri.port != 443 ||
      uri.hasQuery ||
      uri.hasFragment ||
      !['pay-sandbox.sepay.vn', 'pay.sepay.vn'].contains(uri.host) ||
      uri.path != '/v1/checkout/init' ||
      checkout.fields['signature'] == null) {
    throw const FormatException('Invalid checkout');
  }
  const encoder = HtmlEscape(HtmlEscapeMode.attribute);
  final inputs = checkout.fields.entries
      .map(
        (e) =>
            '<input type="hidden" name="${encoder.convert(e.key)}" value="${encoder.convert(e.value)}">',
      )
      .join();
  final primary = AppColors.primary.toARGB32().toRadixString(16).substring(2);
  final background = AppColors.background
      .toARGB32()
      .toRadixString(16)
      .substring(2);
  return '''<!doctype html><html lang="vi"><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Thanh toán SePay</title>
<style>
*{box-sizing:border-box}body{margin:0;padding:24px;min-height:100vh;display:grid;
place-items:center;background:#$background;color:#$primary;font:15px/1.6 system-ui,sans-serif}
main{width:100%;max-width:420px;padding:24px;border:1px solid #e2e8f0;border-radius:20px;
background:white;text-align:center}h1{font-size:20px;margin:0 0 12px}p{color:#475569}
button{width:100%;min-height:48px;padding:12px;border:0;border-radius:12px;
background:#$primary;color:white;font:600 15px system-ui,sans-serif;cursor:pointer}
button:focus-visible{outline:3px solid #fdc700;outline-offset:3px}
</style><main><h1>Đang chuyển đến SePay</h1>
<p>Nếu trang chưa tự chuyển, chọn tiếp tục để mở thanh toán.</p>
<form id="checkout" method="post" accept-charset="UTF-8" action="${encoder.convert(uri.toString())}">
$inputs<button type="submit">Tiếp tục thanh toán</button></form>
<script>document.getElementById('checkout').submit();</script></main></html>''';
}

/// Match only the configured return URL for this specific payment.
bool isCheckoutReturn(String url, PaymentCheckout checkout) {
  final actual = Uri.tryParse(url);
  if (actual == null) return false;
  return ['success_url', 'error_url', 'cancel_url'].any((key) {
    final expected = Uri.tryParse(checkout.fields[key] ?? '');
    return expected != null &&
        expected.hasAuthority &&
        actual.scheme == expected.scheme &&
        actual.host == expected.host &&
        actual.port == expected.port &&
        actual.path == expected.path &&
        actual.queryParameters['paymentId'] == checkout.paymentId;
  });
}
