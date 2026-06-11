import '../../core/api/api_client.dart';

class StoreModel {
  final int id;
  final String name;
  final String? address;
  final String currency;

  StoreModel({
    required this.id,
    required this.name,
    this.address,
    this.currency = 'USD',
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id'] as int,
      name: json['name'] as String,
      address: json['address'] as String?,
      currency: json['currency'] as String? ?? 'USD',
    );
  }
}

class StoreService {
  Future<List<StoreModel>> getStores() async {
    final response = await ApiClient.dio.get('/stores/');
    final list = response.data as List;
    return list.map((e) => StoreModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<StoreModel> createStore({
    required String name,
    String? address,
    String currency = 'USD',
  }) async {
    final response = await ApiClient.dio.post(
      '/stores/',
      data: {
        'name': name,
        'address': address,
        'currency': currency,
      },
    );
    return StoreModel.fromJson(response.data['store'] as Map<String, dynamic>);
  }

  Future<StoreModel> updateStore({
    required int storeId,
    String? name,
    String? address,
    String? currency,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (address != null) data['address'] = address;
    if (currency != null) data['currency'] = currency;

    final response = await ApiClient.dio.patch('/stores/$storeId', data: data);
    return StoreModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<Map<String, dynamic>>> getNotifications(int storeId) async {
    final response = await ApiClient.dio.get('/stores/$storeId/notifications');
    return (response.data as List).cast<Map<String, dynamic>>();
  }
}
