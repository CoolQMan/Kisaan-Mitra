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
- Monitor soil moisture levels based on weather in the area
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

<table>
  <tr>
    <td align="center"><img src="https://github.com/user-attachments/assets/ad2ad3c0-218a-4435-a117-b472fa9bb005" alt="Home Screen" width="200"/><br><small>Home Screen</small></td>
    <td align="center"><img src="https://github.com/user-attachments/assets/d76cff67-a9b9-4ded-ab51-f1d90107aa55" alt="Crop Analysis" width="200"/><br><small>Crop Analysis</small></td>
    <td align="center"><img src="https://github.com/user-attachments/assets/eec24d48-d76f-4e26-8d42-c0ecddc71eab" alt="Analysis Result" width="200"/><br><small>Analysis Result</small></td>
    <td align="center"><img src="https://github.com/user-attachments/assets/3a7af779-708b-4d4c-9f6b-a5a22a81b0cd" alt="Q&A Section" width="200"/><br><small>Q&A Section</small></td>
  </tr>
  <tr>
    <td align="center"><img src="https://github.com/user-attachments/assets/87cf7e85-80ac-4287-9d54-f519c9031340" alt="Marketplace" width="200"/><br><small>Marketplace</small></td>
    <td align="center"><img src="https://github.com/user-attachments/assets/eebfe5bf-c64b-49b1-a6af-df8588c4c771" alt="Smart Irrigation" width="200"/><br><small>Smart Irrigation</small></td>
    <td align="center"><img src="https://github.com/user-attachments/assets/76b37968-1909-49ac-a5de-25147a5ed8ae" alt="Irrigation Recommendation" width="200"/><br><small>Irrigation Recommendation</small></td>
    <td align="center"><img src="https://github.com/user-attachments/assets/bac0d475-bec5-4c28-9c74-0de31d59c5ca" alt="Notification" width="200"/><br><small>Notification</small></td>
  </tr>
</table>


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
   
## 🔑 Demo Account

To quickly test the application without registration, you can use this pre-configured demo account:

- **Email**: farmer@example.com
- **Password**: password123

Alternatively, you can use:
- **Email**: test@example.com
- **Password**: test123

These credentials are automatically configured in the app's authentication service for development and testing purposes.

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

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgements

- All contributors who have helped shape this project
- AI4Humanity for supporting this prototype
- Farming communities for their valuable feedback and insights
