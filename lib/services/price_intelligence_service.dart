import 'package:kisaan_mitra/models/marketplace_models.dart';

/// Service for price intelligence - MSP, market prices, and trends
class PriceIntelligenceService {
  // Singleton pattern
  static final PriceIntelligenceService _instance =
      PriceIntelligenceService._internal();
  factory PriceIntelligenceService() => _instance;
  PriceIntelligenceService._internal() {
    _initMspData();
    _initMarketData();
  }

  final List<MspPriceModel> _mspPrices = [];
  final List<MarketTrendModel> _marketTrends = [];

  // ============================================================================
  // MSP (Minimum Support Price) DATA
  // ============================================================================

  /// Get all MSP prices
  List<MspPriceModel> getAllMspPrices() => List.from(_mspPrices);

  /// Get MSP for a specific crop
  MspPriceModel? getMspForCrop(String cropName) {
    try {
      return _mspPrices.firstWhere(
        (m) => m.cropName.toLowerCase() == cropName.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  /// Get MSP prices by season
  List<MspPriceModel> getMspBySeason(String season) {
    return _mspPrices
        .where((m) => m.season.toLowerCase() == season.toLowerCase())
        .toList();
  }

  // ============================================================================
  // MARKET TRENDS DATA
  // ============================================================================

  /// Get all market trends
  List<MarketTrendModel> getAllMarketTrends() => List.from(_marketTrends);

  /// Get market trend for a specific crop
  MarketTrendModel? getMarketTrendForCrop(String cropName) {
    try {
      return _marketTrends.firstWhere(
        (m) => m.cropName.toLowerCase() == cropName.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  /// Get crops with prices above MSP
  List<MarketTrendModel> getCropsAboveMsp() {
    return _marketTrends.where((m) => m.isAboveMsp).toList();
  }

  /// Get crops with prices below MSP
  List<MarketTrendModel> getCropsBelowMsp() {
    return _marketTrends.where((m) => !m.isAboveMsp).toList();
  }

  /// Get trending up crops
  List<MarketTrendModel> getTrendingUpCrops() {
    return _marketTrends.where((m) => m.trend == PriceTrend.up).toList();
  }

  /// Get trending down crops
  List<MarketTrendModel> getTrendingDownCrops() {
    return _marketTrends.where((m) => m.trend == PriceTrend.down).toList();
  }

  /// Compare your price with market and MSP
  Map<String, dynamic> comparePrices(String cropName, double yourPrice) {
    final msp = getMspForCrop(cropName);
    final market = getMarketTrendForCrop(cropName);

    return {
      'yourPrice': yourPrice,
      'mspPrice': msp?.pricePerKg,
      'marketPrice': market?.currentPrice,
      'vsMsp': msp != null
          ? ((yourPrice - msp.pricePerKg) / msp.pricePerKg * 100)
          : null,
      'vsMarket': market != null
          ? ((yourPrice - market.currentPrice) / market.currentPrice * 100)
          : null,
      'recommendation': _getPriceRecommendation(
          yourPrice, msp?.pricePerKg, market?.currentPrice),
    };
  }

  String _getPriceRecommendation(
      double yourPrice, double? msp, double? market) {
    if (msp == null || market == null) return 'Price data not available';

    if (yourPrice < msp) {
      return 'Your price is below MSP. Consider selling at MSP through government procurement.';
    } else if (yourPrice < market * 0.9) {
      return 'Your price is below market rate. You can increase your price.';
    } else if (yourPrice > market * 1.1) {
      return 'Your price is above market rate. Consider adjusting for faster sale.';
    } else {
      return 'Your price is competitive with current market rates.';
    }
  }

  // ============================================================================
  // MOCK DATA INITIALIZATION - Based on 2024-25 Government MSP
  // ============================================================================

  void _initMspData() {
    if (_mspPrices.isNotEmpty) return;

    // Rabi Crops 2024-25 MSP (per quintal)
    _mspPrices.addAll([
      MspPriceModel(
        cropName: 'Wheat',
        hindiName: 'गेहूं',
        mspPrice: 2275, // ₹/quintal
        season: 'Rabi',
        year: '2024-25',
        effectiveFrom: DateTime(2024, 10, 1),
      ),
      MspPriceModel(
        cropName: 'Barley',
        hindiName: 'जौ',
        mspPrice: 1850,
        season: 'Rabi',
        year: '2024-25',
        effectiveFrom: DateTime(2024, 10, 1),
      ),
      MspPriceModel(
        cropName: 'Gram (Chana)',
        hindiName: 'चना',
        mspPrice: 5440,
        season: 'Rabi',
        year: '2024-25',
        effectiveFrom: DateTime(2024, 10, 1),
      ),
      MspPriceModel(
        cropName: 'Masur (Lentil)',
        hindiName: 'मसूर',
        mspPrice: 6425,
        season: 'Rabi',
        year: '2024-25',
        effectiveFrom: DateTime(2024, 10, 1),
      ),
      MspPriceModel(
        cropName: 'Mustard',
        hindiName: 'सरसों',
        mspPrice: 5650,
        season: 'Rabi',
        year: '2024-25',
        effectiveFrom: DateTime(2024, 10, 1),
      ),
      MspPriceModel(
        cropName: 'Safflower',
        hindiName: 'कुसुम',
        mspPrice: 5800,
        season: 'Rabi',
        year: '2024-25',
        effectiveFrom: DateTime(2024, 10, 1),
      ),
    ]);

    // Kharif Crops 2024-25 MSP (per quintal)
    _mspPrices.addAll([
      MspPriceModel(
        cropName: 'Paddy (Rice)',
        hindiName: 'धान',
        mspPrice: 2300,
        season: 'Kharif',
        year: '2024-25',
        effectiveFrom: DateTime(2024, 6, 1),
      ),
      MspPriceModel(
        cropName: 'Jowar',
        hindiName: 'ज्वार',
        mspPrice: 3180,
        season: 'Kharif',
        year: '2024-25',
        effectiveFrom: DateTime(2024, 6, 1),
      ),
      MspPriceModel(
        cropName: 'Bajra',
        hindiName: 'बाजरा',
        mspPrice: 2500,
        season: 'Kharif',
        year: '2024-25',
        effectiveFrom: DateTime(2024, 6, 1),
      ),
      MspPriceModel(
        cropName: 'Maize',
        hindiName: 'मक्का',
        mspPrice: 2225,
        season: 'Kharif',
        year: '2024-25',
        effectiveFrom: DateTime(2024, 6, 1),
      ),
      MspPriceModel(
        cropName: 'Groundnut',
        hindiName: 'मूंगफली',
        mspPrice: 6377,
        season: 'Kharif',
        year: '2024-25',
        effectiveFrom: DateTime(2024, 6, 1),
      ),
      MspPriceModel(
        cropName: 'Soybean',
        hindiName: 'सोयाबीन',
        mspPrice: 4600,
        season: 'Kharif',
        year: '2024-25',
        effectiveFrom: DateTime(2024, 6, 1),
      ),
      MspPriceModel(
        cropName: 'Cotton (Medium)',
        hindiName: 'कपास (मध्यम)',
        mspPrice: 7020,
        season: 'Kharif',
        year: '2024-25',
        effectiveFrom: DateTime(2024, 6, 1),
      ),
      MspPriceModel(
        cropName: 'Cotton (Long)',
        hindiName: 'कपास (लंबा)',
        mspPrice: 7520,
        season: 'Kharif',
        year: '2024-25',
        effectiveFrom: DateTime(2024, 6, 1),
      ),
      MspPriceModel(
        cropName: 'Sugarcane',
        hindiName: 'गन्ना',
        mspPrice: 315, // FRP per quintal
        season: 'Kharif',
        year: '2024-25',
        effectiveFrom: DateTime(2024, 6, 1),
      ),
    ]);
  }

  void _initMarketData() {
    if (_marketTrends.isNotEmpty) return;

    final now = DateTime.now();

    _marketTrends.addAll([
      // Wheat - slight premium over MSP, stable
      MarketTrendModel(
        cropName: 'Wheat',
        hindiName: 'गेहूं',
        currentPrice: 24.5, // ₹/kg
        mspPricePerKg: 22.75,
        priceChange7d: 1.2,
        priceChange30d: 3.5,
        trend: PriceTrend.up,
        demandLevel: 'High',
        supplyLevel: 'Medium',
        updatedAt: now,
        market: 'Delhi Mandi',
      ),
      // Rice - above MSP, good demand
      MarketTrendModel(
        cropName: 'Paddy (Rice)',
        hindiName: 'धान',
        currentPrice: 26.0,
        mspPricePerKg: 23.0,
        priceChange7d: 2.5,
        priceChange30d: 5.8,
        trend: PriceTrend.up,
        demandLevel: 'High',
        supplyLevel: 'Medium',
        updatedAt: now,
        market: 'Karnal Mandi',
      ),
      // Maize - near MSP, oversupply
      MarketTrendModel(
        cropName: 'Maize',
        hindiName: 'मक्का',
        currentPrice: 21.5,
        mspPricePerKg: 22.25,
        priceChange7d: -1.8,
        priceChange30d: -4.2,
        trend: PriceTrend.down,
        demandLevel: 'Low',
        supplyLevel: 'High',
        updatedAt: now,
        market: 'Davangere Mandi',
      ),
      // Cotton - good premium
      MarketTrendModel(
        cropName: 'Cotton (Medium)',
        hindiName: 'कपास (मध्यम)',
        currentPrice: 72.5,
        mspPricePerKg: 70.2,
        priceChange7d: 0.5,
        priceChange30d: 2.1,
        trend: PriceTrend.stable,
        demandLevel: 'Medium',
        supplyLevel: 'Medium',
        updatedAt: now,
        market: 'Rajkot Mandi',
      ),
      // Soybean - trending up
      MarketTrendModel(
        cropName: 'Soybean',
        hindiName: 'सोयाबीन',
        currentPrice: 52.0,
        mspPricePerKg: 46.0,
        priceChange7d: 4.2,
        priceChange30d: 8.5,
        trend: PriceTrend.up,
        demandLevel: 'High',
        supplyLevel: 'Low',
        updatedAt: now,
        market: 'Indore Mandi',
      ),
      // Mustard - premium pricing
      MarketTrendModel(
        cropName: 'Mustard',
        hindiName: 'सरसों',
        currentPrice: 62.0,
        mspPricePerKg: 56.5,
        priceChange7d: 1.8,
        priceChange30d: 4.5,
        trend: PriceTrend.up,
        demandLevel: 'High',
        supplyLevel: 'Medium',
        updatedAt: now,
        market: 'Jaipur Mandi',
      ),
      // Gram - below MSP, oversupply
      MarketTrendModel(
        cropName: 'Gram (Chana)',
        hindiName: 'चना',
        currentPrice: 50.0,
        mspPricePerKg: 54.4,
        priceChange7d: -2.5,
        priceChange30d: -6.8,
        trend: PriceTrend.down,
        demandLevel: 'Low',
        supplyLevel: 'High',
        updatedAt: now,
        market: 'Nagpur Mandi',
      ),
      // Potato - volatile
      MarketTrendModel(
        cropName: 'Potato',
        hindiName: 'आलू',
        currentPrice: 18.0,
        mspPricePerKg: 0, // No MSP for potato
        priceChange7d: -5.2,
        priceChange30d: -12.5,
        trend: PriceTrend.down,
        demandLevel: 'Medium',
        supplyLevel: 'High',
        updatedAt: now,
        market: 'Agra Mandi',
      ),
      // Onion - seasonal spike
      MarketTrendModel(
        cropName: 'Onion',
        hindiName: 'प्याज',
        currentPrice: 32.0,
        mspPricePerKg: 0, // No MSP for onion
        priceChange7d: 8.5,
        priceChange30d: 25.0,
        trend: PriceTrend.up,
        demandLevel: 'High',
        supplyLevel: 'Low',
        updatedAt: now,
        market: 'Nashik Mandi',
      ),
      // Tomato - seasonal
      MarketTrendModel(
        cropName: 'Tomato',
        hindiName: 'टमाटर',
        currentPrice: 45.0,
        mspPricePerKg: 0, // No MSP
        priceChange7d: 15.2,
        priceChange30d: 35.0,
        trend: PriceTrend.up,
        demandLevel: 'High',
        supplyLevel: 'Low',
        updatedAt: now,
        market: 'Kolar Mandi',
      ),
    ]);
  }
}
