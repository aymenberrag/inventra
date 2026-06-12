import 'package:flutter/material.dart';
import '../../core/storage/store_storage.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/empty_state.dart';
import '../navigation/main_nav.dart';
import 'store_service.dart';

class StoreSelectorScreen extends StatefulWidget {
  const StoreSelectorScreen({super.key});

  @override
  State<StoreSelectorScreen> createState() => _StoreSelectorScreenState();
}

class _StoreSelectorScreenState extends State<StoreSelectorScreen> {
  final _storeService = StoreService();
  List<StoreModel> _stores = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStores();
  }

  Future<void> _loadStores() async {
    setState(() => _loading = true);
    try {
      final stores = await _storeService.getStores();
      setState(() {
        _stores = stores;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load stores: $e')),
        );
      }
    }
  }

  Future<void> _selectStore(StoreModel store) async {
    await StoreStorage.saveStore(
      id: store.id,
      name: store.name,
      currency: store.currency,
    );
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainNav()),
    );
  }

  Future<void> _showCreateStoreDialog() async {
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    String currency = 'USD';
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Create New Store',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Store Name'),
                  validator: (v) => Validators.required(v, field: 'Store name'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Address (optional)'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: currency,
                  decoration: const InputDecoration(labelText: 'Currency'),
                  items: const [
                    DropdownMenuItem(value: 'USD', child: Text('USD (\$)')),
                    DropdownMenuItem(value: 'EUR', child: Text('EUR (€)')),
                    DropdownMenuItem(value: 'GBP', child: Text('GBP (£)')),
                    DropdownMenuItem(value: 'MAD', child: Text('MAD')),
                    DropdownMenuItem(value: 'DZD', child: Text('DZD')),
                    DropdownMenuItem(value: 'TND', child: Text('TND')),
                  ],
                  onChanged: (v) => currency = v ?? 'USD',
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    Navigator.pop(ctx);
                    try {
                      final store = await _storeService.createStore(
                        name: nameController.text.trim(),
                        address: addressController.text.trim().isEmpty
                            ? null
                            : addressController.text.trim(),
                        currency: currency,
                      );
                      await _selectStore(store);
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to create store: $e')),
                        );
                      }
                    }
                  },
                  child: const Text('Create Store'),
                ),
              ],
            ),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Your Store',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose a store to continue or create a new one',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _stores.isEmpty
                      ? EmptyState(
                          icon: Icons.store_outlined,
                          title: 'No stores yet',
                          subtitle: 'Create your first store to get started',
                          action: ElevatedButton.icon(
                            onPressed: _showCreateStoreDialog,
                            icon: const Icon(Icons.add),
                            label: const Text('Create Store'),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadStores,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: _stores.length,
                            itemBuilder: (context, index) {
                              final store = _stores[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(16),
                                  leading: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.store,
                                      color: AppTheme.primary,
                                    ),
                                  ),
                                  title: Text(
                                    store.name,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  subtitle: store.address != null
                                      ? Text(store.address!)
                                      : Text('Currency: ${store.currency}'),
                                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                  onTap: () => _selectStore(store),
                                ),
                              );
                            },
                          ),
                        ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: OutlinedButton.icon(
                onPressed: _showCreateStoreDialog,
                icon: const Icon(Icons.add_business),
                label: const Text('Create New Store'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
