import 'package:flutter/material.dart';

import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/l10n/app_localizations.dart';

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

  final _scannerController = MobileScannerController(

    detectionSpeed: DetectionSpeed.normal,

    facing: CameraFacing.back,

  );



  final List<CartItem> _cart = [];

  final Map<int, TextEditingController> _priceControllers = {};

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

    for (final c in _priceControllers.values) {

      c.dispose();

    }

    super.dispose();

  }



  TextEditingController _getPriceController(CartItem item) {

    return _priceControllers.putIfAbsent(

      item.product.id,

      () => TextEditingController(text: item.sellPrice.toStringAsFixed(2)),

    );

  }



  void _removeFromCart(int index, [StateSetter? setModalState]) {

    final item = _cart[index];

    _priceControllers[item.product.id]?.dispose();

    _priceControllers.remove(item.product.id);

    if (setModalState != null) {

      setModalState(() => _cart.removeAt(index));

    } else {

      setState(() => _cart.removeAt(index));

    }

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



      final l10n = AppLocalizations.of(context);

      final existing = _cart.indexWhere((c) => c.product.id == product.id);

      if (existing >= 0) {

        if (_cart[existing].quantity < product.quantity) {

          setState(() => _cart[existing].quantity++);

        } else {

          _showMessage(l10n.notEnoughStock);

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

          _showMessage('${product.name} ${l10n.outOfStock.toLowerCase()}');

        }

      }

    } catch (_) {

      _showMessage(AppLocalizations.of(context).productNotFound);

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

      final l10n = AppLocalizations.of(context);

      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(

          content: Text(

            '${l10n.saleCompleted} ${CurrencyFormatter.format(_cartTotal, _currency)}',

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



  Widget _buildCartItemCard(CartItem item, int index, StateSetter setModalState, AppLocalizations l10n) {

    return Card(

      margin: const EdgeInsets.only(bottom: 8),

      child: Padding(

        padding: const EdgeInsets.all(12),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Row(

              children: [

                Expanded(

                  child: Text(

                    item.product.name,

                    style: const TextStyle(fontWeight: FontWeight.w600),

                  ),

                ),

                IconButton(

                  onPressed: () => _removeFromCart(index, setModalState),

                  icon: const Icon(Icons.delete_outline, color: AppTheme.danger, size: 20),

                  tooltip: l10n.delete,

                ),

              ],

            ),

            const SizedBox(height: 8),

            Row(

              children: [

                Container(

                  decoration: BoxDecoration(

                    border: Border.all(color: Colors.grey.shade300),

                    borderRadius: BorderRadius.circular(8),

                  ),

                  child: Row(

                    mainAxisSize: MainAxisSize.min,

                    children: [

                      IconButton(

                        onPressed: () {

                          if (item.quantity > 1) {

                            setModalState(() => item.quantity--);

                            setState(() {});

                          } else {

                            _removeFromCart(index, setModalState);

                            setState(() {});

                          }

                        },

                        icon: const Icon(Icons.remove, size: 18),

                        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),

                      ),

                      Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.w600)),

                      IconButton(

                        onPressed: () {

                          if (item.quantity < item.product.availableStock) {

                            setModalState(() => item.quantity++);

                            setState(() {});

                          }

                        },

                        icon: const Icon(Icons.add, size: 18),

                        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),

                      ),

                    ],

                  ),

                ),

                const Spacer(),

                SizedBox(

                  width: 100,

                  child: TextField(

                    keyboardType: const TextInputType.numberWithOptions(decimal: true),

                    decoration: InputDecoration(

                      labelText: l10n.price,

                      isDense: true,

                      prefixText: '\$ ',

                    ),

                    controller: _getPriceController(item),

                    onChanged: (v) {

                      final price = double.tryParse(v);

                      if (price != null && price >= 0) {

                        setModalState(() => item.sellPrice = price);

                        setState(() {});

                      }

                    },

                  ),

                ),

              ],

            ),

            Align(

              alignment: Alignment.centerRight,

              child: Text(

                CurrencyFormatter.format(item.total, _currency),

                style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.primary),

              ),

            ),

          ],

        ),

      ),

    );

  }



  void _showCartSheet() {

    final l10n = AppLocalizations.of(context);



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

                      Text(

                        l10n.cart,

                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),

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

                    Padding(

                      padding: const EdgeInsets.all(24),

                      child: Text(l10n.scanToAdd),

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

                          return _buildCartItemCard(_cart[index], index, setModalState, l10n);

                        },

                      ),

                    ),

                  const SizedBox(height: 16),

                  ElevatedButton(

                    onPressed: _cart.isEmpty ? null : _completeSale,

                    child: Text(l10n.completeSale),

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

    final l10n = AppLocalizations.of(context);



    return Scaffold(

      backgroundColor: Colors.black,

      appBar: AppBar(

        backgroundColor: Colors.black,

        foregroundColor: Colors.white,

        title: Text(l10n.scanAndSell),

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

            flex: 5,

            child: Stack(

              fit: StackFit.expand,

              children: [

                MobileScanner(

                  controller: _scannerController,

                  onDetect: _onBarcodeDetected,

                ),

                Center(

                  child: Container(

                    width: 280,

                    height: 180,

                    decoration: BoxDecoration(

                      border: Border.all(color: AppTheme.primary, width: 2.5),

                      borderRadius: BorderRadius.circular(20),

                    ),

                    child: Stack(

                      children: [

                        Positioned(top: -1, left: -1, child: _corner(true, true)),

                        Positioned(top: -1, right: -1, child: _corner(true, false)),

                        Positioned(bottom: -1, left: -1, child: _corner(false, true)),

                        Positioned(bottom: -1, right: -1, child: _corner(false, false)),

                      ],

                    ),

                  ),

                ),

                if (_processing)

                  Container(

                    color: Colors.black26,

                    child: const Center(

                      child: CircularProgressIndicator(color: AppTheme.primary),

                    ),

                  ),

                Positioned(

                  bottom: 16,

                  left: 0,

                  right: 0,

                  child: Text(

                    l10n.pointCamera,

                    textAlign: TextAlign.center,

                    style: const TextStyle(color: Colors.white70, fontSize: 13),

                  ),

                ),

              ],

            ),

          ),

          Container(

            width: double.infinity,

            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),

            decoration: BoxDecoration(

              color: Colors.white,

              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),

              boxShadow: [

                BoxShadow(

                  color: Colors.black.withValues(alpha: 0.1),

                  blurRadius: 16,

                  offset: const Offset(0, -4),

                ),

              ],

            ),

            child: SafeArea(

              top: false,

              child: Column(

                crossAxisAlignment: CrossAxisAlignment.start,

                mainAxisSize: MainAxisSize.min,

                children: [

                  Row(

                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [

                      Text(

                        '${l10n.scannedItems} (${_cart.length})',

                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),

                      ),

                      Text(

                        CurrencyFormatter.format(_cartTotal, _currency),

                        style: const TextStyle(

                          fontWeight: FontWeight.bold,

                          color: AppTheme.primary,

                          fontSize: 16,

                        ),

                      ),

                    ],

                  ),

                  const SizedBox(height: 8),

                  if (_cart.isEmpty)

                    Padding(

                      padding: const EdgeInsets.symmetric(vertical: 12),

                      child: Center(

                        child: Text(

                          l10n.scanToAdd,

                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),

                        ),

                      ),

                    )

                  else

                    SizedBox(

                      height: 80,

                      child: ListView.separated(

                        scrollDirection: Axis.horizontal,

                        itemCount: _cart.length,

                        separatorBuilder: (_, __) => const SizedBox(width: 8),

                        itemBuilder: (context, index) {

                          final item = _cart[index];

                          return Container(

                            width: 140,

                            padding: const EdgeInsets.all(10),

                            decoration: BoxDecoration(

                              color: AppTheme.surface,

                              borderRadius: BorderRadius.circular(12),

                              border: Border.all(color: Colors.grey.shade200),

                            ),

                            child: Column(

                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [

                                Text(

                                  item.product.name,

                                  maxLines: 1,

                                  overflow: TextOverflow.ellipsis,

                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),

                                ),

                                Text('${l10n.qty}: ${item.quantity}', style: const TextStyle(fontSize: 11)),

                                Text(

                                  CurrencyFormatter.format(item.total, _currency),

                                  style: const TextStyle(

                                    fontWeight: FontWeight.bold,

                                    color: AppTheme.primary,

                                    fontSize: 12,

                                  ),

                                ),

                              ],

                            ),

                          );

                        },

                      ),

                    ),

                  const SizedBox(height: 12),

                  SizedBox(

                    width: double.infinity,

                    child: ElevatedButton(

                      onPressed: _cart.isEmpty ? null : _completeSale,

                      child: _processing

                          ? const SizedBox(

                              height: 22,

                              width: 22,

                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),

                            )

                          : Text(l10n.completeSale),

                    ),

                  ),

                ],

              ),

            ),

          ),

        ],

      ),

    );

  }



  Widget _corner(bool top, bool left) {

    return Container(

      width: 24,

      height: 24,

      decoration: BoxDecoration(

        border: Border(

          top: top ? const BorderSide(color: AppTheme.primary, width: 4) : BorderSide.none,

          bottom: !top ? const BorderSide(color: AppTheme.primary, width: 4) : BorderSide.none,

          left: left ? const BorderSide(color: AppTheme.primary, width: 4) : BorderSide.none,

          right: !left ? const BorderSide(color: AppTheme.primary, width: 4) : BorderSide.none,

        ),

      ),

    );

  }

}

