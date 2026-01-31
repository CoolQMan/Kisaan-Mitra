import 'package:flutter/material.dart';

/// Global localization service using map-based approach
/// Supports English (en) and Hindi (hi)
class AppLocalization extends ChangeNotifier {
  // Singleton pattern
  static final AppLocalization _instance = AppLocalization._internal();
  factory AppLocalization() => _instance;
  AppLocalization._internal();

  String _locale = 'hi'; // Default to Hindi
  String get locale => _locale;
  bool get isHindi => _locale == 'hi';

  void toggleLanguage() {
    _locale = _locale == 'en' ? 'hi' : 'en';
    notifyListeners();
  }

  void setLanguage(String lang) {
    _locale = lang;
    notifyListeners();
  }

  // ============ COMMON ============
  String get appName => _t('Kisaan Mitra', 'किसान मित्र');
  String get home => _t('Home', 'होम');
  String get notifications => _t('Notifications', 'सूचनाएं');
  String get profile => _t('Profile', 'प्रोफ़ाइल');
  String get settings => _t('Settings', 'सेटिंग्स');
  String get ok => _t('OK', 'ठीक है');
  String get cancel => _t('Cancel', 'रद्द करें');
  String get save => _t('Save', 'सहेजें');
  String get submit => _t('Submit', 'जमा करें');
  String get loading => _t('Loading...', 'लोड हो रहा है...');
  String get error => _t('Error', 'त्रुटि');
  String get success => _t('Success', 'सफल');
  String get retry => _t('Retry', 'पुनः प्रयास करें');
  String get close => _t('Close', 'बंद करें');
  String get back => _t('Back', 'वापस');
  String get next => _t('Next', 'आगे');
  String get search => _t('Search', 'खोजें');
  String get filter => _t('Filter', 'फ़िल्टर');
  String get all => _t('All', 'सभी');
  String get details => _t('Details', 'विवरण');
  String get apply => _t('Apply', 'आवेदन करें');
  String get comingSoon => _t('Coming Soon!', 'जल्द आ रहा है!');

  // ============ HOME SCREEN ============
  String get welcome => _t('Welcome', 'स्वागत है');
  String welcomeUser(String name) => _t('Welcome, $name!', 'स्वागत है, $name!');
  String get todayWeather => _t("Today's Weather", 'आज का मौसम');
  String get cropAnalysis => _t('Crop Analysis', 'फसल विश्लेषण');
  String get cropAnalysisDesc =>
      _t('AI-powered disease detection', 'AI संचालित रोग पहचान');
  String get smartIrrigation => _t('Smart Irrigation', 'स्मार्ट सिंचाई');
  String get smartIrrigationDesc =>
      _t('Weather-based recommendations', 'मौसम आधारित सुझाव');
  String get marketplace => _t('Marketplace', 'बाज़ार');
  String get marketplaceDesc =>
      _t('Buy & sell agricultural products', 'कृषि उत्पाद खरीदें और बेचें');
  String get sarkariSeva => _t('Sarkari Seva', 'सरकारी सेवा');
  String get sarkariSevaDesc =>
      _t('Government schemes & services', 'सरकारी योजनाएं और सेवाएं');

  // ============ GOVT SERVICES HUB ============
  String get govtServices => _t('Government Services', 'सरकारी सेवाएं');
  String get services => _t('Services', 'सेवाएं');
  String get quickActions => _t('Quick Actions', 'त्वरित कार्रवाइयां');
  String get announcements => _t('Announcements', 'घोषणाएं');
  String get kisanHelpline => _t('Kisan Helpline', 'किसान हेल्पलाइन');
  String get pmKisanStatus => _t('PM-KISAN Status', 'पीएम-किसान स्थिति');
  String get checkPaymentStatus =>
      _t('Check your payment status', 'अपनी भुगतान स्थिति जांचें');
  String get checkStatus => _t('Check Status', 'स्थिति जांचें');
  String get newRegister => _t('New Register', 'नया पंजीकरण');
  String get callKisanHelpline =>
      _t('Call Kisan Helpline', 'किसान हेल्पलाइन पर कॉल करें');
  String get soilHealthCard => _t('Soil Health Card', 'मृदा स्वास्थ्य कार्ड');
  String get eNamMarket => _t('e-NAM Market', 'ई-नाम बाज़ार');
  String get pmKisanPortal => _t('PM-KISAN Portal', 'पीएम-किसान पोर्टल');
  String get schemes => _t('Schemes', 'योजनाएं');
  String get schemesDesc => _t('Govt. Programs', 'सरकारी कार्यक्रम');
  String get insurance => _t('Insurance', 'बीमा');
  String get insuranceDesc => _t('Crop Protection', 'फसल सुरक्षा');
  String get mandiPrices => _t('Mandi Prices', 'मंडी भाव');
  String get mandiPricesDesc => _t('Live Rates', 'लाइव भाव');
  String get advisory => _t('Advisory', 'सलाह');
  String get advisoryDesc => _t('Expert Tips', 'विशेषज्ञ सुझाव');
  String get dealers => _t('Dealers', 'विक्रेता');
  String get dealersDesc => _t('Find Nearby', 'नज़दीकी खोजें');
  String get helpline => _t('Helpline', 'हेल्पलाइन');
  String get helplineDesc => _t('24/7 Support', '24/7 सहायता');

