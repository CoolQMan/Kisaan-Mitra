import 'package:flutter/material.dart';
import 'package:kisaan_mitra/models/marketplace_model.dart';
import 'package:kisaan_mitra/services/marketplace_service.dart';
import 'package:kisaan_mitra/services/storage_service.dart';
import 'package:intl/intl.dart';

class EditListingScreen extends StatefulWidget {
  final CropListingModel listing;

  const EditListingScreen({
    Key? key,
    required this.listing,
  }) : super(key: key);

  @override
  State<EditListingScreen> createState() => _EditListingScreenState();
}

class _EditListingScreenState extends State<EditListingScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _cropTypeController;
  late TextEditingController _quantityController;
  late TextEditingController _priceController;
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;

  final MarketplaceService _marketplaceService = MarketplaceService();
  final StorageService _storageService = StorageService();

  late String _quantityUnit;
  late DateTime _harvestDate;
  bool _isLoading = false;
  bool _isGettingSuggestedPrice = false;
  double? _suggestedPrice;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing values
    _cropTypeController = TextEditingController(text: widget.listing.cropType);
    _quantityController =
        TextEditingController(text: widget.listing.quantity.toString());
    _priceController =
        TextEditingController(text: widget.listing.price.toString());
    _locationController = TextEditingController(text: widget.listing.location);
    _descriptionController =
        TextEditingController(text: widget.listing.description);
    _quantityUnit = widget.listing.quantityUnit;
    _harvestDate = widget.listing.harvestDate;
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

  Future<void> _updateListing() async {
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

      // Create updated listing
      final updatedListing = CropListingModel(
        id: widget.listing.id,
        userId: widget.listing.userId,
        userName: widget.listing.userName,
        cropType: cropType,
        quantity: quantity,
        quantityUnit: _quantityUnit,
        price: price,
        location: location,
        harvestDate: _harvestDate,
        listedDate: widget.listing.listedDate,
        description: description,
        images: widget.listing.images,
        isAvailable: widget.listing.isAvailable,
      );

      // Update in storage
      await _storageService.updateMyListing(updatedListing);

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Listing updated successfully')),
        );
        Navigator.pop(
            context, true); // Return true to indicate update was successful
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating listing: $e')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Listing'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Update your crop listing',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Edit details about your crop listing',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 16),

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
                  setState(() {
                    _suggestedPrice = null;
                  });
                },
              ),
              const SizedBox(height: 12),

              // Quantity and Unit
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
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 4,
                    child: DropdownButtonFormField<String>(
                      value: _quantityUnit,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Unit',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'kg', child: Text('kg')),
                        DropdownMenuItem(
                            value: 'quintal', child: Text('quintal')),
                        DropdownMenuItem(value: 'ton', child: Text('ton')),
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
              const SizedBox(height: 12),

              // Price
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Price (₹ per ${_quantityUnit})',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.currency_rupee),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                    onPressed:
                        _isGettingSuggestedPrice ? null : _getSuggestedPrice,
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
              const SizedBox(height: 12),

              // Location
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  hintText: 'e.g., Punjab, India',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Harvest Date
              InkWell(
                onTap: _selectHarvestDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Harvest Date',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
              const SizedBox(height: 12),

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Describe your crop quality, variety, etc.',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Update Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateListing,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
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
                            Text('Updating...'),
                          ],
                        )
                      : const Text('Update Listing'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
