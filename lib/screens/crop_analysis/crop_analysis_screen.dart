import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kisaan_mitra/config/routes.dart';
import 'package:kisaan_mitra/services/ai_service.dart';
import 'package:kisaan_mitra/services/location_service.dart';
import 'package:kisaan_mitra/services/localization_service.dart';
import 'package:kisaan_mitra/widgets/crop_analysis/image_picker_widget.dart';
import 'package:kisaan_mitra/widgets/common/language_toggle.dart';

class CropAnalysisScreen extends StatefulWidget {
  const CropAnalysisScreen({Key? key}) : super(key: key);

  @override
  State<CropAnalysisScreen> createState() => _CropAnalysisScreenState();
}

class _CropAnalysisScreenState extends State<CropAnalysisScreen> {
  final AIService _aiService = AIService();
  final LocationService _locationService = LocationService();

  File? _selectedImage;
  bool _isAnalyzing = false;
  String? _cropType;

  // Location state
  double? _latitude;
  double? _longitude;
  bool _locationEnabled = false;
  bool _locationLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAndRequestLocation();
  }

  Future<void> _checkAndRequestLocation() async {
    setState(() {
      _locationLoading = true;
    });

    try {
      final locationData = await _locationService.getCurrentLocation();
      setState(() {
        _latitude = locationData.latitude;
        _longitude = locationData.longitude;
        _locationEnabled = true;
        _locationLoading = false;
      });
    } on LocationException catch (e) {
      setState(() {
        _locationEnabled = false;
        _locationLoading = false;
      });
      // Show dialog only if permission was denied (not on first load)
      if (e.isPermissionDenied && mounted) {
        _showLocationPrompt(e.message, isPermissionIssue: true);
      }
    } catch (e) {
      setState(() {
        _locationEnabled = false;
        _locationLoading = false;
      });
    }
  }

  void _showLocationPrompt(String message, {bool isPermissionIssue = false}) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(
              isPermissionIssue ? Icons.location_off : Icons.location_on,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 8),
            const Text('Location Access'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Location helps identify region-specific diseases more accurately.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Skip for now'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              _checkAndRequestLocation();
            },
            icon: const Icon(Icons.location_on, size: 18),
            label: const Text('Enable Location'),
          ),
        ],
      ),
    );
  }

  void _onImagePicked(File image) {
    setState(() {
      _selectedImage = image;
    });
  }

  Future<void> _analyzeCrop() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first')),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    try {
      final result = await _aiService.analyzeCropHealth(
        _selectedImage!,
        cropType: _cropType?.trim().isNotEmpty == true ? _cropType : null,
        latitude: _latitude,
        longitude: _longitude,
      );

      setState(() {
        _isAnalyzing = false;
      });

      if (mounted) {
        Navigator.pushNamed(
          context,
          AppRoutes.analysisResult,
          arguments: result,
        );
      }
    } on CropHealthApiException catch (e) {
      setState(() {
        _isAnalyzing = false;
      });

      if (mounted) {
        _showErrorDialog(e.message, isNetworkError: e.isNetworkError);
      }
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error analyzing crop: $e')),
        );
      }
    }
  }

  void _showErrorDialog(String message, {bool isNetworkError = false}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(
              isNetworkError ? Icons.wifi_off : Icons.error_outline,
              color: Colors.red,
            ),
            const SizedBox(width: 8),
            Text(isNetworkError ? 'Connection Error' : 'Analysis Failed'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
          if (isNetworkError)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _analyzeCrop();
              },
              child: const Text('Retry'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.cropAnalysis),
        actions: const [LanguageToggle()],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.isHindi
                  ? 'अपनी फसल के स्वास्थ्य का विश्लेषण करें'
                  : 'Analyze your crop health',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              loc.isHindi
                  ? 'रोग पहचान और उपचार सुझाव पाने के लिए फोटो लें या अपलोड करें।'
                  : 'Take or upload a photo of your crop to detect diseases and get treatment recommendations.',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),

            // Location Status Indicator
            _buildLocationStatus(),
            const SizedBox(height: 16),

            // Image Picker
            ImagePickerWidget(onImagePicked: _onImagePicked),
            const SizedBox(height: 16),

            // Crop Type Input (Optional)
            TextFormField(
              decoration: InputDecoration(
                labelText: loc.cropTypeOptional,
                hintText: loc.cropTypeHint,
                helperText: loc.helpsImproveAccuracy,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.grass),
                suffixIcon: _cropType?.isNotEmpty == true
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _cropType = null;
                          });
                        },
                      )
                    : null,
              ),
              textCapitalization: TextCapitalization.words,
              onChanged: (value) {
                setState(() {
                  _cropType = value;
                });
              },
            ),
            const SizedBox(height: 24),

            // Analyze Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isAnalyzing ? null : _analyzeCrop,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isAnalyzing
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(loc.detectingDiseases),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.biotech),
                          const SizedBox(width: 8),
                          Text(loc.analyzeCrop),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),

            // Information Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb_outline,
                            color: Colors.amber.shade700),
                        const SizedBox(width: 8),
                        Text(
                          loc.tipsForBetterAnalysis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTip(Icons.wb_sunny_outlined, loc.tipGoodLighting),
                    _buildTip(Icons.center_focus_strong, loc.tipFocusAffected),
                    _buildTip(Icons.compare, loc.tipIncludeBoth),
                    _buildTip(Icons.zoom_in, loc.tipCloseUp),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationStatus() {
    if (_locationLoading) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 8),
            Text('Getting location...', style: TextStyle(fontSize: 12)),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: _locationEnabled ? null : _checkAndRequestLocation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color:
              _locationEnabled ? Colors.green.shade50 : Colors.orange.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _locationEnabled
                ? Colors.green.shade200
                : Colors.orange.shade200,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _locationEnabled ? Icons.location_on : Icons.location_off,
              size: 16,
              color: _locationEnabled
                  ? Colors.green.shade700
                  : Colors.orange.shade700,
            ),
            const SizedBox(width: 6),
            Text(
              _locationEnabled
                  ? 'Location enabled for accurate detection'
                  : 'Tap to enable location for better accuracy',
              style: TextStyle(
                fontSize: 12,
                color: _locationEnabled
                    ? Colors.green.shade700
                    : Colors.orange.shade700,
              ),
            ),
            if (!_locationEnabled) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_forward_ios,
                size: 12,
                color: Colors.orange.shade700,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTip(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(color: Colors.grey.shade700)),
          ),
        ],
      ),
    );
  }
}
