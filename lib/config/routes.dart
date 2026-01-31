import 'package:flutter/material.dart';
import 'package:kisaan_mitra/screens/auth/login_screen.dart';
import 'package:kisaan_mitra/screens/auth/register_screen.dart';
import 'package:kisaan_mitra/screens/home_screen.dart';
import 'package:kisaan_mitra/screens/crop_analysis/crop_analysis_screen.dart';
import 'package:kisaan_mitra/screens/smart_irrigation/smart_irrigation_screen.dart';
import 'package:kisaan_mitra/screens/govt_services/govt_services_hub_screen.dart';
import 'package:kisaan_mitra/screens/marketplace/marketplace_hub_screen.dart';
import 'package:kisaan_mitra/screens/profile/profile_screen.dart';

import '../models/crop_analysis_model.dart';
import '../models/marketplace_model.dart';
import '../models/question_model.dart';
import '../screens/crop_analysis/analysis_result_screen.dart';
import '../screens/marketplace/crop_listings_screen.dart';
import '../screens/marketplace/edit_listing_screen.dart';
import '../screens/marketplace/market_prices_screen.dart';
import '../screens/marketplace/saved_listing_screen.dart';
import '../screens/marketplace/sell_crop_screen.dart';
import '../screens/marketplace/product_catalog_screen.dart';
import '../screens/marketplace/cart_screen.dart';
import '../screens/marketplace/price_comparison_screen.dart';
import '../screens/marketplace/recommendations_screen.dart';
import '../screens/profile/notificaitons.dart';
import '../screens/profile/settings_screen.dart';
import '../screens/qa_section/ask_question_screen.dart';
import '../screens/qa_section/question_detail_screen.dart';
import '../screens/splash_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String cropAnalysis = '/crop-analysis';
  static const String smartIrrigation = '/smart-irrigation';
  static const String govtServices = '/govt-services';
  static const String marketplace = '/marketplace';
  static const String profile = '/profile';
  static const String analysisResult = '/analysis-result';
  static const String notifications = '/notifications';
  static const String setting = '/settings';
  static const String askQuestion = '/ask-question';
  static const String questionDetail = '/question-detail';
  static const String cropListings = '/crop-listings';
  static const String sellCrop = '/sell-crop';
  static const String savedListings = '/saved-listings';
  static const String marketPrices = '/market-prices';
  static const String editListing = '/edit-listing';
  // New marketplace routes
  static const String productCatalog = '/product-catalog';
  static const String cart = '/cart';
  static const String priceComparison = '/price-comparison';
  static const String recommendations = '/recommendations';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case cropAnalysis:
        return MaterialPageRoute(builder: (_) => const CropAnalysisScreen());
      case setting:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case smartIrrigation:
        return MaterialPageRoute(builder: (_) => const SmartIrrigationScreen());
      case govtServices:
        return MaterialPageRoute(builder: (_) => const GovtServicesHubScreen());
      case askQuestion:
        return MaterialPageRoute(builder: (_) => const AskQuestionScreen());
      case questionDetail:
        final args = settings.arguments as QuestionModel;
        return MaterialPageRoute(
          builder: (_) => QuestionDetailScreen(question: args),
        );
      case marketplace:
        return MaterialPageRoute(builder: (_) => const MarketplaceHubScreen());
      case sellCrop:
        return MaterialPageRoute(builder: (_) => const SellCropScreen());
      case cropListings:
        final args = settings.arguments as CropListingModel;
        return MaterialPageRoute(
          builder: (_) => CropListingsScreen(listing: args),
        );
      case savedListings:
        return MaterialPageRoute(builder: (_) => const SavedListingsScreen());
      case marketPrices:
        return MaterialPageRoute(builder: (_) => const MarketPricesScreen());
      case editListing:
        final args = settings.arguments as CropListingModel;
        return MaterialPageRoute(
            builder: (_) => EditListingScreen(listing: args));
      case productCatalog:
        return MaterialPageRoute(builder: (_) => const ProductCatalogScreen());
      case cart:
        return MaterialPageRoute(builder: (_) => const CartScreen());
      case priceComparison:
        return MaterialPageRoute(builder: (_) => const PriceComparisonScreen());
      case recommendations:
        return MaterialPageRoute(builder: (_) => const RecommendationsScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationScreen());
      case analysisResult:
        final args = settings.arguments as CropAnalysisModel;
        return MaterialPageRoute(
          builder: (_) => AnalysisResultScreen(result: args),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
