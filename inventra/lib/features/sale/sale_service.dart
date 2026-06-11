import '../../core/api/api_client.dart';

class StatsService {
  Future<Map<String, dynamic>> getDashboard({
    required int storeId,
    String? period,
    String? start,
    String? end,
  }) async {
    final response = await ApiClient.dio.get(
      '/stats/dashboard',
      queryParameters: {
        'store_id': storeId,
        if (period != null) 'period': period,
        if (start != null) 'start': start,
        if (end != null) 'end': end,
      },
    );
    return response.data as Map<String, dynamic>;
  }
}

class SaleService {
  Future<Map<String, dynamic>> createSale({
    required int storeId,
    required List<Map<String, dynamic>> items,
  }) async {
    final response = await ApiClient.dio.post(
      '/sales/',
      data: {'store_id': storeId, 'items': items},
    );
    return response.data as Map<String, dynamic>;
  }
}

class CartItem {
  final ProductRef product;
  int quantity;
  double sellPrice;

  CartItem({
    required this.product,
    this.quantity = 1,
    required this.sellPrice,
  });

  double get total => sellPrice * quantity;
}

class ProductRef {
  final int id;
  final String name;
  final double defaultSellPrice;
  final int availableStock;

  ProductRef({
    required this.id,
    required this.name,
    required this.defaultSellPrice,
    required this.availableStock,
  });
}
