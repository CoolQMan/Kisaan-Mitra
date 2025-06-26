# 🌱 Kisaan Mitra - Farmer's Companion App

> **Note:** This is a prototype application developed for AI4Humanity. It demonstrates the concept and functionality but is not a finished production-ready project.

Kisaan Mitra (Farmer's Friend) is a comprehensive mobile application designed to empower farmers with technology-driven solutions for better crop management, knowledge sharing, and market access.

## 📱 Features

### 🌿 Crop Health Analysis
- Upload or take photos of your crops
- AI-powered analysis to identify crop health issues
- Receive detailed recommendations and preventive measures
- Support for various crop types (Rice, Wheat, Cotton, etc.)

### 💧 Smart Irrigation Management
- Monitor soil moisture levels
- Receive irrigation scheduling recommendations
- Weather-based irrigation guidance
- Conservation of water resources

### ❓ Q&A Knowledge Sharing Platform
- Ask farming-related questions to the community
- Answer questions from other farmers
- Browse through existing questions and answers
- Share agricultural knowledge and experiences

### 🛒 Farmer's Marketplace
- List your crops for sale
- Browse available crop listings
- Access real-time market prices
- Connect directly with buyers/sellers
- Save favorite listings

### 👤 User Profile Management
- Personalized dashboard
- Notification center
- Settings customization
- Track your activities

## 📸 Screenshots

| Home Screen | Crop Analysis | Analysis Results |
|:-----------:|:-------------:|:----------------:|
| [Coming Soon] | [Coming Soon] | [Coming Soon] |

| Q&A Section | Marketplace | User Profile |
|:-----------:|:-----------:|:------------:|
| [Coming Soon] | [Coming Soon] | [Coming Soon] |

## 🛠️ Technologies Used

- **Flutter**: Cross-platform UI framework
- **Dart**: Programming language
- **Google Generative AI**: For crop health analysis
- Various Flutter packages including:
  - image_picker: For capturing and selecting images
  - location: For location-based services
  - shared_preferences: For local data storage
  - fl_chart: For data visualization
  - intl & timeago: For date/time formatting

## ⚙️ Setup Instructions

### Prerequisites
- Flutter SDK (^3.6.2)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- Android SDK (for Android development)
- Xcode (for iOS development, macOS only)
- Git

### Installation Steps

1. **Clone the repository**
   ```
   git clone <repository-url>
   cd kisaan_mitra
   ```

2. **Install dependencies**
   ```
   flutter pub get
   ```

3. **Configure API Keys**
   - **Google Generative AI API Key**:
     - Create an account at Google AI Studio
     - Get your API key
     - Configure it in the ai_service.dart file under services folder.
   
   - **Weather API Key**:
     - Sign up for a weather service API
     - Get your API key
     - Configure it in the weather_service.dart file under services folder.

4. **Run the app**
   ```
   flutter run
   ```

5. **Build for production**
   ```
   # For Android
   flutter build apk --release
   
   # For iOS (Not tested on iOS but you can try)
   flutter build ios --release 
   ```

## 📋 Project Structure

```
lib/
  ├── config/           # App configuration, routes, themes
  ├── models/           # Data models
  ├── screens/          # UI screens
  │   ├── auth/         # Authentication screens
  │   ├── crop_analysis/# Crop health analysis
  │   ├── marketplace/  # Marketplace functionality
  │   ├── qa_section/   # Q&A section
  │   └── ...
  ├── services/         # Business logic and API services
  ├── utils/            # Utility functions and helpers
  ├── widgets/          # Reusable UI components
  └── main.dart         # App entry point
```

## 🤝 Contributing

Contributions to improve Kisaan Mitra are welcome. Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the [insert license type] - see the LICENSE file for details.

## 🙏 Acknowledgements

- AI4Humanity for supporting this prototype
- All contributors who have helped shape this project
- Farming communities for their valuable feedback and insights