  // ============ SCHEME FINDER ============
  String get govtSchemes => _t('Government Schemes', 'सरकारी योजनाएं');
  String get allSchemes => _t('All Schemes', 'सभी योजनाएं');
  String get subsidies => _t('Subsidies', 'सब्सिडी');
  String get creditLoans => _t('Credit/Loans', 'ऋण/क़र्ज़');
  String get market => _t('Market', 'बाज़ार');
  String get eligibility => _t('Eligibility', 'पात्रता');
  String get benefits => _t('Benefits', 'लाभ');
  String get howToApply => _t('How to Apply', 'आवेदन कैसे करें');
  String get visitOfficialWebsite =>
      _t('Visit Official Website', 'आधिकारिक वेबसाइट पर जाएं');
  String get deadline => _t('Deadline', 'अंतिम तिथि');
  String get description => _t('Description', 'विवरण');

  // ============ MANDI PRICES ============
  String get selectState => _t('Select State', 'राज्य चुनें');
  String get selectCommodity => _t('Select Commodity', 'वस्तु चुनें');
  String get searchPrices => _t('Search Prices', 'भाव खोजें');
  String get bestPrice => _t('Best Price', 'सर्वोत्तम भाव');
  String get minPrice => _t('Min', 'न्यूनतम');
  String get maxPrice => _t('Max', 'अधिकतम');
  String get modalPrice => _t('Modal', 'मोडल');
  String get noDataFound => _t('No data found', 'कोई डेटा नहीं मिला');
  String get realTimeMandiPrices =>
      _t('Real-time Mandi Prices', 'रियल-टाइम मंडी भाव');
  String get dataFromGovt => _t('Data from data.gov.in', 'data.gov.in से डेटा');

  // ============ INSURANCE CALCULATOR ============
  String get cropInsuranceCalc =>
      _t('Crop Insurance Calculator', 'फसल बीमा कैलकुलेटर');
  String get pmfby => _t('PMFBY', 'पीएमएफबीवाई');
  String get pmfbyFull =>
      _t('Pradhan Mantri Fasal Bima Yojana', 'प्रधानमंत्री फसल बीमा योजना');
  String get calculatePremium =>
      _t('Calculate Your Premium', 'अपना प्रीमियम गणना करें');
  String get season => _t('Season', 'मौसम');
  String get kharif => _t('Kharif', 'खरीफ');
  String get rabi => _t('Rabi', 'रबी');
  String get commercial => _t('Commercial', 'व्यावसायिक');
  String get crop => _t('Crop', 'फसल');
  String get sumInsured => _t('Sum Insured', 'बीमित राशि');
  String get calculate => _t('Calculate', 'गणना करें');
  String get yourPremium => _t('Your Premium', 'आपका प्रीमियम');
  String get premiumRate => _t('Premium Rate', 'प्रीमियम दर');
  String get farmerPremium => _t('Farmer Premium', 'किसान प्रीमियम');
  String get applyOnPmfby =>
      _t('Apply on PMFBY Portal', 'पीएमएफबीवाई पोर्टल पर आवेदन करें');
  String get premiumRatesInfo =>
      _t('Premium Rates (Farmer Share)', 'प्रीमियम दर (किसान हिस्सा)');

