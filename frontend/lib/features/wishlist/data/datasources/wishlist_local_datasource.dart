import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/storage_keys.dart';

/// Lưu danh sách tour yêu thích trên máy (BE chưa có API wishlist).
/// Là [ChangeNotifier] để nút tim ở mọi màn hình cập nhật cùng lúc.
class WishlistLocalDataSource extends ChangeNotifier {
  final Set<String> _ids = {};
  bool _loaded = false;

  Set<String> get ids => Set.unmodifiable(_ids);

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    _ids
      ..clear()
      ..addAll(prefs.getStringList(StorageKeys.wishlistTourIds) ?? const []);
    _loaded = true;
    notifyListeners();
  }

  bool contains(String tourId) => _ids.contains(tourId);

  Future<void> toggle(String tourId) async {
    if (!_ids.remove(tourId)) _ids.add(tourId);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(StorageKeys.wishlistTourIds, _ids.toList());
  }
}
