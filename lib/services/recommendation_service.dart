import 'package:kisaan_mitra/models/marketplace_models.dart';

/// Service for AI-powered crop recommendations and alerts
class RecommendationService {
  // Singleton pattern
  static final RecommendationService _instance =
      RecommendationService._internal();
  factory RecommendationService() => _instance;
  RecommendationService._internal() {
    _initRecommendations();
    _initAlerts();
  }

  final List<CropRecommendationModel> _sowRecommendations = [];
  final List<CropRecommendationModel> _sellRecommendations = [];
  final List<LocalStockAlertModel> _alerts = [];

  // ============================================================================
  // SOW RECOMMENDATIONS
  // ============================================================================

  /// Get crops to sow this season
  List<CropRecommendationModel> getSowRecommendations() =>
      List.from(_sowRecommendations);

  /// Get top N sow recommendations
  List<CropRecommendationModel> getTopSowRecommendations(int count) {
    final sorted = List<CropRecommendationModel>.from(_sowRecommendations)
      ..sort((a, b) => b.confidence.compareTo(a.confidence));
    return sorted.take(count).toList();
  }

  /// Get recommendations by season
  List<CropRecommendationModel> getSowRecommendationsBySeason(String season) {
    return _sowRecommendations
        .where((r) => r.season.toLowerCase() == season.toLowerCase())
        .toList();
  }

  // ============================================================================
  // SELL RECOMMENDATIONS
  // ============================================================================

  /// Get crops to sell now
  List<CropRecommendationModel> getSellRecommendations() =>
      List.from(_sellRecommendations);