  // ============ ADVISORY ============
  String get agroAdvisory => _t('Agro Advisory', 'कृषि सलाह');
  String get cropAdvisory => _t('Crop', 'फसल');
  String get pestAdvisory => _t('Pest', 'कीट');
  String get weatherAdvisory => _t('Weather', 'मौसम');

  // ============ HELPLINE ============
  String get kisanCallCenter => _t('Kisan Call Center', 'किसान कॉल सेंटर');
  String get tollFreeHelpline =>
      _t('24/7 Toll-Free Helpline', '24/7 टोल-फ्री हेल्पलाइन');
  String get callNow => _t('Call Now', 'अभी कॉल करें');
  String get availableIn22Languages =>
      _t('Available in 22 local languages', '22 स्थानीय भाषाओं में उपलब्ध');
  String get allHelplines => _t('All Helplines', 'सभी हेल्पलाइन');
  String get faq =>
      _t('Frequently Asked Questions', 'अक्सर पूछे जाने वाले प्रश्न');
  String get usefulLinks => _t('Useful Links', 'उपयोगी लिंक');

  // ============ SMART IRRIGATION ============
  String get currentWeather => _t('Current Weather', 'वर्तमान मौसम');
  String get weatherForecast => _t('Weather Forecast', 'मौसम पूर्वानुमान');
  String get irrigationAdvice => _t('Irrigation Advice', 'सिंचाई सलाह');
  String get soilMoisture => _t('Soil Moisture', 'मिट्टी की नमी');
  String get temperature => _t('Temperature', 'तापमान');
  String get humidity => _t('Humidity', 'आर्द्रता');
  String get rainfall => _t('Rainfall', 'वर्षा');
  String get windSpeed => _t('Wind Speed', 'हवा की गति');
  String get iotDashboard => _t('IoT Dashboard', 'आईओटी डैशबोर्ड');
  String get irrigationControl => _t('Irrigation Control', 'सिंचाई नियंत्रण');
  String get weatherAlerts => _t('Weather Alerts', 'मौसम अलर्ट');

  // ============ CROP ANALYSIS ============
  String get takePicture => _t('Take Picture', 'फोटो लें');
  String get selectFromGallery => _t('Select from Gallery', 'गैलरी से चुनें');
  String get analyzing => _t('Analyzing...', 'विश्लेषण हो रहा है...');
  String get analysisResult => _t('Analysis Result', 'विश्लेषण परिणाम');
  String get diseaseDetected => _t('Disease Detected', 'रोग पता चला');
  String get healthyCrop => _t('Healthy Crop', 'स्वस्थ फसल');
  String get recommendations => _t('Recommendations', 'सुझाव');
  String get confidence => _t('Confidence', 'विश्वसनीयता');

  // ============ MARKETPLACE ============
  String get buyNow => _t('Buy Now', 'अभी खरीदें');
  String get sellCrop => _t('Sell Crop', 'फसल बेचें');
  String get addToCart => _t('Add to Cart', 'कार्ट में डालें');
  String get cart => _t('Cart', 'कार्ट');
  String get myListings => _t('My Listings', 'मेरी लिस्टिंग');
  String get productCatalog => _t('Product Catalog', 'उत्पाद सूची');
  String get priceComparison => _t('Price Comparison', 'मूल्य तुलना');
  String get quantity => _t('Quantity', 'मात्रा');
  String get price => _t('Price', 'मूल्य');
  String get perQuintal => _t('per quintal', 'प्रति क्विंटल');
  String get perKg => _t('per kg', 'प्रति किलो');
  String get available => _t('Available', 'उपलब्ध');
  String get soldOut => _t('Sold Out', 'बिक चुका');

  // ============ AUTH ============
  String get login => _t('Login', 'लॉगिन');
  String get register => _t('Register', 'पंजीकरण');
  String get email => _t('Email', 'ईमेल');
  String get password => _t('Password', 'पासवर्ड');
  String get confirmPassword =>
      _t('Confirm Password', 'पासवर्ड की पुष्टि करें');
  String get forgotPassword => _t('Forgot Password?', 'पासवर्ड भूल गए?');
  String get dontHaveAccount => _t("Don't have an account?", 'खाता नहीं है?');
  String get alreadyHaveAccount =>
      _t('Already have an account?', 'पहले से खाता है?');
  String get signUp => _t('Sign Up', 'साइन अप');
  String get phoneNumber => _t('Phone Number', 'फ़ोन नंबर');
  String get name => _t('Name', 'नाम');
  String get logout => _t('Logout', 'लॉगआउट');

