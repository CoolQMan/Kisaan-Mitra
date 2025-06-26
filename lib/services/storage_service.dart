import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/marketplace_model.dart';
import '../models/question_model.dart';

class StorageService {
  // Singleton pattern
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  static const String myListingsKey = 'my_listings';
  static const String savedListingsKey = 'saved_listings';

  // In-memory storage for questions
  final List<QuestionModel> _questions = [];

  // Get all questions
  List<QuestionModel> getAllQuestions() {
    return List.from(_questions);
  }

  // Add a new question (at the beginning of the list)
  void addQuestion(QuestionModel question) {
    _questions.insert(0, question); // Insert at the beginning
  }

  // Get user questions
  List<QuestionModel> getUserQuestions(String userId) {
    return _questions.where((q) => q.userId == userId).toList();
  }

  //Listings
  Future<void> addToMyListings(CropListingModel listing) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> myListingsJson = prefs.getStringList(myListingsKey) ?? [];

    // Check if listing already exists
    bool exists = myListingsJson.any((item) {
      final decoded = jsonDecode(item);
      return decoded['id'] == listing.id;
    });

    if (!exists) {
      myListingsJson.add(jsonEncode(listing.toJson()));
      await prefs.setStringList(myListingsKey, myListingsJson);
    }
  }

  Future<void> addToSavedListings(CropListingModel listing) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedListingsJson =
        prefs.getStringList(savedListingsKey) ?? [];

    // Check if listing already exists
    bool exists = savedListingsJson.any((item) {
      final decoded = jsonDecode(item);
      return decoded['id'] == listing.id;
    });

    if (!exists) {
      savedListingsJson.add(jsonEncode(listing.toJson()));
      await prefs.setStringList(savedListingsKey, savedListingsJson);
    }
  }

  Future<List<CropListingModel>> getMyListings() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> myListingsJson = prefs.getStringList(myListingsKey) ?? [];

    return myListingsJson.map((item) {
      return CropListingModel.fromJson(jsonDecode(item));
    }).toList();
  }

  // Get all Saved Listings
  Future<List<CropListingModel>> getSavedListings() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedListingsJson =
        prefs.getStringList(savedListingsKey) ?? [];

    return savedListingsJson.map((item) {
      return CropListingModel.fromJson(jsonDecode(item));
    }).toList();
  }

  // Remove from My Listings
  Future<void> removeFromMyListings(String listingId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> myListingsJson = prefs.getStringList(myListingsKey) ?? [];

    myListingsJson.removeWhere((item) {
      final decoded = jsonDecode(item);
      return decoded['id'] == listingId;
    });

    await prefs.setStringList(myListingsKey, myListingsJson);
  }

  Future<void> removeFromSavedListings(String listingId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedListingsJson =
        prefs.getStringList(savedListingsKey) ?? [];

    savedListingsJson.removeWhere((item) {
      final decoded = jsonDecode(item);
      return decoded['id'] == listingId;
    });

    await prefs.setStringList(savedListingsKey, savedListingsJson);
  }

  //Update Listing
  Future<void> updateMyListing(CropListingModel updatedListing) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> myListingsJson = prefs.getStringList(myListingsKey) ?? [];

    // Find and replace the listing
    for (int i = 0; i < myListingsJson.length; i++) {
      final decoded = jsonDecode(myListingsJson[i]);
      if (decoded['id'] == updatedListing.id) {
        myListingsJson[i] = jsonEncode(updatedListing.toJson());
        break;
      }
    }

    // Save the updated list
    await prefs.setStringList(myListingsKey, myListingsJson);
  }
}
