// Government Services Models
// Models for schemes, mandi prices, advisories, and dealers

/// Government scheme model
class GovtScheme {
  final String id;
  final String name;
  final String nameHindi;
  final String description;
  final String category; // insurance, subsidy, credit, training
  final String eligibility;
  final String benefits;
  final String applicationProcess;
  final String websiteUrl;
  final String? iconName;
  final bool isActive;
  final DateTime? deadline;

  const GovtScheme({
    required this.id,
    required this.name,
    this.nameHindi = '',
    required this.description,
    required this.category,
    required this.eligibility,
    required this.benefits,
    required this.applicationProcess,
    required this.websiteUrl,
    this.iconName,
    this.isActive = true,
    this.deadline,
  });
}

/// Mandi price record from data.gov.in API
class MandiPrice {
  final String state;
  final String district;
  final String market;
  final String commodity;
  final String variety;
  final String grade;
  final double minPrice;
  final double maxPrice;
  final double modalPrice;
  final DateTime arrivalDate;

  const MandiPrice({
    required this.state,
    required this.district,
    required this.market,
    required this.commodity,
    required this.variety,
    required this.grade,
    required this.minPrice,
    required this.maxPrice,
    required this.modalPrice,
    required this.arrivalDate,
  });

  factory MandiPrice.fromJson(Map<String, dynamic> json) {
    return MandiPrice(
      state: json['state'] ?? '',
      district: json['district'] ?? '',
      market: json['market'] ?? '',
      commodity: json['commodity'] ?? '',
      variety: json['variety'] ?? '',
      grade: json['grade'] ?? '',
      minPrice: _parseDouble(json['min_price']),
      maxPrice: _parseDouble(json['max_price']),
      modalPrice: _parseDouble(json['modal_price']),
      arrivalDate: _parseDate(json['arrival_date']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) {
      // Format: "dd/mm/yyyy" or "yyyy-mm-dd"
      try {
        if (value.contains('/')) {
          final parts = value.split('/');
          return DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        } else {
          return DateTime.parse(value);
        }
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }
}

/// Agro advisory bulletin
class AgroAdvisory {
  final String id;
  final String title;
  final String content;
  final String source; // KVK name, ICAR, etc.
  final String category; // crop, pest, weather, general
  final DateTime publishedDate;
  final String? imageUrl;
  final String? district;
  final String? state;

  const AgroAdvisory({
    required this.id,
    required this.title,
    required this.content,
    required this.source,
    required this.category,
    required this.publishedDate,
    this.imageUrl,
    this.district,
    this.state,
  });
}

/// Dealer information
class DealerInfo {
  final String id;
  final String name;
  final String type; // seeds, fertilizers, pesticides, machinery
  final String address;
  final String district;
  final String state;
  final String? phone;
  final String? email;
  final double? latitude;
  final double? longitude;
  final bool isVerified;

  const DealerInfo({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    required this.district,
    required this.state,
    this.phone,
    this.email,
    this.latitude,
    this.longitude,
    this.isVerified = false,
  });
}

/// Cold storage / Warehouse info
class StorageFacility {
  final String id;
  final String name;
  final String type; // cold_storage, warehouse, godown
  final String address;
  final String district;
  final String state;
  final double capacityMT; // Metric tons
  final String? phone;
  final String? ownerName;
  final double? latitude;
  final double? longitude;

  const StorageFacility({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    required this.district,
    required this.state,
    required this.capacityMT,
    this.phone,
    this.ownerName,
    this.latitude,
    this.longitude,
  });
}

/// PMFBY Insurance calculation result
class InsuranceCalculation {
  final String cropName;
  final String season; // Kharif, Rabi, Commercial
  final double sumInsured;
  final double premiumRate; // percentage
  final double farmerPremium;
  final double govtSubsidy;

  const InsuranceCalculation({
    required this.cropName,
    required this.season,
    required this.sumInsured,
    required this.premiumRate,
    required this.farmerPremium,
    required this.govtSubsidy,
  });
}

/// Service category for hub display
class ServiceCategory {
  final String id;
  final String title;
  final String titleHindi;
  final String icon;
  final String route;
  final String description;
  final int color; // Color value

  const ServiceCategory({
    required this.id,
    required this.title,
    this.titleHindi = '',
    required this.icon,
    required this.route,
    required this.description,
    required this.color,
  });
}
