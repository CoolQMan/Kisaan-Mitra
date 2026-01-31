import 'package:kisaan_mitra/models/marketplace_models.dart';

/// Service for managing product catalog and cart
class ProductService {
  // Singleton pattern
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal() {
    _initMockProducts();
  }

  final List<ProductModel> _products = [];
  final List<CartItemModel> _cart = [];

  // ============================================================================
  // PRODUCT CATALOG
  // ============================================================================

  /// Get all products
  List<ProductModel> getAllProducts() => List.from(_products);

  /// Get products by category
  List<ProductModel> getProductsByCategory(ProductCategory category) {
    return _products.where((p) => p.category == category).toList();
  }

  /// Get featured products
  List<ProductModel> getFeaturedProducts() {
    return _products.where((p) => p.isFeatured).toList();
  }

  /// Search products
  List<ProductModel> searchProducts(String query) {
    final lowerQuery = query.toLowerCase();
    return _products
        .where((p) =>
            p.name.toLowerCase().contains(lowerQuery) ||
            p.hindiName.contains(query) ||
            p.description.toLowerCase().contains(lowerQuery) ||
            p.tags.any((t) => t.toLowerCase().contains(lowerQuery)))
        .toList();
  }

  /// Get product by ID
  ProductModel? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  // ============================================================================
  // CART MANAGEMENT
  // ============================================================================

  /// Get cart items
  List<CartItemModel> getCart() => List.from(_cart);

  /// Get cart total
  double getCartTotal() {
    return _cart.fold(0, (sum, item) => sum + item.totalPrice);
  }

  /// Get cart item count
  int getCartItemCount() {
    return _cart.fold(0, (sum, item) => sum + item.quantity);
  }

  /// Add to cart
  void addToCart(ProductModel product, {int quantity = 1}) {
    final existingIndex =
        _cart.indexWhere((item) => item.product.id == product.id);
    if (existingIndex >= 0) {
      _cart[existingIndex].quantity += quantity;
    } else {
      _cart.add(CartItemModel(product: product, quantity: quantity));
    }
  }

  /// Remove from cart
  void removeFromCart(String productId) {
    _cart.removeWhere((item) => item.product.id == productId);
  }

  /// Update cart quantity
  void updateCartQuantity(String productId, int quantity) {
    final item = _cart.firstWhere((item) => item.product.id == productId);
    if (quantity <= 0) {
      removeFromCart(productId);
    } else {
      item.quantity = quantity;
    }
  }

  /// Clear cart
  void clearCart() {
    _cart.clear();
  }

  // ============================================================================
  // MOCK DATA INITIALIZATION
  // ============================================================================

