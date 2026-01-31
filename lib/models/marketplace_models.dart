// Marketplace Models for Kisaan Mitra
// Includes products, prices, recommendations, and alerts

// ============================================================================
// PRODUCT MODELS (For Purchasing)
// ============================================================================

/// Categories of products farmers can purchase
enum ProductCategory {
  seeds,
  fertilizers,
  pesticides,
  machinery,
  storageTransport,
}

extension ProductCategoryExtension on ProductCategory {
  String get displayName {
    switch (this) {
      case ProductCategory.seeds:
        return 'Seeds';
      case ProductCategory.fertilizers:
        return 'Fertilizers';
      case ProductCategory.pesticides:
        return 'Pesticides';
      case ProductCategory.machinery:
        return 'Farm Machinery';
      case ProductCategory.storageTransport:
        return 'Storage & Transport';
    }
  }

  String get icon {
    switch (this) {
      case ProductCategory.seeds:
        return '🌱';
      case ProductCategory.fertilizers:
        return '🧪';
      case ProductCategory.pesticides:
        return '🛡️';
      case ProductCategory.machinery:
        return '🚜';
      case ProductCategory.storageTransport:
        return '🏭';
    }
  }

  String get hindiName {
    switch (this) {
      case ProductCategory.seeds:
        return 'बीज';
      case ProductCategory.fertilizers:
        return 'उर्वरक';
      case ProductCategory.pesticides:
        return 'कीटनाशक';
      case ProductCategory.machinery:
        return 'कृषि मशीनरी';
      case ProductCategory.storageTransport:
        return 'भंडारण और परिवहन';
    }
  }
}

/// Product that farmers can purchase
class ProductModel {
  final String id;
  final String name;
  final String hindiName;
  final ProductCategory category;
  final String description;
  final double price;
  final String unit; // per kg, per bag, per hour, etc.
  final String imageAsset; // Local asset path
  final String seller;
  final double rating; // 1-5 stars
  final int reviewCount;
  final int stock; // Available quantity
  final Map<String, String> specifications;
  final List<String> tags;
  final bool isFeatured;

  const ProductModel({
    required this.id,
    required this.name,
    required this.hindiName,
    required this.category,
    required this.description,
    required this.price,
    required this.unit,
    this.imageAsset = '',
    required this.seller,
    this.rating = 4.0,
    this.reviewCount = 0,
    this.stock = 100,
    this.specifications = const {},
    this.tags = const [],
    this.isFeatured = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'hindiName': hindiName,
        'category': category.name,
        'description': description,
        'price': price,
        'unit': unit,
        'imageAsset': imageAsset,
        'seller': seller,
        'rating': rating,
        'reviewCount': reviewCount,
        'stock': stock,
        'specifications': specifications,
        'tags': tags,
        'isFeatured': isFeatured,
      };
}

/// Item in shopping cart
class CartItemModel {
  final ProductModel product;
  int quantity;

  CartItemModel({
    required this.product,
    this.quantity = 1,
  });

  double get totalPrice => product.price * quantity;
}

/// Order placed by farmer
class OrderModel {
  final String id;
  final String farmerId;
  final List<CartItemModel> items;
  final double totalAmount;
  final String status; // pending, confirmed, shipped, delivered
  final DateTime orderedAt;
  final String deliveryAddress;

  const OrderModel({
    required this.id,
    required this.farmerId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.orderedAt,
    required this.deliveryAddress,
  });
}

// ============================================================================
// PRICE MODELS (MSP & Market)
// ============================================================================

/// Government Minimum Support Price
class MspPriceModel {
  final String cropName;
  final String hindiName;
  final double mspPrice; // ₹ per quintal
  final String season; // Kharif, Rabi
  final String year;
  final DateTime effectiveFrom;

  const MspPriceModel({
    required this.cropName,
    required this.hindiName,
    required this.mspPrice,
    required this.season,
    required this.year,
    required this.effectiveFrom,
  });

  /// Price per kg (MSP is usually in ₹/quintal)
  double get pricePerKg => mspPrice / 100;
}

/// Price trend direction
enum PriceTrend { up, down, stable }

/// Current market price with trend
class MarketTrendModel {
  final String cropName;
  final String hindiName;
  final double currentPrice; // ₹ per kg
  final double mspPricePerKg;
  final double priceChange7d; // Percentage
  final double priceChange30d; // Percentage
  final PriceTrend trend;
  final String demandLevel; // High, Medium, Low
  final String supplyLevel; // High, Medium, Low
  final DateTime updatedAt;
  final String market; // Mandi name

  const MarketTrendModel({
    required this.cropName,
    required this.hindiName,
    required this.currentPrice,
    required this.mspPricePerKg,
    required this.priceChange7d,
    required this.priceChange30d,
    required this.trend,
    required this.demandLevel,
    required this.supplyLevel,
    required this.updatedAt,
    this.market = 'Local Mandi',
  });

  /// Percentage above or below MSP
  double get mspDifferencePercent =>
      ((currentPrice - mspPricePerKg) / mspPricePerKg) * 100;

  bool get isAboveMsp => currentPrice >= mspPricePerKg;
}

// ============================================================================
// RECOMMENDATION MODELS
// ============================================================================

/// Recommended action for a crop
enum CropAction { sow, sell, hold, avoid }

extension CropActionExtension on CropAction {
  String get displayName {
    switch (this) {
      case CropAction.sow:
        return 'Sow Now';
      case CropAction.sell:
        return 'Sell Now';
      case CropAction.hold:
        return 'Hold';
      case CropAction.avoid:
        return 'Avoid';
    }
  }

  String get hindiName {
    switch (this) {
      case CropAction.sow:
        return 'अभी बोएं';
      case CropAction.sell:
        return 'अभी बेचें';
      case CropAction.hold:
        return 'रोकें';
      case CropAction.avoid:
        return 'बचें';
    }
  }
}

/// AI-powered crop recommendation
class CropRecommendationModel {
  final String cropName;
  final String hindiName;
  final CropAction action;
  final String reason;
  final String hindiReason;
  final double predictedPriceChange; // Expected % change
  final int optimalTimingDays; // Days until optimal action
  final double confidence; // 0.0 to 1.0
  final String season;
  final double expectedReturn; // ₹ per acre (for sow) or per quintal (for sell)

  const CropRecommendationModel({
    required this.cropName,
    required this.hindiName,
    required this.action,
    required this.reason,
    required this.hindiReason,
    required this.predictedPriceChange,
    required this.optimalTimingDays,
    required this.confidence,
    required this.season,
    required this.expectedReturn,
  });
}

// ============================================================================
// ALERT MODELS
// ============================================================================

/// Alert severity level
enum AlertSeverity { info, warning, critical }

/// Local overstock alert
class LocalStockAlertModel {
  final String cropName;
  final String hindiName;
  final String region;
  final double stockLevel; // Percentage above normal
  final AlertSeverity severity;
  final String message;
  final String hindiMessage;
  final String recommendation;
  final List<String> alternativeCrops;
  final DateTime createdAt;

  const LocalStockAlertModel({
    required this.cropName,
    required this.hindiName,
    required this.region,
    required this.stockLevel,
    required this.severity,
    required this.message,
    required this.hindiMessage,
    required this.recommendation,
    required this.alternativeCrops,
    required this.createdAt,
  });
}
