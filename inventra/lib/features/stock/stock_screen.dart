import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';

import '../../core/l10n/app_localizations.dart';

import '../../core/storage/store_storage.dart';

import '../../core/utils/currency_formatter.dart';

import '../../core/utils/validators.dart';

import '../../core/theme/app_theme.dart';

import '../../core/widgets/empty_state.dart';

import '../../core/widgets/barcode_scan_screen.dart';

import '../stock/product_service.dart';



class StockScreen extends StatefulWidget {

  const StockScreen({super.key});



  @override

  State<StockScreen> createState() => _StockScreenState();

}



class _StockScreenState extends State<StockScreen> {

  final _productService = ProductService();

  final _categoryService = CategoryService();

  final _imagePicker = ImagePicker();



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



  Future<void> _scanBarcode(TextEditingController controller) async {

    final barcode = await Navigator.push<String>(

      context,

      MaterialPageRoute(builder: (_) => const BarcodeScanScreen()),

    );

    if (barcode != null) {

      controller.text = barcode;

    }

  }



  Future<int?> _showAddCategoryDialog(int storeId) async {

    final l10n = AppLocalizations.of(context);

    final nameController = TextEditingController();



    final name = await showDialog<String>(

      context: context,

      builder: (ctx) => AlertDialog(

        title: Text(l10n.addCategory),

        content: TextField(

          controller: nameController,

          decoration: InputDecoration(labelText: l10n.category),

          autofocus: true,

        ),

        actions: [

          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),

          ElevatedButton(

            onPressed: () => Navigator.pop(ctx, nameController.text.trim()),

            child: Text(l10n.add),

          ),

        ],

      ),

    );



    if (name == null || name.isEmpty) return null;



    final category = await _categoryService.createCategory(

      storeId: storeId,

      name: name,

    );

    setState(() => _categories.add(category));

