import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kisaan_mitra/models/user_model.dart';

class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Mock user data for development
  final Map<String, String> _users = {
    'farmer@example.com': 'password123',
    'test@example.com': 'test123',
  };

  // User authentication state
  bool _isAuthenticated = false;
  UserModel? _currentUser;

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  UserModel? get currentUser => _currentUser;

  // Login method
  Future<String?> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Check if user exists
    if (!_users.containsKey(email)) {
      return 'User does not exist';
    }

    // Check if password matches
    if (_users[email] != password) {
      return 'Incorrect password';
    }

    // Set authentication state
    _isAuthenticated = true;

    // Create mock user data
    _currentUser = UserModel(
      id: '1',
      name: 'Rakesh Yadav',
      email: email,
      phoneNumber: '+91 9876543210',
      location: 'Punjab, India',
      createdAt: DateTime.now(),
    );

    // Save auth state to local storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAuthenticated', true);
    await prefs.setString('userEmail', email);
    await prefs.setString('userName', 'Rakesh Yadav');
    await prefs.setString('userPhone', '+91 9876543210');

    return null; // No error means success
  }

  // Register method
  Future<String?> register(
      String name, String email, String password, String phoneNumber) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Check if user already exists
    if (_users.containsKey(email)) {
      return 'User already exists';
    }

    // Register new user
    _users[email] = password;

    // Auto login after registration
    return login(email, password);
  }

  // Logout method
  Future<void> logout() async {
    _isAuthenticated = false;
    _currentUser = null;

    // Clear auth state from local storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Check if user is already logged in
  Future<bool> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isAuthenticated = prefs.getBool('isAuthenticated') ?? false;

    if (isAuthenticated) {
      final userEmail = prefs.getString('userEmail');
      final userName = prefs.getString('userName');
      final userPhone = prefs.getString('userPhone');

      if (userEmail != null) {
        _isAuthenticated = true;
        _currentUser = UserModel(
          id: '1',
          name: userName ?? 'Rakesh Yadav',
          email: userEmail,
          phoneNumber: userPhone ?? '+91 9876543210',
          location: 'Punjab, India',
          createdAt: DateTime.now(),
        );
        return true;
      }
    }

    return false;
  }
}