  // ============ PROFILE ============
  String get editProfile => _t('Edit Profile', 'प्रोफ़ाइल संपादित करें');
  String get farmerDetails => _t('Farmer Details', 'किसान विवरण');
  String get landDetails => _t('Land Details', 'भूमि विवरण');
  String get cropDetails => _t('Crop Details', 'फसल विवरण');
  String get location => _t('Location', 'स्थान');
  String get language => _t('Language', 'भाषा');
  String get english => _t('English', 'अंग्रेज़ी');
  String get hindi => _t('Hindi', 'हिंदी');

  // ============ WEATHER ============
  String get sunny => _t('Sunny', 'धूप');
  String get cloudy => _t('Cloudy', 'बादल');
  String get rainy => _t('Rainy', 'बारिश');
  String get clear => _t('Clear', 'साफ');
  String get partlyCloudy => _t('Partly Cloudy', 'आंशिक बादल');

  // ============ CROPS ============
  String get rice => _t('Rice', 'चावल');
  String get wheat => _t('Wheat', 'गेहूं');
  String get maize => _t('Maize', 'मक्का');
  String get cotton => _t('Cotton', 'कपास');
  String get sugarcane => _t('Sugarcane', 'गन्ना');
  String get potato => _t('Potato', 'आलू');
  String get tomato => _t('Tomato', 'टमाटर');
  String get onion => _t('Onion', 'प्याज');
  String get soybean => _t('Soybean', 'सोयाबीन');
  String get groundnut => _t('Groundnut', 'मूंगफली');

  // ============ STATES ============
  String get maharashtra => _t('Maharashtra', 'महाराष्ट्र');
  String get madhyaPradesh => _t('Madhya Pradesh', 'मध्य प्रदेश');
  String get uttarPradesh => _t('Uttar Pradesh', 'उत्तर प्रदेश');
  String get rajasthan => _t('Rajasthan', 'राजस्थान');
  String get punjab => _t('Punjab', 'पंजाब');
  String get haryana => _t('Haryana', 'हरियाणा');
  String get gujarat => _t('Gujarat', 'गुजरात');
  String get karnataka => _t('Karnataka', 'कर्नाटक');
  String get tamilNadu => _t('Tamil Nadu', 'तमिलनाडु');
  String get andhraPradesh => _t('Andhra Pradesh', 'आंध्र प्रदेश');
  String get bihar => _t('Bihar', 'बिहार');
  String get westBengal => _t('West Bengal', 'पश्चिम बंगाल');

  // ============ CROP ANALYSIS - EXTENDED ============
  String get analyzeCrop => _t('Analyze Crop', 'फसल का विश्लेषण करें');
  String get detectingDiseases =>
      _t('Detecting diseases...', 'रोग पहचान हो रही है...');
  String get cropTypeOptional =>
      _t('Crop Type (Optional)', 'फसल का प्रकार (वैकल्पिक)');
  String get cropTypeHint =>
      _t('e.g., Rice, Wheat, Cotton, Tomato', 'जैसे- चावल, गेहूं, कपास, टमाटर');
  String get helpsImproveAccuracy => _t('Helps improve detection accuracy',
      'पहचान सटीकता बढ़ाने में मदद करता है');
  String get tipsForBetterAnalysis =>
      _t('Tips for better analysis:', 'बेहतर विश्लेषण के लिए सुझाव:');
  String get tipGoodLighting => _t('Ensure good lighting when taking photos',
      'फोटो लेते समय अच्छी रोशनी रखें');
  String get tipFocusAffected => _t('Focus on the affected area of the plant',
      'पौधे के प्रभावित हिस्से पर फोकस करें');
  String get tipIncludeBoth => _t('Include both healthy and unhealthy parts',
      'स्वस्थ और अस्वस्थ दोनों भागों को शामिल करें');
  String get tipCloseUp => _t('Take close-up shots of visible symptoms',
      'दिखाई देने वाले लक्षणों की नज़दीकी फोटो लें');
  String get pleaseSelectImage =>
      _t('Please select an image first', 'कृपया पहले एक फोटो चुनें');
  String get locationAccess => _t('Location Access', 'स्थान पहुंच');
  String get skipForNow => _t('Skip for now', 'अभी छोड़ें');
  String get enableLocation => _t('Enable Location', 'स्थान सक्षम करें');
  String get locationHelpsIdentify => _t(
      'Location helps identify region-specific diseases more accurately.',
      'स्थान क्षेत्र-विशिष्ट रोगों को अधिक सटीक रूप से पहचानने में मदद करता है।');