    return category.id;

  }



  Future<void> _showAddProductSheet() async {
    final l10n = AppLocalizations.of(context);
    final storeId = await StoreStorage.getStoreId();
    if (!mounted) return;
    if (storeId == null) return;



    final nameController = TextEditingController();

    final barcodeController = TextEditingController();

    final buyController = TextEditingController();

    final sellController = TextEditingController();

    final qtyController = TextEditingController(text: '0');

    int? categoryId;

    String? imageBase64;

    final formKey = GlobalKey<FormState>();



    await showModalBottomSheet(

      context: context,

      isScrollControlled: true,

      shape: const RoundedRectangleBorder(

        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),

      ),

      builder: (ctx) {

        return StatefulBuilder(

          builder: (context, setSheetState) {

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

                      Text(

                        l10n.addProduct,

                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),

                      ),

                      const SizedBox(height: 16),

                      GestureDetector(

                        onTap: () async {

                          final picked = await _imagePicker.pickImage(

                            source: ImageSource.gallery,

                            maxWidth: 800,

                            maxHeight: 800,

                            imageQuality: 70,

                          );

                          if (picked != null) {

                            final bytes = await picked.readAsBytes();

                            setSheetState(() {

                              imageBase64 = 'data:image/jpeg;base64,${base64Encode(bytes)}';

                            });

                          }

                        },

                        child: Container(

                          height: 120,

                          decoration: BoxDecoration(

                            color: Colors.grey.shade100,

                            borderRadius: BorderRadius.circular(12),

                            border: Border.all(color: Colors.grey.shade300),

                          ),

                          child: imageBase64 != null

                              ? ClipRRect(

                                  borderRadius: BorderRadius.circular(12),

                                  child: Image.memory(

                                    base64Decode(imageBase64!.split(',').last),

                                    fit: BoxFit.cover,

                                    width: double.infinity,

                                  ),

                                )

                              : Column(

                                  mainAxisAlignment: MainAxisAlignment.center,

                                  children: [

                                    Icon(Icons.add_photo_alternate_outlined, color: Colors.grey.shade500, size: 36),

                                    const SizedBox(height: 4),

                                    Text(l10n.pickImage, style: TextStyle(color: Colors.grey.shade600)),

                                  ],

                                ),

                        ),

                      ),

                      const SizedBox(height: 12),

                      TextFormField(

                        controller: nameController,

                        decoration: InputDecoration(labelText: l10n.productName),

                        validator: (v) => Validators.required(v, field: 'Name'),

                      ),

                      const SizedBox(height: 12),

                      TextFormField(

                        controller: barcodeController,

                        decoration: InputDecoration(

                          labelText: l10n.barcode,

                          suffixIcon: IconButton(

                            icon: const Icon(Icons.qr_code_scanner),

                            onPressed: () => _scanBarcode(barcodeController),

                          ),

                        ),

                        validator: (v) => Validators.required(v, field: 'Barcode'),

                      ),

                      const SizedBox(height: 12),

                      Row(

                        children: [

                          Expanded(

                            child: DropdownButtonFormField<int?>(

                              decoration: InputDecoration(labelText: l10n.category),

                              initialValue: categoryId,

                              items: [

                                DropdownMenuItem(value: null, child: Text(l10n.noCategory)),

                                ..._categories.map(

                                  (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),

                                ),

                              ],

                              onChanged: (v) => setSheetState(() => categoryId = v),

                            ),

                          ),

                          IconButton(

                            onPressed: () async {

                              final newId = await _showAddCategoryDialog(storeId);

                              if (newId != null) {

                                setSheetState(() => categoryId = newId);

                              }

                            },

                            icon: const Icon(Icons.add_circle_outline),

                            tooltip: l10n.addCategory,

                          ),

                        ],

                      ),

                      const SizedBox(height: 12),

                      Row(

                        children: [

                          Expanded(

                            child: TextFormField(

                              controller: buyController,

                              keyboardType: TextInputType.number,

                              decoration: InputDecoration(labelText: l10n.buyPrice),

                              validator: Validators.positiveNumber,

                            ),

                          ),

                          const SizedBox(width: 12),

                          Expanded(

                            child: TextFormField(

                              controller: sellController,

                              keyboardType: TextInputType.number,

                              decoration: InputDecoration(labelText: l10n.sellPrice),

                              validator: Validators.positiveNumber,

                            ),

                          ),

                        ],

                      ),

                      const SizedBox(height: 12),

                      TextFormField(

                        controller: qtyController,

                        keyboardType: TextInputType.number,

                        decoration: InputDecoration(labelText: l10n.initialQuantity),

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

                            imageUrl: imageBase64,

                          );

                          _loadData();

                        },

                        child: Text(l10n.addProduct),

                      ),

                    ],

                  ),

                ),

              ),

            );

          },

        );

      },

    );

  }



  Future<void> _showStockActions(ProductModel product) async {

    final l10n = AppLocalizations.of(context);

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

              Text('${l10n.currentStock}: ${product.quantity}'),

              const SizedBox(height: 20),

              TextField(

                controller: refillController,

                keyboardType: TextInputType.number,

                decoration: InputDecoration(

                  labelText: l10n.refillAmount,

                  prefixIcon: const Icon(Icons.add),

                ),

              ),

              const SizedBox(height: 12),

              TextField(

                controller: newQtyController,

                keyboardType: TextInputType.number,

                decoration: InputDecoration(

                  labelText: l10n.setExactQty,

                  prefixIcon: const Icon(Icons.edit),

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

                child: Text(l10n.updateStock),

              ),

            ],

          ),

        );

      },

    );

  }



  Widget _productImage(ProductModel product) {

    if (product.imageUrl == null || product.imageUrl!.isEmpty) {

      return Container(

        width: 52,

        height: 52,

        decoration: BoxDecoration(

          color: AppTheme.primary.withValues(alpha: 0.1),

          borderRadius: BorderRadius.circular(10),

        ),

        child: const Icon(Icons.inventory_2_outlined, color: AppTheme.primary),

      );

    }



    try {

      if (product.imageUrl!.startsWith('data:')) {

        final bytes = base64Decode(product.imageUrl!.split(',').last);

        return ClipRRect(

          borderRadius: BorderRadius.circular(10),

          child: Image.memory(bytes, width: 52, height: 52, fit: BoxFit.cover),

        );

      }

    } catch (_) {}



    return Container(

      width: 52,

      height: 52,

      decoration: BoxDecoration(

        color: AppTheme.primary.withValues(alpha: 0.1),

        borderRadius: BorderRadius.circular(10),

      ),

      child: const Icon(Icons.inventory_2_outlined, color: AppTheme.primary),

    );

  }



  @override

  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context);



    return Scaffold(

      body: SafeArea(

        child: Column(

          children: [

            Padding(

              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),

              child: Row(

                children: [

                  Expanded(

                    child: Text(

                      l10n.stock,

                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),

                    ),

                  ),

                  IconButton(

                    onPressed: _showAddProductSheet,

                    style: IconButton.styleFrom(

                      backgroundColor: AppTheme.primary.withValues(alpha: 0.1),

                    ),

                    icon: const Icon(Icons.add_rounded, color: AppTheme.primary),

                  ),

                ],

              ),

            ),

            Padding(

              padding: const EdgeInsets.symmetric(horizontal: 16),

              child: TextField(

                onChanged: (v) => setState(() => _search = v),

                decoration: InputDecoration(

                  hintText: l10n.searchProducts,

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

            const SizedBox(height: 10),

            SizedBox(

              height: 38,

              child: ListView(

                scrollDirection: Axis.horizontal,

                padding: const EdgeInsets.symmetric(horizontal: 16),

                children: [

                  Padding(

                    padding: const EdgeInsets.only(right: 8),

                    child: FilterChip(

                      label: Text(l10n.all),

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

                          title: l10n.noProducts,

                          subtitle: l10n.noProductsHint,

                          action: ElevatedButton(

                            onPressed: _showAddProductSheet,

                            child: Text(l10n.addProduct),

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

                                child: Padding(

                                  padding: const EdgeInsets.all(12),

                                  child: Row(

                                    children: [

                                      _productImage(product),

                                      const SizedBox(width: 12),

                                      Expanded(

                                        child: Column(

                                          crossAxisAlignment: CrossAxisAlignment.start,

                                          children: [

                                            Text(

                                              product.name,

                                              style: const TextStyle(fontWeight: FontWeight.w600),

                                              maxLines: 1,

                                              overflow: TextOverflow.ellipsis,

                                            ),

                                            const SizedBox(height: 2),

                                            Text(

                                              '${l10n.barcode}: ${product.barcode}',

                                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),

                                            ),

                                            Text(

                                              CurrencyFormatter.format(product.sellPrice, _currency),

                                              style: const TextStyle(

                                                fontWeight: FontWeight.w600,

                                                color: AppTheme.primary,

                                              ),

                                            ),

                                          ],

                                        ),

                                      ),

                                      Column(

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

                                              '${l10n.qty}: ${product.quantity}',

                                              style: TextStyle(

                                                color: product.isLowStock

                                                    ? AppTheme.danger

                                                    : AppTheme.success,

                                                fontWeight: FontWeight.w600,

                                                fontSize: 12,

                                              ),

                                            ),

                                          ),

                                          TextButton(

                                            onPressed: () => _showStockActions(product),

                                            child: Text(l10n.manage),

                                          ),

                                        ],

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

