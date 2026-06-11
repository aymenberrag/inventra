import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StoreStorage {
  static const storage = FlutterSecureStorage();

  static Future<void> saveStore({
    required int id,
    required String name,
    String currency = 'USD',
  }) async {
    await storage.write(key: 'store_id', value: id.toString());
    await storage.write(key: 'store_name', value: name);
    await storage.write(key: 'store_currency', value: currency);
  }

  static Future<int?> getStoreId() async {
    final id = await storage.read(key: 'store_id');
    return id != null ? int.tryParse(id) : null;
  }

  static Future<String?> getStoreName() async {
    return storage.read(key: 'store_name');
  }

  static Future<String> getCurrency() async {
    return await storage.read(key: 'store_currency') ?? 'USD';
  }

  static Future<void> updateStoreInfo({
    String? name,
    String? currency,
  }) async {
    if (name != null) {
      await storage.write(key: 'store_name', value: name);
    }
    if (currency != null) {
      await storage.write(key: 'store_currency', value: currency);
    }
  }

  static Future<void> clear() async {
    await storage.delete(key: 'store_id');
    await storage.delete(key: 'store_name');
    await storage.delete(key: 'store_currency');
  }
}