  void _initMockProducts() {
    if (_products.isNotEmpty) return;

    // ==================== SEEDS ====================
    _products.addAll([
      const ProductModel(
        id: 'seed_001',
        name: 'Premium Wheat Seeds (HD-3086)',
        hindiName: 'प्रीमियम गेहूं बीज (HD-3086)',
        category: ProductCategory.seeds,
        description:
            'High-yielding variety suitable for irrigated conditions. Rust resistant with excellent grain quality.',
        price: 65,
        unit: 'per kg',
        seller: 'Kisaan Seeds Co.',
        rating: 4.5,
        reviewCount: 234,
        stock: 500,
        specifications: {
          'Variety': 'HD-3086',
          'Yield': '55-60 q/ha',
          'Duration': '140-145 days',
          'Season': 'Rabi',
        },
        tags: ['wheat', 'rabi', 'high-yield', 'irrigated'],
        isFeatured: true,
      ),
      const ProductModel(
        id: 'seed_002',
        name: 'Basmati Rice Seeds (Pusa-1121)',
        hindiName: 'बासमती धान बीज (पूसा-1121)',
        category: ProductCategory.seeds,
        description:
            'Premium aromatic rice variety with extra-long grains. High market demand.',
        price: 120,
        unit: 'per kg',
        seller: 'Agri Premium Seeds',
        rating: 4.7,
        reviewCount: 456,
        stock: 300,
        specifications: {
          'Variety': 'Pusa-1121',
          'Grain Length': '8.4 mm',
          'Duration': '135-140 days',
          'Season': 'Kharif',
        },
        tags: ['rice', 'basmati', 'premium', 'aromatic'],
        isFeatured: true,
      ),
      const ProductModel(
        id: 'seed_003',
        name: 'Hybrid Maize Seeds (NK-6240)',
        hindiName: 'हाइब्रिड मक्का बीज (NK-6240)',
        category: ProductCategory.seeds,
        description:
            'High-yielding hybrid maize suitable for grain and fodder. Drought tolerant.',
        price: 450,
        unit: 'per kg',
        seller: 'Syngenta India',
        rating: 4.3,
        reviewCount: 189,
        stock: 200,
        specifications: {
          'Yield': '80-90 q/ha',
          'Duration': '95-100 days',
          'Grain Color': 'Yellow',
        },
        tags: ['maize', 'hybrid', 'drought-tolerant'],
      ),
      const ProductModel(
        id: 'seed_004',
        name: 'Cotton Seeds (Bt Cotton)',
        hindiName: 'कपास बीज (बीटी कॉटन)',
        category: ProductCategory.seeds,
        description:
            'Bollworm resistant Bt cotton variety with high lint yield.',
        price: 950,
        unit: 'per packet (450g)',
        seller: 'Mahyco Seeds',
        rating: 4.4,
        reviewCount: 312,
        stock: 150,
        specifications: {
          'Lint Yield': '35-40%',
          'Duration': '160-180 days',
          'Resistance': 'Bollworm',
        },
        tags: ['cotton', 'bt', 'high-yield'],
      ),
      const ProductModel(
        id: 'seed_005',
        name: 'Mustard Seeds (Pusa Bold)',
        hindiName: 'सरसों बीज (पूसा बोल्ड)',
        category: ProductCategory.seeds,
        description:
            'Bold seeded variety with high oil content. Suitable for late sowing.',
        price: 85,
        unit: 'per kg',
        seller: 'IARI Seeds',
        rating: 4.2,
        reviewCount: 156,
        stock: 400,
        specifications: {
          'Oil Content': '42%',
          'Duration': '130-135 days',
          'Season': 'Rabi',
        },
        tags: ['mustard', 'oil-seed', 'rabi'],
      ),
    ]);

    // ==================== FERTILIZERS ====================
    _products.addAll([
      const ProductModel(
        id: 'fert_001',
        name: 'Urea (46% N)',
        hindiName: 'यूरिया (46% नाइट्रोजन)',
        category: ProductCategory.fertilizers,
        description:
            'High nitrogen content fertilizer for vegetative growth. Subsidy available.',
        price: 266,
        unit: 'per 45kg bag',
        seller: 'IFFCO',
        rating: 4.6,
        reviewCount: 1245,
        stock: 1000,
        specifications: {
          'Nitrogen': '46%',
          'Form': 'Prilled',
          'Subsidy': 'Available',
        },
        tags: ['urea', 'nitrogen', 'subsidy'],
        isFeatured: true,
      ),
      const ProductModel(
        id: 'fert_002',
        name: 'DAP (18-46-0)',
        hindiName: 'डीएपी (18-46-0)',
        category: ProductCategory.fertilizers,
        description:
            'Di-ammonium phosphate for root development and flowering. Essential for crops.',
        price: 1350,
        unit: 'per 50kg bag',
        seller: 'IFFCO',
        rating: 4.5,
        reviewCount: 987,
        stock: 800,
        specifications: {
          'Nitrogen': '18%',
          'Phosphorus': '46%',
          'Form': 'Granular',
        },
        tags: ['dap', 'phosphorus', 'basal'],
        isFeatured: true,
      ),
      const ProductModel(
        id: 'fert_003',
        name: 'MOP (Potash)',
        hindiName: 'म्यूरेट ऑफ पोटाश',
        category: ProductCategory.fertilizers,
        description:
            'Muriate of Potash for fruit quality and disease resistance.',
        price: 1700,
        unit: 'per 50kg bag',
        seller: 'Kribhco',
        rating: 4.3,
        reviewCount: 543,
        stock: 500,
        specifications: {
          'K2O': '60%',
          'Form': 'Crystalline',
        },
        tags: ['potash', 'potassium', 'quality'],
      ),
      const ProductModel(
        id: 'fert_004',
        name: 'NPK Complex (10-26-26)',
        hindiName: 'एनपीके कॉम्प्लेक्स (10-26-26)',
        category: ProductCategory.fertilizers,
        description:
            'Balanced NPK for overall crop nutrition. Ideal for vegetables.',
        price: 1450,
        unit: 'per 50kg bag',
        seller: 'Coromandel',
        rating: 4.4,
        reviewCount: 678,
        stock: 600,
        specifications: {
          'N': '10%',
          'P': '26%',
          'K': '26%',
        },
        tags: ['npk', 'complex', 'balanced'],
      ),
      const ProductModel(
        id: 'fert_005',
        name: 'Organic Vermicompost',
        hindiName: 'जैविक वर्मीकम्पोस्ट',
        category: ProductCategory.fertilizers,
        description:
            '100% organic compost made from earthworms. Improves soil health.',
        price: 8,
        unit: 'per kg',
        seller: 'Green Earth Organics',
        rating: 4.7,
        reviewCount: 234,
        stock: 2000,
        specifications: {
          'Organic Matter': '>20%',
          'NPK': '1.5-2-1.5',
          'pH': '6.5-7.5',
        },
        tags: ['organic', 'vermicompost', 'natural'],
      ),
    ]);

    // ==================== PESTICIDES ====================
    _products.addAll([
      const ProductModel(
        id: 'pest_001',
        name: 'Imidacloprid 17.8% SL',
        hindiName: 'इमिडाक्लोप्रिड 17.8% SL',
        category: ProductCategory.pesticides,
        description:
            'Systemic insecticide effective against sucking pests like aphids, jassids.',
        price: 450,
        unit: 'per 250ml',
        seller: 'Bayer CropScience',
        rating: 4.5,
        reviewCount: 567,
        stock: 300,
        specifications: {
          'Active Ingredient': 'Imidacloprid',
          'Target Pests': 'Aphids, Jassids, Whiteflies',
          'Application': 'Foliar spray',
        },
        tags: ['insecticide', 'systemic', 'sucking-pests'],
        isFeatured: true,
      ),
      const ProductModel(
        id: 'pest_002',
        name: 'Mancozeb 75% WP',
        hindiName: 'मैन्कोज़ेब 75% WP',
        category: ProductCategory.pesticides,
        description:
            'Broad-spectrum fungicide for control of blight, rust, and leaf spots.',
        price: 280,
        unit: 'per 500g',
        seller: 'UPL Limited',
        rating: 4.3,
        reviewCount: 432,
        stock: 400,
        specifications: {
          'Active Ingredient': 'Mancozeb',
          'Target Diseases': 'Blight, Rust, Leaf spots',
          'Application': 'Preventive spray',
        },
        tags: ['fungicide', 'blight', 'preventive'],
      ),
      const ProductModel(
        id: 'pest_003',
        name: 'Glyphosate 41% SL',
        hindiName: 'ग्लाइफोसेट 41% SL',
        category: ProductCategory.pesticides,
        description:
            'Non-selective herbicide for weed control. Apply before sowing.',
        price: 380,
        unit: 'per litre',
        seller: 'Monsanto',
        rating: 4.2,
        reviewCount: 345,
        stock: 250,
        specifications: {
          'Active Ingredient': 'Glyphosate',
          'Target': 'All weeds',
          'Application': 'Pre-emergence',
        },
        tags: ['herbicide', 'weedkiller', 'non-selective'],
      ),
      const ProductModel(
        id: 'pest_004',
        name: 'Neem Oil (Azadirachtin 1500 ppm)',
        hindiName: 'नीम तेल (अज़ाडिराक्टिन 1500 ppm)',
        category: ProductCategory.pesticides,
        description:
            'Organic bio-pesticide from neem. Safe for beneficial insects.',
        price: 320,
        unit: 'per litre',
        seller: 'Parry Organics',
        rating: 4.6,
        reviewCount: 289,
        stock: 350,
        specifications: {
          'Active Ingredient': 'Azadirachtin',
          'Mode': 'Antifeedant, Repellent',
          'Type': 'Organic',
        },
        tags: ['organic', 'neem', 'bio-pesticide', 'safe'],
        isFeatured: true,
      ),
    ]);

    // ==================== MACHINERY ====================
    _products.addAll([
      const ProductModel(
        id: 'mach_001',
        name: 'Knapsack Sprayer (16L)',
        hindiName: 'नैपसैक स्प्रेयर (16L)',
        category: ProductCategory.machinery,
        description:
            'Manual backpack sprayer for pesticide application. Durable plastic tank.',
        price: 850,
        unit: 'per unit',
        seller: 'Aspee Agro',
        rating: 4.3,
        reviewCount: 567,
        stock: 100,
        specifications: {
          'Capacity': '16 litres',
          'Type': 'Manual',
          'Material': 'HDPE',
        },
        tags: ['sprayer', 'manual', 'pesticide'],
      ),
      const ProductModel(
        id: 'mach_002',
        name: 'Battery Sprayer (16L)',
        hindiName: 'बैटरी स्प्रेयर (16L)',
        category: ProductCategory.machinery,
        description: 'Electric battery-powered sprayer. 8-hour battery life.',
        price: 2800,
        unit: 'per unit',
        seller: 'Neptune Fairdeal',
        rating: 4.5,
        reviewCount: 345,
        stock: 80,
        specifications: {
          'Capacity': '16 litres',
          'Battery': '12V 8Ah',
          'Runtime': '6-8 hours',
        },
        tags: ['sprayer', 'battery', 'electric'],
        isFeatured: true,
      ),
      const ProductModel(
        id: 'mach_003',
        name: 'Power Weeder',
        hindiName: 'पावर वीडर',
        category: ProductCategory.machinery,
        description: 'Petrol-powered weeder for inter-cultivation. 2HP engine.',
        price: 28000,
        unit: 'per unit',
        seller: 'Honda India',
        rating: 4.4,
        reviewCount: 189,
        stock: 25,
        specifications: {
          'Engine': '2 HP Petrol',
          'Working Width': '300mm',
          'Weight': '22 kg',
        },
        tags: ['weeder', 'power', 'petrol'],
      ),
      const ProductModel(
        id: 'mach_004',
        name: 'Mini Tractor (20 HP) - Rental',
        hindiName: 'मिनी ट्रैक्टर (20 HP) - किराया',
        category: ProductCategory.machinery,
        description:
            'Compact tractor for small farms. Available for daily rental.',
        price: 1200,
        unit: 'per day',
        seller: 'Agri Rentals',
        rating: 4.2,
        reviewCount: 123,
        stock: 10,
        specifications: {
          'Power': '20 HP',
          'Type': 'Diesel',
          'Rental': 'Daily/Weekly',
        },
        tags: ['tractor', 'rental', 'mini'],
      ),
    ]);

    // ==================== STORAGE & TRANSPORT ====================
    _products.addAll([
      const ProductModel(
        id: 'stor_001',
        name: 'Grain Storage Bags (50kg)',
        hindiName: 'अनाज भंडारण बैग (50kg)',
        category: ProductCategory.storageTransport,
        description: 'HDPE woven bags with moisture barrier. Pack of 50.',
        price: 750,
        unit: 'per 50 bags',
        seller: 'Poly Pack Industries',
        rating: 4.4,
        reviewCount: 234,
        stock: 500,
        specifications: {
          'Capacity': '50 kg',
          'Material': 'HDPE Woven',
          'Quantity': '50 bags',
        },
        tags: ['bags', 'storage', 'grain'],
      ),
      const ProductModel(
        id: 'stor_002',
        name: 'Cold Storage Facility - Weekly',
        hindiName: 'कोल्ड स्टोरेज सुविधा - साप्ताहिक',
        category: ProductCategory.storageTransport,
        description:
            'Climate-controlled storage for perishables. Temperature 2-8°C.',
        price: 2500,
        unit: 'per quintal/week',
        seller: 'Fresh Chain Logistics',
        rating: 4.6,
        reviewCount: 156,
        stock: 50,
        specifications: {
          'Temperature': '2-8°C',
          'Humidity': '85-90%',
          'Min Quantity': '5 quintals',
        },
        tags: ['cold-storage', 'perishables', 'rental'],
        isFeatured: true,
      ),
      const ProductModel(
        id: 'stor_003',
        name: 'Transport Service - Per Trip',
        hindiName: 'परिवहन सेवा - प्रति ट्रिप',
        category: ProductCategory.storageTransport,
        description: 'Farm-to-market transport. 3-ton capacity truck.',
        price: 15,
        unit: 'per km',
        seller: 'Kisaan Transport',
        rating: 4.3,
        reviewCount: 189,
        stock: 20,
        specifications: {
          'Capacity': '3 tons',
          'Type': 'Open/Covered',
          'Area': 'State-wide',
        },
        tags: ['transport', 'logistics', 'mandi'],
      ),
      const ProductModel(
        id: 'stor_004',
        name: 'Hermetic Storage Silo (1 Ton)',
        hindiName: 'हर्मेटिक स्टोरेज साइलो (1 टन)',
        category: ProductCategory.storageTransport,
        description:
            'Airtight metal silo for long-term grain storage. Prevents pests.',
        price: 18000,
        unit: 'per unit',
        seller: 'GrainPro India',
        rating: 4.7,
        reviewCount: 89,
        stock: 30,
        specifications: {
          'Capacity': '1000 kg',
          'Material': 'Galvanized Steel',
          'Pest Protection': '100%',
        },
        tags: ['silo', 'hermetic', 'long-term'],
      ),
    ]);
  }
}
