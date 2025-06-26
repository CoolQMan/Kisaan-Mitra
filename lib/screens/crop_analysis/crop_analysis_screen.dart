import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kisaan_mitra/config/routes.dart';
import 'package:kisaan_mitra/services/ai_service.dart';
import 'package:kisaan_mitra/widgets/crop_analysis/image_picker_widget.dart';

class CropAnalysisScreen extends StatefulWidget {
  const CropAnalysisScreen({Key? key}) : super(key: key);

  @override
  State<CropAnalysisScreen> createState() => _CropAnalysisScreenState();
}

class _CropAnalysisScreenState extends State<CropAnalysisScreen> {
  final AIService _aiService = AIService();
  File? _selectedImage;
  bool _isAnalyzing = false;
  String? _cropType;

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

    if (_cropType == null || _cropType!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a crop type')),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    try {
      final result = await _aiService.analyzeCropHealth(
        _selectedImage!,
        _cropType!,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Health Analysis'),
        // Keep back button for feature screens accessed from home grid
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Analyze your crop health',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Take or upload a photo of your crop to analyze its health and get recommendations.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // Image Picker
            ImagePickerWidget(onImagePicked: _onImagePicked),
            const SizedBox(height: 16),

            // Crop Type Dropdown
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Enter Crop Type',
                hintText: 'e.g., Rice, Wheat, Cotton',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.grass),
              ),
              textCapitalization: TextCapitalization.words,
              onChanged: (value) {
                setState(() {
                  _cropType = value.trim();
                });
              },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a crop type';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Analyze Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isAnalyzing ? null : _analyzeCrop,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: _isAnalyzing
                    ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text('Analyzing...'),
                  ],
                )
                    : const Text('Analyze Crop'),
              ),
            ),
            const SizedBox(height: 16),

            // Information Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Tips for better analysis:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('• Ensure good lighting when taking photos'),
                    Text('• Focus on the affected area of the plant'),
                    Text('• Include both healthy and unhealthy parts for comparison'),
                    Text('• Take close-up shots of any visible symptoms'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
