class CropListingModel {
  final String id;
  final String userId;
  final String userName;
  final String cropType;
  final double quantity;
  final String quantityUnit;
  final double price;
  final String location;
  final DateTime harvestDate;
  final DateTime listedDate;
  final String description;
  final List<String> images;
  final bool isAvailable;

  CropListingModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.cropType,
    required this.quantity,
    required this.quantityUnit,
    required this.price,
    required this.location,
    required this.harvestDate,
    required this.listedDate,
    required this.description,
    required this.images,
    required this.isAvailable,
  });

  factory CropListingModel.fromJson(Map<String, dynamic> json) {
    return CropListingModel(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      cropType: json['cropType'],
      quantity: json['quantity'],
      quantityUnit: json['quantityUnit'],
      price: json['price'],
      location: json['location'],
      harvestDate: DateTime.parse(json['harvestDate']),
      listedDate: DateTime.parse(json['listedDate']),
      description: json['description'],
      images: List<String>.from(json['images']),
      isAvailable: json['isAvailable'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'cropType': cropType,
      'quantity': quantity,
      'quantityUnit': quantityUnit,
      'price': price,
      'location': location,
      'harvestDate': harvestDate.toIso8601String(),
      'listedDate': listedDate.toIso8601String(),
      'description': description,
      'images': images,
      'isAvailable': isAvailable,
    };
  }
}

class MarketPriceModel {
  final String cropType;
  final String location;
  final double minPrice;
  final double maxPrice;
  final double avgPrice;
  final DateTime updatedAt;

  MarketPriceModel({
    required this.cropType,
    required this.location,
    required this.minPrice,
    required this.maxPrice,
    required this.avgPrice,
    required this.updatedAt,
  });

  factory MarketPriceModel.fromJson(Map<String, dynamic> json) {
    return MarketPriceModel(
      cropType: json['cropType'],
      location: json['location'],
      minPrice: json['minPrice'],
      maxPrice: json['maxPrice'],
      avgPrice: json['avgPrice'],
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cropType': cropType,
      'location': location,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'avgPrice': avgPrice,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
