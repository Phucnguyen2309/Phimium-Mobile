import 'dart:convert';

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
  return '''<!doctype html><html lang="vi"><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<form id="checkout" method="post" accept-charset="UTF-8" action="${encoder.convert(uri.toString())}">
$inputs<button type="submit">Tiếp tục thanh toán</button></form>
<script>document.getElementById('checkout').submit();</script></html>''';
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
