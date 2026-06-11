import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../core/storage/store_storage.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/theme/app_theme.dart';
import '../stock/product_service.dart';
import 'sale_service.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final _productService = ProductService();
  final _saleService = SaleService();
  final _scannerController = MobileScannerController();

  final List<CartItem> _cart = [];
  String _currency = 'USD';
  int? _storeId;
  bool _processing = false;
  String? _lastScanned;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _storeId = await StoreStorage.getStoreId();
    _currency = await StoreStorage.getCurrency();
    setState(() {});
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _onBarcodeDetected(BarcodeCapture capture) async {
    if (_processing || _storeId == null) return;

    final barcode = capture.barcodes.firstOrNull?.rawValue;
    if (barcode == null || barcode == _lastScanned) return;

    setState(() {
      _processing = true;
      _lastScanned = barcode;
    });

    try {
      final product = await _productService.getByBarcode(
        storeId: _storeId!,
        barcode: barcode,
      );

      final existing = _cart.indexWhere((c) => c.product.id == product.id);
      if (existing >= 0) {
        if (_cart[existing].quantity < product.quantity) {
          setState(() => _cart[existing].quantity++);
        } else {
          _showMessage('Not enough stock for ${product.name}');
        }
      } else {
        if (product.quantity > 0) {
          setState(() {
            _cart.add(
              CartItem(
                product: ProductRef(
                  id: product.id,
                  name: product.name,
                  defaultSellPrice: product.sellPrice,
                  availableStock: product.quantity,
                ),
                sellPrice: product.sellPrice,
              ),
            );
          });
        } else {
          _showMessage('${product.name} is out of stock');
        }
      }
    } catch (_) {
      _showMessage('Product not found');
    } finally {
      await Future.delayed(const Duration(milliseconds: 800));
      setState(() {
        _processing = false;
        _lastScanned = null;
      });
    }
  }

  void _showMessage(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  double get _cartTotal => _cart.fold(0, (sum, item) => sum + item.total);

  Future<void> _completeSale() async {
    if (_cart.isEmpty || _storeId == null) return;

    setState(() => _processing = true);
    try {
      await _saleService.createSale(
        storeId: _storeId!,
        items: _cart
            .map(
              (c) => {
                'product_id': c.product.id,
                'quantity': c.quantity,
                'sell_price': c.sellPrice,
              },
            )
            .toList(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Sale completed! Total: ${CurrencyFormatter.format(_cartTotal, _currency)}',
          ),
          backgroundColor: AppTheme.success,
        ),
      );
      setState(() => _cart.clear());
      Navigator.pop(context);
    } catch (e) {
      _showMessage('Sale failed: $e');
    } finally {
      setState(() => _processing = false);
    }
  }

  void _showCartSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Cart',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        CurrencyFormatter.format(_cartTotal, _currency),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_cart.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('Scan products to add them'),
                    )
                  else
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.45,
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _cart.length,
                        itemBuilder: (context, index) {
                          final item = _cart[index];
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.name,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          if (item.quantity > 1) {
                                            setModalState(() => item.quantity--);
                                            setState(() {});
                                          }
                                        },
                                        icon: const Icon(Icons.remove_circle_outline),
                                      ),
                                      Text('${item.quantity}'),
                                      IconButton(
                                        onPressed: () {
                                          if (item.quantity < item.product.availableStock) {
                                            setModalState(() => item.quantity++);
                                            setState(() {});
                                          }
                                        },
                                        icon: const Icon(Icons.add_circle_outline),
                                      ),
                                      const Spacer(),
                                      SizedBox(
                                        width: 90,
                                        child: TextField(
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                            labelText: 'Price',
                                            isDense: true,
                                          ),
                                          controller: TextEditingController(
                                            text: item.sellPrice.toStringAsFixed(2),
                                          ),
                                          onChanged: (v) {
                                            final price = double.tryParse(v);
                                            if (price != null) {
                                              setModalState(() => item.sellPrice = price);
                                              setState(() {});
                                            }
                                          },
                                        ),
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
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _cart.isEmpty ? null : _completeSale,
                    child: const Text('Complete Sale'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan & Sell'),
        actions: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: _showCartSheet,
                icon: const Icon(Icons.shopping_cart_outlined),
              ),
              if (_cart.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppTheme.danger,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${_cart.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: MobileScanner(
                  controller: _scannerController,
                  onDetect: _onBarcodeDetected,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Scanned Items (${_cart.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _cart.isEmpty
                        ? Center(
                            child: Text(
                              'Point camera at barcode to scan',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _cart.length,
                            itemBuilder: (context, index) {
                              final item = _cart[index];
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(item.product.name),
                                subtitle: Text('Qty: ${item.quantity}'),
                                trailing: Text(
                                  CurrencyFormatter.format(item.total, _currency),
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                              );
                            },
                          ),
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        CurrencyFormatter.format(_cartTotal, _currency),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _cart.isEmpty ? null : _completeSale,
                    child: _processing
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Complete Sale'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
