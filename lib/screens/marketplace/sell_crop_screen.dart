import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:kisaan_mitra/services/marketplace_service.dart';
import 'package:intl/intl.dart';

import '../../services/storage_service.dart';

class SellCropScreen extends StatefulWidget {
  const SellCropScreen({Key? key}) : super(key: key);

  @override
  State<SellCropScreen> createState() => _SellCropScreenState();
}

class _SellCropScreenState extends State<SellCropScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cropTypeController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  final MarketplaceService _marketplaceService = MarketplaceService();

  String _quantityUnit = 'kg';
  DateTime _harvestDate = DateTime.now().subtract(const Duration(days: 7));
  bool _isLoading = false;
  bool _isGettingSuggestedPrice = false;
  double? _suggestedPrice;

  final ImagePicker _picker = ImagePicker();
  List<File> _selectedImages = [];
  bool _imageError = false;

  @override
  void initState() {
    super.initState();
    // Set default location
    _locationController.text = 'Punjab, India';
  }

  @override
  void dispose() {
    _cropTypeController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _getSuggestedPrice() async {
    final cropType = _cropTypeController.text.trim();
    final location = _locationController.text.trim();

    if (cropType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a crop type')),
      );
      return;
    }

    if (location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a location')),
      );
      return;
    }

    setState(() {
      _isGettingSuggestedPrice = true;
    });

    try {
      final suggestedPrice = await _marketplaceService.getSuggestedPrice(
        cropType,
        location,
      );

      setState(() {
        _suggestedPrice = suggestedPrice;
        _priceController.text = suggestedPrice.toString();
        _isGettingSuggestedPrice = false;
      });
    } catch (e) {
      setState(() {
        _isGettingSuggestedPrice = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting suggested price: $e')),
      );
    }
  }

  Future<void> _submitListing() async {
    // Check if images are selected
    if (_selectedImages.isEmpty) {
      setState(() {
        _imageError = true;
      });
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final cropType = _cropTypeController.text.trim();
      final quantity = double.parse(_quantityController.text.trim());
      final price = double.parse(_priceController.text.trim());
      final location = _locationController.text.trim();
      final description = _descriptionController.text.trim();

      // Convert images to paths for storage
      List<String> imagePaths =
          _selectedImages.map((file) => file.path).toList();

      // Create new listing
      final newListing = await _marketplaceService.addListing(
        cropType,
        quantity,
        _quantityUnit,
        price,
        location,
        _harvestDate,
        description,
        imagePaths,
      );

      // Save to SharedPreferences
      final storageService = StorageService();
      await storageService.addToMyListings(newListing);

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Crop listed successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error listing crop: $e')),
        );
      }
    }
  }

  Future<void> _selectHarvestDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _harvestDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && pickedDate != _harvestDate) {
      setState(() {
        _harvestDate = pickedDate;
      });
    }
  }

  //picking imaging
  // Replace the _pickImage method
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 800,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImages = [File(pickedFile.path)]; // Only keep one image
          _imageError = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  //image source selection
  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  //remove image
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sell Crop'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'List your crop for sale',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Enter details about your crop to list it on the marketplace',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),

              // Crop Type
              TextFormField(
                controller: _cropTypeController,
                decoration: const InputDecoration(
                  labelText: 'Crop Type',
                  hintText: 'e.g., Wheat, Rice, Cotton',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.grass),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a crop type';
                  }
                  return null;
                },
                onChanged: (_) {
                  // Clear suggested price when crop type changes
                  setState(() {
                    _suggestedPrice = null;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Quantity
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.scale),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter quantity';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    flex: 4,
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: _quantityUnit,
                      decoration: const InputDecoration(
                        labelText: 'Unit',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: 'kg', child: Text('Kilograms (kg)')),
                        DropdownMenuItem(
                            value: 'quintal', child: Text('Quintal')),
                        DropdownMenuItem(value: 'ton', child: Text('Ton')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _quantityUnit = value;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Price with Suggested Price
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Price (₹ per ${_quantityUnit})',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.currency_rupee),
                      suffixIcon: IconButton(
                        icon: _isGettingSuggestedPrice
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.auto_awesome),
                        onPressed: _isGettingSuggestedPrice
                            ? null
                            : _getSuggestedPrice,
                        tooltip: 'Get suggested price',
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter price';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  if (_suggestedPrice != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Suggested price: ₹${_suggestedPrice!.toStringAsFixed(2)} per ${_quantityUnit}',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Location
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  hintText: 'e.g., Punjab, India',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Harvest Date
              InkWell(
                onTap: _selectHarvestDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Harvest Date',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateFormat('MMM d, yyyy').format(_harvestDate)),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Describe your crop quality, variety, etc.',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              //Image Selection
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Crop Images (Required)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _imageError ? Colors.red : Colors.grey.shade300,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _selectedImages.isEmpty
                        ? Center(
                            child: TextButton.icon(
                              onPressed: _showImageSourceOptions,
                              icon: const Icon(Icons.add_a_photo),
                              label: const Text('Add Image'),
                            ),
                          )
                        : Stack(
                            children: [
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: FileImage(_selectedImages[0]),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _selectedImages = []),
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                  if (_imageError)
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Please add at least one image',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitListing,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: _isLoading
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
                            Text('Listing...'),
                          ],
                        )
                      : const Text('List Crop for Sale'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
