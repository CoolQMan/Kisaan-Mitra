import 'package:kisaan_mitra/models/marketplace_model.dart';
import 'package:kisaan_mitra/services/auth_service.dart';
import 'package:uuid/uuid.dart';

class MarketplaceService {
  // Singleton pattern
  static final MarketplaceService _instance = MarketplaceService._internal();
  factory MarketplaceService() => _instance;
  MarketplaceService._internal();

  final AuthService _authService = AuthService();
  final List<CropListingModel> _listings = [];
  final List<MarketPriceModel> _marketPrices = [];

  // Get all crop listings
  List<CropListingModel> getAllListings() {
    return List.from(_listings);
  }

  // Get user's crop listings
  List<CropListingModel> getUserListings(String userId) {
    return _listings.where((listing) => listing.userId == userId).toList();
  }

  // Add a new crop listing
  Future<CropListingModel> addListing(
    String cropType,
    double quantity,
    String quantityUnit,
    double price,
    String location,
    DateTime harvestDate,
    String description,
    List<String> images,
  ) async {
    // Generate a suggested price based on market trends
    final suggestedPrice = await getSuggestedPrice(cropType, location);

    final newListing = CropListingModel(
      id: const Uuid().v4(),
      userId: _authService.currentUser?.id ?? 'unknown',
      userName: _authService.currentUser?.name ?? 'Anonymous',
      cropType: cropType,
      quantity: quantity,
      quantityUnit: quantityUnit,
      price: price,
      location: location,
      harvestDate: harvestDate,
      listedDate: DateTime.now(),
      description: description,
      images: images,
      isAvailable: true,
    );

    _listings.insert(0, newListing); // Add to the beginning of the list
    return newListing;
  }

  // Get market prices for a specific crop
  List<MarketPriceModel> getMarketPrices(String cropType) {
    return _marketPrices
        .where(
            (price) => price.cropType.toLowerCase() == cropType.toLowerCase())
        .toList();
  }

  // Get suggested price for a crop based on market trends
  Future<double> getSuggestedPrice(String cropType, String location) async {
    // In a real app, this would query a backend service for real-time market data
    // For now, we'll use mock data
    await Future.delayed(const Duration(milliseconds: 500));

    // Find matching market price data
    final matchingPrices = _marketPrices
        .where(
          (price) =>
              price.cropType.toLowerCase() == cropType.toLowerCase() &&
              price.location.toLowerCase() == location.toLowerCase(),
        )
        .toList();

    if (matchingPrices.isNotEmpty) {
      return matchingPrices.first.avgPrice;
    }

    // If no exact match, return an average price based on crop type
    final cropPrices = _marketPrices
        .where(
            (price) => price.cropType.toLowerCase() == cropType.toLowerCase())
        .toList();

    if (cropPrices.isNotEmpty) {
      return cropPrices.map((p) => p.avgPrice).reduce((a, b) => a + b) /
          cropPrices.length;
    }

    // Default fallback prices for common crops
    final defaultPrices = {
      'rice': 25.0,
      'wheat': 20.0,
      'corn': 18.0,
      'cotton': 60.0,
      'sugarcane': 3.0,
      'potato': 15.0,
      'tomato': 25.0,
    };

    return defaultPrices[cropType.toLowerCase()] ?? 30.0;
  }

  // Initialize with some mock data
  void initMockData() {
    if (_listings.isEmpty) {
      final currentUserId = _authService.currentUser?.id ?? 'unknown';

      // Add mock listings
      _listings.add(CropListingModel(
        id: '1',
        userId: 'user1',
        userName: 'Farmer Singh',
        cropType: 'Wheat',
        quantity: 500,
        quantityUnit: 'kg',
        price: 22.5,
        location: 'Punjab, India',
        harvestDate: DateTime.now().subtract(const Duration(days: 15)),
        listedDate: DateTime.now().subtract(const Duration(days: 5)),
        description: 'High-quality wheat harvested from organic farm.',
        images: ['wheat_image.jpg'],
        isAvailable: true,
      ));

      _listings.add(CropListingModel(
        id: '2',
        userId: currentUserId,
        userName: _authService.currentUser?.name ?? 'You',
        cropType: 'Rice',
        quantity: 300,
        quantityUnit: 'kg',
        price: 35.0,
        location: 'Haryana, India',
        harvestDate: DateTime.now().subtract(const Duration(days: 20)),
        listedDate: DateTime.now().subtract(const Duration(days: 3)),
        description: 'Premium basmati rice, freshly harvested.',
        images: ['rice_image.jpg'],
        isAvailable: true,
      ));

      _listings.add(CropListingModel(
        id: '3',
        userId: 'user3',
        userName: 'Anita Patel',
        cropType: 'Cotton',
        quantity: 200,
        quantityUnit: 'kg',
        price: 65.0,
        location: 'Gujarat, India',
        harvestDate: DateTime.now().subtract(const Duration(days: 30)),
        listedDate: DateTime.now().subtract(const Duration(days: 10)),
        description: 'High-quality cotton, ready for processing.',
        images: ['cotton_image.jpg'],
        isAvailable: true,
      ));
    }

    if (_marketPrices.isEmpty) {
      // Add mock market prices
      _marketPrices.add(MarketPriceModel(
        cropType: 'Wheat',
        location: 'Punjab, India',
        minPrice: 20.0,
        maxPrice: 25.0,
        avgPrice: 22.5,
        updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
      ));

      _marketPrices.add(MarketPriceModel(
        cropType: 'Wheat',
        location: 'Haryana, India',
        minPrice: 19.0,
        maxPrice: 24.0,
        avgPrice: 21.5,
        updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
      ));

      _marketPrices.add(MarketPriceModel(
        cropType: 'Rice',
        location: 'Punjab, India',
        minPrice: 30.0,
        maxPrice: 40.0,
        avgPrice: 35.0,
        updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
      ));

      _marketPrices.add(MarketPriceModel(
        cropType: 'Cotton',
        location: 'Gujarat, India',
        minPrice: 60.0,
        maxPrice: 70.0,
        avgPrice: 65.0,
        updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
      ));
    }
  }
}
