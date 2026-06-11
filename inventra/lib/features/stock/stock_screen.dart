import 'package:flutter/material.dart';
import '../../core/storage/store_storage.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/validators.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/empty_state.dart';
import '../stock/product_service.dart';

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  final _productService = ProductService();
  final _categoryService = CategoryService();

  List<ProductModel> _products = [];
  List<CategoryModel> _categories = [];
  int? _selectedCategoryId;
  String _search = '';
  String _currency = 'USD';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final storeId = await StoreStorage.getStoreId();
      final currency = await StoreStorage.getCurrency();
      if (storeId == null) return;

      final results = await Future.wait([
        _productService.getProducts(
          storeId: storeId,
          categoryId: _selectedCategoryId,
        ),
        _categoryService.getCategories(storeId),
      ]);

      setState(() {
        _products = results[0] as List<ProductModel>;
        _categories = results[1] as List<CategoryModel>;
        _currency = currency;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  List<ProductModel> get _filteredProducts {
    if (_search.isEmpty) return _products;
    return _products
        .where((p) =>
            p.name.toLowerCase().contains(_search.toLowerCase()) ||
            p.barcode.contains(_search))
        .toList();
  }

  Future<void> _showAddProductSheet() async {
    final storeId = await StoreStorage.getStoreId();
    if (storeId == null) return;

    final nameController = TextEditingController();
    final barcodeController = TextEditingController();
    final buyController = TextEditingController();
    final sellController = TextEditingController();
    final qtyController = TextEditingController(text: '0');
    int? categoryId;
    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Add Product',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Product Name'),
                    validator: (v) => Validators.required(v, field: 'Name'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: barcodeController,
                    decoration: const InputDecoration(labelText: 'Barcode'),
                    validator: (v) => Validators.required(v, field: 'Barcode'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int?>(
                    value: categoryId,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('No category')),
                      ..._categories.map(
                        (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),
                      ),
                    ],
                    onChanged: (v) => categoryId = v,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: buyController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Buy Price'),
                          validator: Validators.positiveNumber,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: sellController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Sell Price'),
                          validator: Validators.positiveNumber,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: qtyController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Initial Quantity'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      Navigator.pop(ctx);
                      await _productService.createProduct(
                        storeId: storeId,
                        name: nameController.text.trim(),
                        barcode: barcodeController.text.trim(),
                        buyPrice: double.parse(buyController.text),
                        sellPrice: double.parse(sellController.text),
                        quantity: int.tryParse(qtyController.text) ?? 0,
                        categoryId: categoryId,
                      );
                      _loadData();
                    },
                    child: const Text('Add Product'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showStockActions(ProductModel product) async {
    final refillController = TextEditingController();
    final newQtyController = TextEditingController(text: '${product.quantity}');

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                product.name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text('Current stock: ${product.quantity}'),
              const SizedBox(height: 20),
              TextField(
                controller: refillController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Refill amount (+)',
                  prefixIcon: Icon(Icons.add),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newQtyController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Set exact quantity',
                  prefixIcon: Icon(Icons.edit),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  if (refillController.text.isNotEmpty) {
                    await _productService.updateProduct(
                      productId: product.id,
                      quantityDelta: int.parse(refillController.text),
                    );
                  } else if (newQtyController.text.isNotEmpty) {
                    await _productService.updateProduct(
                      productId: product.id,
                      quantity: int.parse(newQtyController.text),
                    );
                  }
                  _loadData();
                },
                child: const Text('Update Stock'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Stock',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    onPressed: _showAddProductSheet,
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                onChanged: (v) => setState(() => _search = v),
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: const Text('All'),
                      selected: _selectedCategoryId == null,
                      onSelected: (_) {
                        setState(() => _selectedCategoryId = null);
                        _loadData();
                      },
                    ),
                  ),
                  ..._categories.map(
                    (c) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(c.name),
                        selected: _selectedCategoryId == c.id,
                        onSelected: (_) {
                          setState(() => _selectedCategoryId = c.id);
                          _loadData();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredProducts.isEmpty
                      ? EmptyState(
                          icon: Icons.inventory_2_outlined,
                          title: 'No products found',
                          subtitle: 'Add products to manage your stock',
                          action: ElevatedButton(
                            onPressed: _showAddProductSheet,
                            child: const Text('Add Product'),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadData,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredProducts.length,
                            itemBuilder: (context, index) {
                              final product = _filteredProducts[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(12),
                                  title: Text(
                                    product.name,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Barcode: ${product.barcode}'),
                                      Text(
                                        'Price: ${CurrencyFormatter.format(product.sellPrice, _currency)}',
                                      ),
                                    ],
                                  ),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: product.isLowStock
                                              ? AppTheme.danger.withValues(alpha: 0.1)
                                              : AppTheme.success.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          'Qty: ${product.quantity}',
                                          style: TextStyle(
                                            color: product.isLowStock
                                                ? AppTheme.danger
                                                : AppTheme.success,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () => _showStockActions(product),
                                        child: const Text('Manage'),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