  // ============ SMART IRRIGATION - EXTENDED ============
  String get weatherTab => _t('Weather', 'मौसम');
  String get iotSensors => _t('IoT Sensors', 'आईओटी सेंसर');
  String get controlTab => _t('Control', 'नियंत्रण');
  String get analyticsTab => _t('Analytics', 'विश्लेषण');
  String get fiveDayForecast => _t('5-Day Forecast', '5-दिन का पूर्वानुमान');
  String get irrigationRecommendations =>
      _t('Irrigation Recommendations', 'सिंचाई सुझाव');
  String get enterCropType => _t('Enter Crop Type', 'फसल का प्रकार दर्ज करें');
  String get cropTypeHintShort =>
      _t('e.g., Rice, Wheat, Cotton', 'जैसे- चावल, गेहूं, कपास');
  String get getAdvice => _t('Get Advice', 'सलाह लें');
  String get waterNow => _t('Water Now', 'अभी पानी दें');
  String get skipWatering => _t('Skip Watering', 'पानी न दें');
  String get waterUsage => _t('Water Usage', 'पानी का उपयोग');
  String get litersPerDay => _t('Liters/Day', 'लीटर/दिन');
  String get savingsThisMonth => _t('Savings This Month', 'इस महीने की बचत');
  String get premiumFeature => _t('Premium Feature', 'प्रीमियम फीचर');
  String get upgradeToAccess => _t('Upgrade to access IoT sensor dashboard',
      'आईओटी सेंसर डैशबोर्ड तक पहुंचने के लिए अपग्रेड करें');
  String get upgrade => _t('Upgrade', 'अपग्रेड करें');
  String get errorLoadingWeather =>
      _t('Error loading weather data', 'मौसम डेटा लोड करने में त्रुटि');

  // ============ MARKETPLACE - EXTENDED ============
  String get shop => _t('Shop', 'दुकान');
  String get buyFarmInputs => _t('Buy farm inputs', 'कृषि सामग्री खरीदें');
  String get sellCrops => _t('Sell Crops', 'फसल बेचें');
  String get listYourProduce => _t('List your produce', 'अपनी उपज लिस्ट करें');
  String get prices => _t('Prices', 'भाव');
  String get mspVsMarket => _t('MSP vs Market', 'एमएसपी बनाम बाज़ार');
  String get aiInsights => _t('AI Insights', 'एआई अंतर्दृष्टि');
  String get trendingUp => _t('Trending Up', 'बढ़ती कीमतें');
  String get featuredProducts => _t('Featured Products', 'विशेष उत्पाद');
  String get seeAll => _t('See All', 'सभी देखें');
  String get moreActions => _t('More Actions', 'और विकल्प');
  String get manageYourListings =>
      _t('Manage your crop listings', 'अपनी फसल लिस्टिंग प्रबंधित करें');
  String get viewAllMandiPrices =>
      _t('View all mandi prices', 'सभी मंडी भाव देखें');
  String get marketPrices => _t('Market Prices', 'बाज़ार भाव');
  String get overstockAlert => _t('Overstock Alert', 'अधिक स्टॉक अलर्ट');
  String get addProduct => _t('Add Product', 'उत्पाद जोड़ें');
  String get checkout => _t('Checkout', 'चेकआउट');
  String get orderPlaced => _t('Order Placed', 'ऑर्डर हो गया');
  String get orderHistory => _t('Order History', 'ऑर्डर इतिहास');
  String get seeds => _t('Seeds', 'बीज');
  String get fertilizers => _t('Fertilizers', 'उर्वरक');
  String get pesticides => _t('Pesticides', 'कीटनाशक');
  String get equipment => _t('Equipment', 'उपकरण');
  String get organicProducts => _t('Organic Products', 'जैविक उत्पाद');

  // Helper method
  String _t(String en, String hi) => _locale == 'hi' ? hi : en;
}

/// Global instance for easy access
final AppLocalization loc = AppLocalization();
