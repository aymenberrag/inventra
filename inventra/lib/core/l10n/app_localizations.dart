import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const supportedLocales = [
    Locale('en'),
    Locale('fr'),
    Locale('ar'),
  ];

  String get _code => locale.languageCode;

  String t(String key) => _strings[_code]?[key] ?? _strings['en']![key] ?? key;

  // Common
  String get appName => t('app_name');
  String get home => t('home');
  String get stock => t('stock');
  String get sell => t('sell');
  String get stats => t('stats');
  String get profile => t('profile');
  String get login => t('login');
  String get register => t('register');
  String get email => t('email');
  String get password => t('password');
  String get fullName => t('full_name');
  String get confirmPassword => t('confirm_password');
  String get signIn => t('sign_in');
  String get createAccount => t('create_account');
  String get continueWithGoogle => t('continue_with_google');
  String get orDivider => t('or_divider');
  String get agreePrivacy => t('agree_privacy');
  String get privacyPolicy => t('privacy_policy');
  String get mustAgreePrivacy => t('must_agree_privacy');
  String get cancel => t('cancel');
  String get add => t('add');
  String get startManaging => t('start_managing');
  String get skip => t('skip');
  String get next => t('next');
  String get welcomeBack => t('welcome_back');
  String get todaysOverview => t('todays_overview');
  String get totalSales => t('total_sales');
  String get revenue => t('revenue');
  String get profit => t('profit');
  String get lowStock => t('low_stock');
  String get quickSale => t('quick_sale');
  String get quickSaleHint => t('quick_sale_hint');
  String get notifications => t('notifications');
  String get noNotifications => t('no_notifications');
  String get searchProducts => t('search_products');
  String get addProduct => t('add_product');
  String get noProducts => t('no_products');
  String get noProductsHint => t('no_products_hint');
  String get productName => t('product_name');
  String get barcode => t('barcode');
  String get category => t('category');
  String get noCategory => t('no_category');
  String get addCategory => t('add_category');
  String get buyPrice => t('buy_price');
  String get sellPrice => t('sell_price');
  String get initialQuantity => t('initial_quantity');
  String get scanBarcode => t('scan_barcode');
  String get productImage => t('product_image');
  String get pickImage => t('pick_image');
  String get manage => t('manage');
  String get statistics => t('statistics');
  String get today => t('today');
  String get thisWeek => t('this_week');
  String get thisMonth => t('this_month');
  String get custom => t('custom');
  String get avgSale => t('avg_sale');
  String get noData => t('no_data');
  String get scanAndSell => t('scan_and_sell');
  String get cart => t('cart');
  String get scanToAdd => t('scan_to_add');
  String get completeSale => t('complete_sale');
  String get total => t('total');
  String get price => t('price');
  String get scannedItems => t('scanned_items');
  String get pointCamera => t('point_camera');
  String get personalInfo => t('personal_info');
  String get storeInfo => t('store_info');
  String get language => t('language');
  String get storeName => t('store_name');
  String get currency => t('currency');
  String get saveChanges => t('save_changes');
  String get switchStore => t('switch_store');
  String get logout => t('logout');
  String get profileUpdated => t('profile_updated');
  String get all => t('all');
  String get qty => t('qty');
  String get delete => t('delete');
  String get editPrice => t('edit_price');
  String get saleCompleted => t('sale_completed');
  String get productNotFound => t('product_not_found');
  String get outOfStock => t('out_of_stock');
  String get notEnoughStock => t('not_enough_stock');
  String get currentStock => t('current_stock');
  String get updateStock => t('update_stock');
  String get refillAmount => t('refill_amount');
  String get setExactQty => t('set_exact_qty');
  String get english => t('english');
  String get french => t('french');
  String get arabic => t('arabic');

  // Onboarding
  String get onboarding1Title => t('onboarding_1_title');
  String get onboarding1Desc => t('onboarding_1_desc');
  String get onboarding2Title => t('onboarding_2_title');
  String get onboarding2Desc => t('onboarding_2_desc');
  String get onboarding3Title => t('onboarding_3_title');
  String get onboarding3Desc => t('onboarding_3_desc');
  String get onboarding4Title => t('onboarding_4_title');
  String get onboarding4Desc => t('onboarding_4_desc');

  static const Map<String, Map<String, String>> _strings = {
    'en': {
      'app_name': 'Inventra',
      'home': 'Home',
      'stock': 'Stock',
      'sell': 'Sell',
      'stats': 'Stats',
      'profile': 'Profile',
      'login': 'Login',
      'register': 'Register',
      'email': 'Email',
      'password': 'Password',
      'full_name': 'Full Name',
      'confirm_password': 'Confirm Password',
      'sign_in': 'Sign In',
      'create_account': 'Create Account',
      'continue_with_google': 'Continue with Google',
      'or_divider': 'or',
      'agree_privacy': 'I agree to the Privacy Policy',
      'privacy_policy': 'Privacy Policy',
      'must_agree_privacy': 'You must agree to the Privacy Policy',
      'cancel': 'Cancel',
      'add': 'Add',
      'start_managing': 'Start Managing',
      'skip': 'Skip',
      'next': 'Next',
      'welcome_back': 'Welcome back',
      'todays_overview': "Today's Overview",
      'total_sales': 'Total Sales',
      'revenue': 'Revenue',
      'profit': 'Profit',
      'low_stock': 'Low Stock',
      'quick_sale': 'Quick Sale',
      'quick_sale_hint': 'Tap the scan button to sell products',
      'notifications': 'Notifications',
      'no_notifications': 'No notifications',
      'search_products': 'Search products...',
      'add_product': 'Add Product',
      'no_products': 'No products found',
      'no_products_hint': 'Add products to manage your stock',
      'product_name': 'Product Name',
      'barcode': 'Barcode',
      'category': 'Category',
      'no_category': 'No category',
      'add_category': 'Add new category',
      'buy_price': 'Buy Price',
      'sell_price': 'Sell Price',
      'initial_quantity': 'Initial Quantity',
      'scan_barcode': 'Scan barcode',
      'product_image': 'Product Image',
      'pick_image': 'Pick Image',
      'manage': 'Manage',
      'statistics': 'Statistics',
      'today': 'Today',
      'this_week': 'This Week',
      'this_month': 'This Month',
      'custom': 'Custom',
      'avg_sale': 'Avg. Sale',
      'no_data': 'No data for this period',
      'scan_and_sell': 'Scan & Sell',
      'cart': 'Cart',
      'scan_to_add': 'Scan products to add them',
      'complete_sale': 'Complete Sale',
      'total': 'Total',
      'price': 'Price',
      'scanned_items': 'Scanned Items',
      'point_camera': 'Point camera at barcode to scan',
      'personal_info': 'Personal Info',
      'store_info': 'Store Info',
      'language': 'Language',
      'store_name': 'Store Name',
      'currency': 'Currency',
      'save_changes': 'Save Changes',
      'switch_store': 'Switch Store / Create New',
      'logout': 'Logout',
      'profile_updated': 'Profile updated',
      'all': 'All',
      'qty': 'Qty',
      'delete': 'Delete',
      'edit_price': 'Edit Price',
      'sale_completed': 'Sale completed!',
      'product_not_found': 'Product not found',
      'out_of_stock': 'Out of stock',
      'not_enough_stock': 'Not enough stock',
      'current_stock': 'Current stock',
      'update_stock': 'Update Stock',
      'refill_amount': 'Refill amount (+)',
      'set_exact_qty': 'Set exact quantity',
      'english': 'English',
      'french': 'Français',
      'arabic': 'العربية',
      'onboarding_1_title': 'Welcome to Inventra',
      'onboarding_1_desc':
          'Manage your inventory, sales, and profits from one powerful app. Built for modern stores of all sizes.',
      'onboarding_2_title': 'Track Stock in Real Time',
      'onboarding_2_desc':
          'Add products manually or scan barcodes. Monitor stock levels and get alerts before items run out.',
      'onboarding_3_title': 'Sell Smarter, Not Harder',
      'onboarding_3_desc':
          'Create sales in seconds, adjust prices when needed, and keep every transaction organized automatically.',
      'onboarding_4_title': 'Understand Your Business',
      'onboarding_4_desc':
          'Discover your best-selling products, busiest hours, profits, and trends with powerful analytics and AI-driven insights.',
    },
    'fr': {
      'app_name': 'Inventra',
      'home': 'Accueil',
      'stock': 'Stock',
      'sell': 'Vente',
      'stats': 'Stats',
      'profile': 'Profil',
      'login': 'Connexion',
      'register': 'Inscription',
      'email': 'E-mail',
      'password': 'Mot de passe',
      'full_name': 'Nom complet',
      'confirm_password': 'Confirmer le mot de passe',
      'sign_in': 'Se connecter',
      'create_account': 'Créer un compte',
      'continue_with_google': 'Continuer avec Google',
      'or_divider': 'ou',
      'agree_privacy': "J'accepte la Politique de confidentialité",
      'privacy_policy': 'Politique de confidentialité',
      'must_agree_privacy':
          'Vous devez accepter la Politique de confidentialité',
      'cancel': 'Annuler',
      'add': 'Ajouter',
      'start_managing': 'Commencer à gérer',
      'skip': 'Passer',
      'next': 'Suivant',
      'welcome_back': 'Bon retour',
      'todays_overview': "Aperçu du jour",
      'total_sales': 'Ventes totales',
      'revenue': 'Revenus',
      'profit': 'Profit',
      'low_stock': 'Stock faible',
      'quick_sale': 'Vente rapide',
      'quick_sale_hint': 'Appuyez sur le bouton scan pour vendre',
      'notifications': 'Notifications',
      'no_notifications': 'Aucune notification',
      'search_products': 'Rechercher des produits...',
      'add_product': 'Ajouter un produit',
      'no_products': 'Aucun produit trouvé',
      'no_products_hint': 'Ajoutez des produits pour gérer votre stock',
      'product_name': 'Nom du produit',
      'barcode': 'Code-barres',
      'category': 'Catégorie',
      'no_category': 'Sans catégorie',
      'add_category': 'Ajouter une catégorie',
      'buy_price': "Prix d'achat",
      'sell_price': 'Prix de vente',
      'initial_quantity': 'Quantité initiale',
      'scan_barcode': 'Scanner le code-barres',
      'product_image': 'Image du produit',
      'pick_image': 'Choisir une image',
      'manage': 'Gérer',
      'statistics': 'Statistiques',
      'today': "Aujourd'hui",
      'this_week': 'Cette semaine',
      'this_month': 'Ce mois',
      'custom': 'Personnalisé',
      'avg_sale': 'Vente moy.',
      'no_data': 'Aucune donnée pour cette période',
      'scan_and_sell': 'Scanner & Vendre',
      'cart': 'Panier',
      'scan_to_add': 'Scannez des produits pour les ajouter',
      'complete_sale': 'Finaliser la vente',
      'total': 'Total',
      'price': 'Prix',
      'scanned_items': 'Articles scannés',
      'point_camera': 'Pointez la caméra vers un code-barres',
      'personal_info': 'Informations personnelles',
      'store_info': 'Informations du magasin',
      'language': 'Langue',
      'store_name': 'Nom du magasin',
      'currency': 'Devise',
      'save_changes': 'Enregistrer',
      'switch_store': 'Changer de magasin / Créer',
      'logout': 'Déconnexion',
      'profile_updated': 'Profil mis à jour',
      'all': 'Tous',
      'qty': 'Qté',
      'delete': 'Supprimer',
      'edit_price': 'Modifier le prix',
      'sale_completed': 'Vente terminée !',
      'product_not_found': 'Produit introuvable',
      'out_of_stock': 'Rupture de stock',
      'not_enough_stock': 'Stock insuffisant',
      'current_stock': 'Stock actuel',
      'update_stock': 'Mettre à jour le stock',
      'refill_amount': 'Quantité à ajouter (+)',
      'set_exact_qty': 'Définir la quantité exacte',
      'english': 'English',
      'french': 'Français',
      'arabic': 'العربية',
      'onboarding_1_title': 'Bienvenue sur Inventra',
      'onboarding_1_desc':
          'Gérez votre inventaire, vos ventes et vos profits depuis une seule application. Conçue pour les magasins modernes.',
      'onboarding_2_title': 'Suivez le stock en temps réel',
      'onboarding_2_desc':
          'Ajoutez des produits manuellement ou scannez des codes-barres. Surveillez les niveaux de stock et recevez des alertes.',
      'onboarding_3_title': 'Vendez plus intelligemment',
      'onboarding_3_desc':
          'Créez des ventes en quelques secondes, ajustez les prix si nécessaire et gardez chaque transaction organisée.',
      'onboarding_4_title': 'Comprenez votre activité',
      'onboarding_4_desc':
          'Découvrez vos meilleures ventes, heures de pointe, profits et tendances avec des analyses puissantes.',
    },
    'ar': {
      'app_name': 'Inventra',
      'home': 'الرئيسية',
      'stock': 'المخزون',
      'sell': 'بيع',
      'stats': 'إحصائيات',
      'profile': 'الملف',
      'login': 'تسجيل الدخول',
      'register': 'إنشاء حساب',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'full_name': 'الاسم الكامل',
      'confirm_password': 'تأكيد كلمة المرور',
      'sign_in': 'دخول',
      'create_account': 'إنشاء حساب',
      'continue_with_google': 'المتابعة مع Google',
      'or_divider': 'أو',
      'agree_privacy': 'أوافق على سياسة الخصوصية',
      'privacy_policy': 'سياسة الخصوصية',
      'must_agree_privacy': 'يجب الموافقة على سياسة الخصوصية',
      'cancel': 'إلغاء',
      'add': 'إضافة',
      'start_managing': 'ابدأ الإدارة',
      'skip': 'تخطي',
      'next': 'التالي',
      'welcome_back': 'مرحباً بعودتك',
      'todays_overview': 'نظرة عامة اليوم',
      'total_sales': 'إجمالي المبيعات',
      'revenue': 'الإيرادات',
      'profit': 'الربح',
      'low_stock': 'مخزون منخفض',
      'quick_sale': 'بيع سريع',
      'quick_sale_hint': 'اضغط على زر المسح لبيع المنتجات',
      'notifications': 'الإشعارات',
      'no_notifications': 'لا توجد إشعارات',
      'search_products': 'البحث عن منتجات...',
      'add_product': 'إضافة منتج',
      'no_products': 'لم يتم العثور على منتجات',
      'no_products_hint': 'أضف منتجات لإدارة مخزونك',
      'product_name': 'اسم المنتج',
      'barcode': 'الباركود',
      'category': 'الفئة',
      'no_category': 'بدون فئة',
      'add_category': 'إضافة فئة جديدة',
      'buy_price': 'سعر الشراء',
      'sell_price': 'سعر البيع',
      'initial_quantity': 'الكمية الأولية',
      'scan_barcode': 'مسح الباركود',
      'product_image': 'صورة المنتج',
      'pick_image': 'اختر صورة',
      'manage': 'إدارة',
      'statistics': 'الإحصائيات',
      'today': 'اليوم',
      'this_week': 'هذا الأسبوع',
      'this_month': 'هذا الشهر',
      'custom': 'مخصص',
      'avg_sale': 'متوسط البيع',
      'no_data': 'لا توجد بيانات لهذه الفترة',
      'scan_and_sell': 'مسح وبيع',
      'cart': 'السلة',
      'scan_to_add': 'امسح المنتجات لإضافتها',
      'complete_sale': 'إتمام البيع',
      'total': 'المجموع',
      'price': 'السعر',
      'scanned_items': 'العناصر الممسوحة',
      'point_camera': 'وجّه الكاميرا نحو الباركود',
      'personal_info': 'المعلومات الشخصية',
      'store_info': 'معلومات المتجر',
      'language': 'اللغة',
      'store_name': 'اسم المتجر',
      'currency': 'العملة',
      'save_changes': 'حفظ التغييرات',
      'switch_store': 'تبديل المتجر / إنشاء جديد',
      'logout': 'تسجيل الخروج',
      'profile_updated': 'تم تحديث الملف',
      'all': 'الكل',
      'qty': 'الكمية',
      'delete': 'حذف',
      'edit_price': 'تعديل السعر',
      'sale_completed': 'تم البيع بنجاح!',
      'product_not_found': 'المنتج غير موجود',
      'out_of_stock': 'نفد المخزون',
      'not_enough_stock': 'المخزون غير كافٍ',
      'current_stock': 'المخزون الحالي',
      'update_stock': 'تحديث المخزون',
      'refill_amount': 'كمية الإضافة (+)',
      'set_exact_qty': 'تعيين الكمية الدقيقة',
      'english': 'English',
      'french': 'Français',
      'arabic': 'العربية',
      'onboarding_1_title': 'مرحباً بك في Inventra',
      'onboarding_1_desc':
          'أدر مخزونك ومبيعاتك وأرباحك من تطبيق واحد قوي. مصمم للمتاجر الحديثة بجميع الأحجام.',
      'onboarding_2_title': 'تتبع المخزون في الوقت الفعلي',
      'onboarding_2_desc':
          'أضف المنتجات يدوياً أو امسح الباركود. راقب مستويات المخزون واحصل على تنبيهات قبل نفاد المنتجات.',
      'onboarding_3_title': 'بيع بذكاء أكثر',
      'onboarding_3_desc':
          'أنشئ المبيعات في ثوانٍ، عدّل الأسعار عند الحاجة، واحتفظ بكل معاملة منظمة تلقائياً.',
      'onboarding_4_title': 'افهم عملك',
      'onboarding_4_desc':
          'اكتشف أفضل منتجاتك مبيعاً، أوقات الذروة، الأرباح والاتجاهات مع تحليلات قوية.',
    },
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'fr', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
