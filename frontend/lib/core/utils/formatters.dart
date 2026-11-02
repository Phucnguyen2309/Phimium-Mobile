import 'package:intl/intl.dart';

/// Định dạng tiền, ngày giờ dùng chung
class Formatters {
  Formatters._();

  static final NumberFormat _vnd =
      NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);

  /// 350000 -> "350.000 đ"
  static String vnd(num? value) => value == null ? '--' : _vnd.format(value);

  /// "2026-11-20" -> "20/11/2026"
  static String date(DateTime? value) =>
      value == null ? '--' : DateFormat('dd/MM/yyyy').format(value);

  /// DateTime -> "18:30 20/11/2026"
  static String dateTime(DateTime? value) =>
      value == null ? '--' : DateFormat('HH:mm dd/MM/yyyy').format(value.toLocal());

  /// "08:30:00" -> "08:30"
  static String time(String? hhmmss) {
    if (hhmmss == null || hhmmss.length < 5) return hhmmss ?? '--';
    return hhmmss.substring(0, 5);
  }

  /// 150 phút -> "2 giờ 30 phút"
  static String duration(int? minutes) {
    if (minutes == null || minutes <= 0) return '--';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h == 0) return '$m phút';
    if (m == 0) return '$h giờ';
    return '$h giờ $m phút';
  }

  /// Đọc số từ JSON (BigDecimal của BE có thể là num hoặc String)
  static double? toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static int? toInt(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static DateTime? toDate(dynamic value) =>
      value == null ? null : DateTime.tryParse(value.toString());
}
