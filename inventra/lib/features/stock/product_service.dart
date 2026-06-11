import '../../core/api/api_client.dart';

class ProductModel {
  final int id;
  final int storeId;
  final int? categoryId;
  final String name;
  final String barcode;
  final double buyPrice;
  final double sellPrice;
  final int quantity;
  final int lowStockThreshold;

  ProductModel({
    required this.id,
    required this.storeId,
    this.categoryId,
    required this.name,
    required this.barcode,
    required this.buyPrice,
    required this.sellPrice,
    required this.quantity,
    required this.lowStockThreshold,
  });

  bool get isLowStock => quantity <= lowStockThreshold;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int,
      storeId: json['store_id'] as int,
      categoryId: json['category_id'] as int?,
      name: json['name'] as String,
      barcode: json['barcode'] as String,
      buyPrice: (json['buy_price'] as num).toDouble(),
      sellPrice: (json['sell_price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      lowStockThreshold: json['low_stock_threshold'] as int? ?? 5,
    );
  }
}

class CategoryModel {
  final int id;
  final String name;
  final int storeId;

  CategoryModel({
    required this.id,
    required this.name,
    required this.storeId,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      storeId: json['store_id'] as int,
    );
  }
}

class ProductService {
  Future<List<ProductModel>> getProducts({
    required int storeId,
    int? categoryId,
  }) async {
    final response = await ApiClient.dio.get(
      '/products/',
      queryParameters: {
        'store_id': storeId,
        if (categoryId != null) 'category_id': categoryId,
      },
    );
    final list = response.data as List;
    return list.map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ProductModel> createProduct({
    required int storeId,
    required String name,
    required String barcode,
    required double buyPrice,
    required double sellPrice,
    int quantity = 0,
    int? categoryId,
  }) async {
    final response = await ApiClient.dio.post(
      '/products/',
      data: {
        'store_id': storeId,
        'name': name,
        'barcode': barcode,
        'buy_price': buyPrice,
        'sell_price': sellPrice,
        'quantity': quantity,
        if (categoryId != null) 'category_id': categoryId,
      },
    );
    return ProductModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ProductModel> updateProduct({
    required int productId,
    int? quantity,
    int? quantityDelta,
    double? buyPrice,
    double? sellPrice,
    String? name,
  }) async {
    final data = <String, dynamic>{};
    if (quantity != null) data['quantity'] = quantity;
    if (quantityDelta != null) data['quantity_delta'] = quantityDelta;
    if (buyPrice != null) data['buy_price'] = buyPrice;
    if (sellPrice != null) data['sell_price'] = sellPrice;
    if (name != null) data['name'] = name;

    final response = await ApiClient.dio.patch('/products/$productId', data: data);
    return ProductModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ProductModel> getByBarcode({
    required int storeId,
    required String barcode,
  }) async {
    final response = await ApiClient.dio.get(
      '/products/barcode/$barcode',
      queryParameters: {'store_id': storeId},
    );
    return ProductModel.fromJson(response.data as Map<String, dynamic>);
  }
}

class CategoryService {
  Future<List<CategoryModel>> getCategories(int storeId) async {
    final response = await ApiClient.dio.get(
      '/categories/',
      queryParameters: {'store_id': storeId},
    );
    final list = response.data as List;
    return list.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<CategoryModel> createCategory({
    required int storeId,
    required String name,
  }) async {
    final response = await ApiClient.dio.post(
      '/categories/',
      data: {'store_id': storeId, 'name': name},
    );
    return CategoryModel.fromJson(response.data as Map<String, dynamic>);
  }
}