  /// Get sell recommendation for specific crop
  CropRecommendationModel? getSellRecommendationForCrop(String cropName) {
    try {
      return _sellRecommendations.firstWhere(
        (r) => r.cropName.toLowerCase() == cropName.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  /// Get "Sell Now" recommendations
  List<CropRecommendationModel> getSellNowRecommendations() {
    return _sellRecommendations
        .where((r) => r.action == CropAction.sell)
        .toList();
  }

  /// Get "Hold" recommendations
  List<CropRecommendationModel> getHoldRecommendations() {
    return _sellRecommendations
        .where((r) => r.action == CropAction.hold)
        .toList();
  }

  // ============================================================================
  // OVERSTOCK ALERTS
  // ============================================================================

  /// Get all overstock alerts
  List<LocalStockAlertModel> getOverstockAlerts() => List.from(_alerts);

  /// Get alerts by severity
  List<LocalStockAlertModel> getAlertsBySeverity(AlertSeverity severity) {
    return _alerts.where((a) => a.severity == severity).toList();
  }

  /// Get alerts for a region
  List<LocalStockAlertModel> getAlertsForRegion(String region) {
    return _alerts
        .where((a) => a.region.toLowerCase().contains(region.toLowerCase()))
        .toList();
  }

  /// Get critical alerts
  List<LocalStockAlertModel> getCriticalAlerts() {
    return _alerts.where((a) => a.severity == AlertSeverity.critical).toList();
  }

  // ============================================================================
  // DEMAND PREDICTIONS
  // ============================================================================

  /// Get demand prediction for a crop (returns expected % price change)
  Map<String, dynamic> getDemandPrediction(String cropName, int monthsAhead) {
    // Simulated prediction based on historical patterns
    final predictions = <String, Map<String, dynamic>>{
      'wheat': {
        'currentDemand': 'Medium',
        'prediction3m': 15.5,
        'prediction6m': 22.0,
        'reason': 'Festival season demand expected to increase',
        'confidence': 0.78,
      },
      'rice': {
        'currentDemand': 'High',
        'prediction3m': 8.2,
        'prediction6m': 12.5,
        'reason': 'Steady export demand, limited supply',
        'confidence': 0.82,
      },
      'soybean': {
        'currentDemand': 'High',
        'prediction3m': 12.0,
        'prediction6m': 18.5,
        'reason': 'Growing demand from oil industry',
        'confidence': 0.75,
      },
      'cotton': {
        'currentDemand': 'Medium',
        'prediction3m': 5.0,
        'prediction6m': 8.0,
        'reason': 'Textile industry recovery',
        'confidence': 0.68,
      },
      'maize': {
        'currentDemand': 'Low',
        'prediction3m': -5.0,
        'prediction6m': 2.0,
        'reason': 'Oversupply expected to continue',
        'confidence': 0.72,
      },
    };

    final crop = cropName.toLowerCase();
    if (predictions.containsKey(crop)) {
      final data = predictions[crop]!;
      return {
        ...data,
        'predictedChange':
            monthsAhead <= 3 ? data['prediction3m'] : data['prediction6m'],
      };
    }

    return {
      'currentDemand': 'Unknown',
      'predictedChange': 0.0,
      'reason': 'Insufficient data for prediction',
      'confidence': 0.0,
    };
  }

  // ============================================================================
  // MOCK DATA INITIALIZATION
  // ============================================================================

  void _initRecommendations() {
    if (_sowRecommendations.isNotEmpty) return;

    // ==================== SOW RECOMMENDATIONS (Current Season - Rabi) ====================
    _sowRecommendations.addAll([
      const CropRecommendationModel(
        cropName: 'Wheat',
        hindiName: 'गेहूं',
        action: CropAction.sow,
        reason:
            'Optimal sowing time. High demand expected in March-April. MSP increased by 5%.',
        hindiReason:
            'बुवाई का उचित समय। मार्च-अप्रैल में उच्च मांग की उम्मीद। MSP में 5% की वृद्धि।',
        predictedPriceChange: 8.5,
        optimalTimingDays: 0, // Sow now
        confidence: 0.85,
        season: 'Rabi',
        expectedReturn: 45000, // ₹ per acre
      ),
      const CropRecommendationModel(
        cropName: 'Mustard',
        hindiName: 'सरसों',
        action: CropAction.sow,
        reason:
            'Oil prices rising. Lower production last year means higher prices expected.',
        hindiReason:
            'तेल की कीमतें बढ़ रही हैं। पिछले साल कम उत्पादन से उच्च कीमतों की उम्मीद।',
        predictedPriceChange: 12.0,
        optimalTimingDays: 0,
        confidence: 0.82,
        season: 'Rabi',
        expectedReturn: 38000,
      ),
      const CropRecommendationModel(
        cropName: 'Gram (Chana)',
        hindiName: 'चना',
        action: CropAction.avoid,
        reason:
            'Oversupply in market. Prices below MSP. Consider alternatives.',
        hindiReason:
            'बाजार में अधिक आपूर्ति। MSP से कम कीमतें। विकल्प पर विचार करें।',
        predictedPriceChange: -8.0,
        optimalTimingDays: 0,
        confidence: 0.78,
        season: 'Rabi',
        expectedReturn: 25000,
      ),
      const CropRecommendationModel(
        cropName: 'Peas',
        hindiName: 'मटर',
        action: CropAction.sow,
        reason: 'Short duration crop. High vegetable demand in winter.',
        hindiReason: 'कम अवधि की फसल। सर्दियों में सब्जी की उच्च मांग।',
        predictedPriceChange: 15.0,
        optimalTimingDays: 0,
        confidence: 0.75,
        season: 'Rabi',
        expectedReturn: 50000,
      ),
      const CropRecommendationModel(
        cropName: 'Potato',
        hindiName: 'आलू',
        action: CropAction.avoid,
        reason:
            'Oversupply expected. Prices crashed last season. High storage costs.',
        hindiReason:
            'अधिक आपूर्ति की उम्मीद। पिछले सीजन में कीमतें गिरीं। भंडारण लागत अधिक।',
        predictedPriceChange: -15.0,
        optimalTimingDays: 0,
        confidence: 0.80,
        season: 'Rabi',
        expectedReturn: 30000,
      ),
    ]);

    // ==================== SELL RECOMMENDATIONS ====================
    _sellRecommendations.addAll([
      const CropRecommendationModel(
        cropName: 'Soybean',
        hindiName: 'सोयाबीन',
        action: CropAction.sell,
        reason:
            'Prices 15% above MSP. Oil industry demand high. Sell before new arrivals.',
        hindiReason:
            'कीमतें MSP से 15% अधिक। तेल उद्योग की मांग अधिक। नई आवक से पहले बेचें।',
        predictedPriceChange: -5.0, // Expected to drop
        optimalTimingDays: 0, // Sell now
        confidence: 0.88,
        season: 'Kharif',
        expectedReturn: 5200, // ₹ per quintal
      ),
      const CropRecommendationModel(
        cropName: 'Paddy (Rice)',
        hindiName: 'धान',
        action: CropAction.sell,
        reason:
            'Government procurement active. MSP guaranteed. Avoid storage losses.',
        hindiReason: 'सरकारी खरीद जारी। MSP की गारंटी। भंडारण हानि से बचें।',
        predictedPriceChange: 2.0,
        optimalTimingDays: 0,
        confidence: 0.90,
        season: 'Kharif',
        expectedReturn: 2400,
      ),
      const CropRecommendationModel(
        cropName: 'Cotton (Medium)',
        hindiName: 'कपास (मध्यम)',
        action: CropAction.hold,
        reason:
            'Prices expected to rise in January. Textile demand increasing.',
        hindiReason: 'जनवरी में कीमतें बढ़ने की उम्मीद। कपड़ा मांग बढ़ रही है।',
        predictedPriceChange: 8.0,
        optimalTimingDays: 30, // Wait 30 days
        confidence: 0.72,
        season: 'Kharif',
        expectedReturn: 7500,
      ),
      const CropRecommendationModel(
        cropName: 'Maize',
        hindiName: 'मक्का',
        action: CropAction.hold,
        reason:
            'Current prices below MSP. Wait for poultry demand to increase.',
        hindiReason:
            'वर्तमान कीमतें MSP से कम। पोल्ट्री मांग बढ़ने की प्रतीक्षा करें।',
        predictedPriceChange: 10.0,
        optimalTimingDays: 45,
        confidence: 0.65,
        season: 'Kharif',
        expectedReturn: 2400,
      ),
      const CropRecommendationModel(
        cropName: 'Onion',
        hindiName: 'प्याज',
        action: CropAction.sell,
        reason:
            'Prices at peak due to shortage. Government may impose export ban.',
        hindiReason:
            'कमी के कारण कीमतें चरम पर। सरकार निर्यात प्रतिबंध लगा सकती है।',
        predictedPriceChange: -20.0,
        optimalTimingDays: 0,
        confidence: 0.85,
        season: 'Kharif',
        expectedReturn: 3200,
      ),
      const CropRecommendationModel(
        cropName: 'Tomato',
        hindiName: 'टमाटर',
        action: CropAction.sell,
        reason:
            'Seasonal peak prices. New crop arrival in 2 weeks will crash prices.',
        hindiReason:
            'मौसमी चरम कीमतें। 2 सप्ताह में नई फसल आने से कीमतें गिरेंगी।',
        predictedPriceChange: -35.0,
        optimalTimingDays: 0,
        confidence: 0.92,
        season: 'Rabi',
        expectedReturn: 4500,
      ),
    ]);
  }

  void _initAlerts() {
    if (_alerts.isNotEmpty) return;

    final now = DateTime.now();

    _alerts.addAll([
      LocalStockAlertModel(
        cropName: 'Potato',
        hindiName: 'आलू',
        region: 'Uttar Pradesh',
        stockLevel: 45.0, // 45% above normal
        severity: AlertSeverity.critical,
        message: 'Potato oversupply in UP. Prices crashed 25% in last week.',
        hindiMessage:
            'यूपी में आलू की अधिक आपूर्ति। पिछले सप्ताह कीमतों में 25% की गिरावट।',
        recommendation:
            'Avoid planting potato this season. Consider wheat or mustard.',
        alternativeCrops: ['Wheat', 'Mustard', 'Peas'],
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      LocalStockAlertModel(
        cropName: 'Gram (Chana)',
        hindiName: 'चना',
        region: 'Madhya Pradesh',
        stockLevel: 32.0,
        severity: AlertSeverity.warning,
        message: 'Chana stocks 32% above normal. Market prices below MSP.',
        hindiMessage:
            'चना का स्टॉक सामान्य से 32% अधिक। बाजार मूल्य MSP से कम।',
        recommendation: 'Sell through government procurement centers at MSP.',
        alternativeCrops: ['Soybean', 'Wheat'],
        createdAt: now.subtract(const Duration(hours: 6)),
      ),
      LocalStockAlertModel(
        cropName: 'Maize',
        hindiName: 'मक्का',
        region: 'Karnataka',
        stockLevel: 28.0,
        severity: AlertSeverity.warning,
        message: 'Maize oversupply affecting prices in Karnataka region.',
        hindiMessage:
            'कर्नाटक में मक्का की अधिक आपूर्ति कीमतों को प्रभावित कर रही है।',
        recommendation: 'Store in hermetic bags and wait for poultry demand.',
        alternativeCrops: ['Ragi', 'Jowar'],
        createdAt: now.subtract(const Duration(hours: 12)),
      ),
      LocalStockAlertModel(
        cropName: 'Tomato',
        hindiName: 'टमाटर',
        region: 'Andhra Pradesh',
        stockLevel: 15.0,
        severity: AlertSeverity.info,
        message: 'Tomato supply normalizing. New arrivals expected soon.',
        hindiMessage:
            'टमाटर की आपूर्ति सामान्य हो रही है। जल्द नई आवक की उम्मीद।',
        recommendation: 'Sell current stock quickly before prices drop.',
        alternativeCrops: [],
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    ]);
  }
}
