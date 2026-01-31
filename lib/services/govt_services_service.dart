// Government Services Service
// Integrates with data.gov.in API for mandi prices and provides scheme information

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kisaan_mitra/models/govt_services_models.dart';

class GovtServicesService {
  // Singleton pattern
  static final GovtServicesService _instance = GovtServicesService._internal();
  factory GovtServicesService() => _instance;
  GovtServicesService._internal();

  // data.gov.in API configuration
  // Note: Get your own API key from https://data.gov.in/
  static const String _dataGovApiKey =
      '579b464db66ec23bdd000001cdd3946e44ce4aad7209ff7b23ac571b';
  static const String _dataGovBaseUrl = 'https://api.data.gov.in/resource';

  // Resource IDs for different datasets
  static const String _mandiPricesResourceId =
      '9ef84268-d588-465a-a308-a864a43d0070';

  // ============================================================================
  // MANDI PRICES - REAL API
  // ============================================================================

  /// Fetch current mandi prices from data.gov.in
  Future<List<MandiPrice>> getMandiPrices({
    String? state,
    String? district,
    String? commodity,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final queryParams = {
        'api-key': _dataGovApiKey,
        'format': 'json',
        'limit': limit.toString(),
        'offset': offset.toString(),
      };

      if (state != null && state.isNotEmpty) {
        queryParams['filters[state]'] = state;
      }
      if (district != null && district.isNotEmpty) {
        queryParams['filters[district]'] = district;
      }
      if (commodity != null && commodity.isNotEmpty) {
        queryParams['filters[commodity]'] = commodity;
      }

      final uri = Uri.parse('$_dataGovBaseUrl/$_mandiPricesResourceId')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final records = data['records'] as List<dynamic>? ?? [];

        return records.map((json) => MandiPrice.fromJson(json)).toList();
      } else {
        print('Mandi API error: ${response.statusCode}');
        // Return mock data as fallback
        return _getMockMandiPrices(commodity: commodity);
      }
    } catch (e) {
      print('Error fetching mandi prices: $e');
      // Return mock data as fallback
      return _getMockMandiPrices(commodity: commodity);
    }
  }

  /// Get list of available states
  List<String> getStates() {
    return [
      'Andhra Pradesh',
      'Arunachal Pradesh',
      'Assam',
      'Bihar',
      'Chhattisgarh',
      'Goa',
      'Gujarat',
      'Haryana',
      'Himachal Pradesh',
      'Jharkhand',
      'Karnataka',
      'Kerala',
      'Madhya Pradesh',
      'Maharashtra',
      'Manipur',
      'Meghalaya',
      'Mizoram',
      'Nagaland',
      'Odisha',
      'Punjab',
      'Rajasthan',
      'Sikkim',
      'Tamil Nadu',
      'Telangana',
      'Tripura',
      'Uttar Pradesh',
      'Uttarakhand',
      'West Bengal',
      'Delhi',
    ];
  }

  /// Get list of common commodities
  List<String> getCommodities() {
    return [
      'Rice',
      'Wheat',
      'Maize',
      'Bajra',
      'Jowar',
      'Barley',
      'Ragi',
      'Arhar',
      'Moong',
      'Masoor',
      'Urad',
      'Gram',
      'Groundnut',
      'Mustard',
      'Soyabean',
      'Sunflower',
      'Cotton',
      'Jute',
      'Sugarcane',
      'Potato',
      'Onion',
      'Tomato',
      'Brinjal',
      'Cabbage',
      'Cauliflower',
      'Lady Finger',
      'Green Chilli',
      'Ginger',
      'Garlic',
      'Turmeric',
      'Coriander',
      'Banana',
      'Mango',
      'Orange',
      'Apple',
      'Grapes',
      'Papaya',
    ];
  }

  /// Mock mandi prices for fallback
  List<MandiPrice> _getMockMandiPrices({String? commodity}) {
    final mockData = [
      MandiPrice(
        state: 'Uttar Pradesh',
        district: 'Ghaziabad',
        market: 'Loni',
        commodity: commodity ?? 'Wheat',
        variety: 'Lokwan',
        grade: 'Medium',
        minPrice: 2150,
        maxPrice: 2350,
        modalPrice: 2275,
        arrivalDate: DateTime.now(),
      ),
      MandiPrice(
        state: 'Uttar Pradesh',
        district: 'Noida',
        market: 'Noida',
        commodity: commodity ?? 'Wheat',
        variety: 'Lokwan',
        grade: 'Medium',
        minPrice: 2100,
        maxPrice: 2300,
        modalPrice: 2200,
        arrivalDate: DateTime.now(),
      ),
      MandiPrice(
        state: 'Haryana',
        district: 'Gurgaon',
        market: 'Sohna',
        commodity: commodity ?? 'Wheat',
        variety: 'Sharbati',
        grade: 'FAQ',
        minPrice: 2200,
        maxPrice: 2400,
        modalPrice: 2350,
        arrivalDate: DateTime.now(),
      ),
      MandiPrice(
        state: 'Punjab',
        district: 'Amritsar',
        market: 'Amritsar',
        commodity: commodity ?? 'Wheat',
        variety: 'Lokwan',
        grade: 'FAQ',
        minPrice: 2250,
        maxPrice: 2450,
        modalPrice: 2375,
        arrivalDate: DateTime.now(),
      ),
      MandiPrice(
        state: 'Madhya Pradesh',
        district: 'Indore',
        market: 'Indore',
        commodity: commodity ?? 'Wheat',
        variety: 'Sehore',
        grade: 'FAQ',
        minPrice: 2180,
        maxPrice: 2380,
        modalPrice: 2280,
        arrivalDate: DateTime.now(),
      ),
    ];
    return mockData;
  }

  // ============================================================================
  // GOVERNMENT SCHEMES - STATIC DATA
  // ============================================================================

  /// Get all government schemes
  List<GovtScheme> getSchemes() {
    return [
      GovtScheme(
        id: 'pm-kisan',
        name: 'PM-KISAN',
        nameHindi: 'प्रधानमंत्री किसान सम्मान निधि',
        description:
            'Direct income support of ₹6,000 per year in three equal installments to small and marginal farmer families.',
        category: 'subsidy',
        eligibility:
            'All landholding farmer families with cultivable land. Excludes income tax payers, government employees.',
        benefits:
            '₹6,000 per year (₹2,000 every 4 months) directly to bank account',
        applicationProcess:
            '1. Visit pmkisan.gov.in\n2. Click on New Farmer Registration\n3. Enter Aadhaar and mobile number\n4. Fill land details\n5. Submit and verify',
        websiteUrl: 'https://pmkisan.gov.in/',
        iconName: 'account_balance_wallet',
        isActive: true,
      ),
      GovtScheme(
        id: 'pmfby',
        name: 'PMFBY - Crop Insurance',
        nameHindi: 'प्रधानमंत्री फसल बीमा योजना',
        description:
            'Comprehensive crop insurance to protect farmers against crop loss due to natural calamities, pests & diseases.',
        category: 'insurance',
        eligibility:
            'All farmers growing notified crops in notified areas. Mandatory for loanee farmers, voluntary for others.',
        benefits:
            'Full sum insured for crop loss. Premium: 2% for Kharif, 1.5% for Rabi, 5% for commercial crops.',
        applicationProcess:
            '1. Visit pmfby.gov.in\n2. Register with Aadhaar\n3. Select crop and area\n4. Pay premium\n5. Get insurance certificate',
        websiteUrl: 'https://pmfby.gov.in/',
        iconName: 'security',
        isActive: true,
        deadline: DateTime(2026, 2, 15),
      ),
      GovtScheme(
        id: 'pm-kusum',
        name: 'PM-KUSUM',
        nameHindi: 'प्रधानमंत्री किसान ऊर्जा सुरक्षा एवं उत्थान महाभियान',
        description:
            'Solar pump subsidy scheme to reduce dependence on grid/diesel and promote clean energy in agriculture.',
        category: 'subsidy',
        eligibility:
            'Individual farmers, groups, cooperatives, FPOs, water user associations with land ownership.',
        benefits:
            '60% subsidy on solar pumps (30% Central + 30% State). Earn by selling surplus power to grid.',
        applicationProcess:
            '1. Apply through state agriculture department\n2. Submit land documents\n3. Select pump capacity\n4. Installation by empanelled vendor',
        websiteUrl: 'https://pmkusum.mnre.gov.in/',
        iconName: 'solar_power',
        isActive: true,
      ),
      GovtScheme(
        id: 'kcc',
        name: 'Kisan Credit Card',
        nameHindi: 'किसान क्रेडिट कार्ड',
        description:
            'Affordable credit for farmers to meet their agricultural and allied activities expenses.',
        category: 'credit',
        eligibility:
            'All farmers including tenant farmers, oral lessees, sharecroppers, self-help groups, joint liability groups.',
        benefits:
            'Credit limit based on land holding. Interest rate: 7% (effective 4% with timely repayment). Crop insurance included.',
        applicationProcess:
            '1. Apply at any bank branch\n2. Submit land records, ID proof\n3. Bank verification\n4. Card issuance within 15 days',
        websiteUrl: 'https://www.pmkisan.gov.in/KccFarmer.aspx',
        iconName: 'credit_card',
        isActive: true,
      ),
      GovtScheme(
        id: 'soil-health',
        name: 'Soil Health Card',
        nameHindi: 'मृदा स्वास्थ्य कार्ड',
        description:
            'Free soil testing and nutrient-based crop recommendations for every farm.',
        category: 'advisory',
        eligibility:
            'All farmers. Every farm should get tested once in 3 years.',
        benefits:
            'Free soil test report with NPK status, pH, EC. Crop-wise fertilizer recommendations. Reduces input costs.',
        applicationProcess:
            '1. Visit nearest Soil Testing Lab\n2. Submit soil sample\n3. Receive card in 2-3 weeks\n4. View online at soilhealth.dac.gov.in',
        websiteUrl: 'https://soilhealth.dac.gov.in/',
        iconName: 'eco',
        isActive: true,
      ),
      GovtScheme(
        id: 'enam',
        name: 'e-NAM',
        nameHindi: 'राष्ट्रीय कृषि बाजार',
        description:
            'Online trading platform for agricultural produce across India for transparent price discovery.',
        category: 'market',
        eligibility:
            'All farmers, traders, FPOs. APMCs linked to eNAM platform.',
        benefits:
            'Better price discovery. Reduced intermediaries. Direct payment to bank. Access to distant buyers.',
        applicationProcess:
            '1. Register at enam.gov.in\n2. Verify with Aadhaar\n3. Link bank account\n4. Start trading',
        websiteUrl: 'https://enam.gov.in/',
        iconName: 'storefront',
        isActive: true,
      ),
    ];
  }

  /// Get schemes by category
  List<GovtScheme> getSchemesByCategory(String category) {
    return getSchemes().where((s) => s.category == category).toList();
  }

  /// Get scheme by ID
  GovtScheme? getSchemeById(String id) {
    try {
      return getSchemes().firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  // ============================================================================
  // PMFBY INSURANCE CALCULATOR
  // ============================================================================

  /// Calculate crop insurance premium
  InsuranceCalculation calculateInsurancePremium({
    required String cropName,
    required String season, // Kharif, Rabi, Commercial
    required double sumInsured,
  }) {
    double premiumRate;

    switch (season.toLowerCase()) {
      case 'kharif':
        premiumRate = 2.0; // 2% for Kharif crops
        break;
      case 'rabi':
        premiumRate = 1.5; // 1.5% for Rabi crops
        break;
      case 'commercial':
      case 'horticultural':
        premiumRate = 5.0; // 5% for commercial/horticultural crops
        break;
      default:
        premiumRate = 2.0;
    }

    final farmerPremium = sumInsured * (premiumRate / 100);
    final govtSubsidy =
        sumInsured - farmerPremium; // Simplified - actual is more complex

    return InsuranceCalculation(
      cropName: cropName,
      season: season,
      sumInsured: sumInsured,
      premiumRate: premiumRate,
      farmerPremium: farmerPremium,
      govtSubsidy: govtSubsidy,
    );
  }

  // ============================================================================
  // AGRO ADVISORIES - MOCK DATA
  // ============================================================================

  /// Get agro advisories
  List<AgroAdvisory> getAdvisories({String? state, String? category}) {
    final advisories = [
      AgroAdvisory(
        id: 'adv_1',
        title: 'Wheat Sowing Advisory - Rabi 2025-26',
        content: 'Recommended varieties: HD-3226, PBW-781, DBW-222. '
            'Sowing period: Nov 1-25. Seed rate: 100 kg/ha. '
            'Apply 60 kg N, 40 kg P2O5, 30 kg K2O per hectare.',
        source: 'ICAR-IARI, New Delhi',
        category: 'crop',
        publishedDate: DateTime.now().subtract(const Duration(days: 2)),
        state: 'Uttar Pradesh',
      ),
      AgroAdvisory(
        id: 'adv_2',
        title: 'Alert: Yellow Rust in Wheat',
        content:
            'Yellow rust symptoms observed in parts of Punjab and Haryana. '
            'Spray Propiconazole 25EC @ 0.1% immediately if symptoms appear. '
            'Avoid late sowing to reduce disease incidence.',
        source: 'PAU, Ludhiana',
        category: 'pest',
        publishedDate: DateTime.now().subtract(const Duration(days: 1)),
        state: 'Punjab',
      ),
      AgroAdvisory(
        id: 'adv_3',
        title: 'Cold Wave Advisory',
        content: 'Cold wave expected in North India Jan 30 - Feb 5. '
            'Protect vegetables with plastic mulch. '
            'Light irrigation in evening to protect from frost. '
            'Cover nurseries at night.',
        source: 'IMD Weather Advisory',
        category: 'weather',
        publishedDate: DateTime.now(),
      ),
      AgroAdvisory(
        id: 'adv_4',
        title: 'Mustard Aphid Management',
        content: 'Aphid infestation increasing in mustard crop. '
            'Economic threshold: 50 aphids per 10 cm central shoot. '
            'Spray Dimethoate 30EC @ 1ml/L or Imidacloprid 17.8SL @ 0.3ml/L.',
        source: 'KVK Ghaziabad',
        category: 'pest',
        publishedDate: DateTime.now().subtract(const Duration(days: 3)),
        state: 'Uttar Pradesh',
      ),
    ];

    return advisories.where((a) {
      if (category != null && a.category != category) return false;
      if (state != null && a.state != null && a.state != state) return false;
      return true;
    }).toList();
  }

  // ============================================================================
  // DEALERS - MOCK DATA
  // ============================================================================

  /// Get nearby dealers
  List<DealerInfo> getDealers({String? district, String? type}) {
    final dealers = [
      DealerInfo(
        id: 'd1',
        name: 'Kisan Seva Kendra',
        type: 'seeds',
        address: 'Main Market, Loni',
        district: 'Ghaziabad',
        state: 'Uttar Pradesh',
        phone: '9876543210',
        isVerified: true,
      ),
      DealerInfo(
        id: 'd2',
        name: 'Agro Fertilizers Pvt Ltd',
        type: 'fertilizers',
        address: 'Industrial Area',
        district: 'Ghaziabad',
        state: 'Uttar Pradesh',
        phone: '9876543211',
        isVerified: true,
      ),
      DealerInfo(
        id: 'd3',
        name: 'Shri Ram Seeds',
        type: 'seeds',
        address: 'Kisan Mandi',
        district: 'Noida',
        state: 'Uttar Pradesh',
        phone: '9876543212',
        isVerified: true,
      ),
      DealerInfo(
        id: 'd4',
        name: 'Bharat Pesticides',
        type: 'pesticides',
        address: 'Agriculture Market',
        district: 'Ghaziabad',
        state: 'Uttar Pradesh',
        phone: '9876543213',
        isVerified: true,
      ),
      DealerInfo(
        id: 'd5',
        name: 'Mahindra Tractors',
        type: 'machinery',
        address: 'GT Road',
        district: 'Ghaziabad',
        state: 'Uttar Pradesh',
        phone: '9876543214',
        isVerified: true,
      ),
    ];

    return dealers.where((d) {
      if (type != null && d.type != type) return false;
      if (district != null && d.district != district) return false;
      return true;
    }).toList();
  }

  // ============================================================================
  // STORAGE FACILITIES - MOCK DATA
  // ============================================================================

  /// Get storage facilities
  List<StorageFacility> getStorageFacilities({String? district, String? type}) {
    final facilities = [
      StorageFacility(
        id: 's1',
        name: 'FCI Godown Loni',
        type: 'godown',
        address: 'Industrial Area, Loni',
        district: 'Ghaziabad',
        state: 'Uttar Pradesh',
        capacityMT: 5000,
        phone: '0120-2345678',
        ownerName: 'FCI',
      ),
      StorageFacility(
        id: 's2',
        name: 'Kisan Cold Storage',
        type: 'cold_storage',
        address: 'Meerut Road',
        district: 'Ghaziabad',
        state: 'Uttar Pradesh',
        capacityMT: 2000,
        phone: '9876500001',
        ownerName: 'Private',
      ),
      StorageFacility(
        id: 's3',
        name: 'State Warehouse Corporation',
        type: 'warehouse',
        address: 'Sector 63',
        district: 'Noida',
        state: 'Uttar Pradesh',
        capacityMT: 10000,
        phone: '0120-2345679',
      ),
    ];

    return facilities.where((f) {
      if (type != null && f.type != type) return false;
      if (district != null && f.district != district) return false;
      return true;
    }).toList();
  }

  // ============================================================================
  // HELPLINE INFORMATION
  // ============================================================================

  Map<String, String> getHelplines() {
    return {
      'Kisan Call Center': '1800-180-1551',
      'PM-KISAN Helpline': '155261',
      'PMFBY Helpline': '1800-200-7710',
      'Soil Health Card': '1800-180-1551',
      'e-NAM Helpline': '1800-270-0224',
      'Agriculture Emergency': '1800-180-1515',
    };
  }

  /// Get service categories for hub display
  List<ServiceCategory> getServiceCategories() {
    return [
      ServiceCategory(
        id: 'schemes', title: 'Schemes', titleHindi: 'योजनाएं',
        icon: 'assignment', route: '/govt-services/schemes',
        description: 'PM-KISAN, PMFBY, KCC & more',
        color: 0xFF4CAF50, // Green
      ),
      ServiceCategory(
        id: 'insurance', title: 'Crop Insurance', titleHindi: 'फसल बीमा',
        icon: 'security', route: '/govt-services/insurance',
        description: 'PMFBY calculator & status',
        color: 0xFF2196F3, // Blue
      ),
      ServiceCategory(
        id: 'mandi', title: 'Mandi Prices', titleHindi: 'मंडी भाव',
        icon: 'trending_up', route: '/govt-services/mandi',
        description: 'Live market rates',
        color: 0xFFFF9800, // Orange
      ),
      ServiceCategory(
        id: 'advisory', title: 'Advisories', titleHindi: 'सलाह',
        icon: 'tips_and_updates', route: '/govt-services/advisory',
        description: 'Expert farming tips',
        color: 0xFF9C27B0, // Purple
      ),
      ServiceCategory(
        id: 'dealers', title: 'Dealers', titleHindi: 'डीलर',
        icon: 'store', route: '/govt-services/dealers',
        description: 'Seeds, fertilizers nearby',
        color: 0xFF795548, // Brown
      ),
      ServiceCategory(
        id: 'helpline', title: 'Helpline', titleHindi: 'हेल्पलाइन',
        icon: 'support_agent', route: '/govt-services/helpline',
        description: 'Kisan Call Center',
        color: 0xFFE91E63, // Pink
      ),
    ];
  }
}
