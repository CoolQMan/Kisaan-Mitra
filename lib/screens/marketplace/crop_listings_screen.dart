import 'package:flutter/material.dart';
import 'package:kisaan_mitra/models/marketplace_model.dart';
import 'package:intl/intl.dart';

import '../../services/storage_service.dart';

class CropListingsScreen extends StatefulWidget {
  final CropListingModel listing;

  const CropListingsScreen({
    Key? key,
    required this.listing,
  }) : super(key: key);

  @override
  State<CropListingsScreen> createState() => _CropListingsScreenState();
}

class _CropListingsScreenState extends State<CropListingsScreen> {
  bool _isSaving = false;

  void _saveListing() {
    setState(() {
      _isSaving = true;
    });

    // Save to SharedPreferences
    final storageService = StorageService();
    storageService.addToSavedListings(widget.listing).then((_) {
      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Listing saved for reference')),
      );

      Navigator.pop(context);
    }).catchError((error) {
      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving listing: $error')),
      );
    });
  }

  String getImagePath(String cropType) {
    switch (cropType.toLowerCase()) {
      case 'wheat':
        return 'assets/images/wheat.jpg';
      case 'rice':
        return 'assets/images/rice.jpg';
      case 'cotton':
        return 'assets/images/cotton.jpg';
      default:
        return 'assets/images/wheat.jpg'; // Default image
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      symbol: '₹',
      decimalDigits: 2,
    );

    // Calculate mock market average (95% of listing price for demonstration)
    final marketAverage = widget.listing.price * 0.95;
    final priceDifference = widget.listing.price - marketAverage;
    final isAboveMarket = priceDifference > 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.listing.cropType),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Crop Image
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                image: DecorationImage(
                  image: AssetImage(getImagePath(widget.listing.cropType)),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price and Quantity
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        currencyFormat.format(widget.listing.price),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        'per ${widget.listing.quantityUnit}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.listing.quantity} ${widget.listing.quantityUnit} available',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Divider
                  const Divider(),
                  const SizedBox(height: 16),

                  // Crop Details
                  const Text(
                    'Crop Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    Icons.grass,
                    'Crop Type',
                    widget.listing.cropType,
                  ),
                  _buildDetailRow(
                    Icons.location_on,
                    'Location',
                    widget.listing.location,
                  ),
                  _buildDetailRow(
                    Icons.calendar_today,
                    'Harvest Date',
                    DateFormat('MMM d, yyyy')
                        .format(widget.listing.harvestDate),
                  ),
                  _buildDetailRow(
                    Icons.access_time,
                    'Listed Date',
                    DateFormat('MMM d, yyyy').format(widget.listing.listedDate),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.listing.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),

                  // Divider
                  const Divider(),
                  const SizedBox(height: 16),

                  // Seller Info
                  const Text(
                    'Seller Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.green.shade100,
                        child: Text(
                          widget.listing.userName.substring(0, 1),
                          style: TextStyle(
                            color: Colors.green.shade800,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.listing.userName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.listing.location,
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Market Price Comparison (replacing bidding section)
                  const Text(
                    'Market Price Comparison',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Your Price:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              currencyFormat.format(widget.listing.price),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Market Average:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              currencyFormat.format(marketAverage),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Price Difference:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${isAboveMarket ? '+' : ''}${currencyFormat.format(priceDifference)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color:
                                    isAboveMarket ? Colors.blue : Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Price Recommendation',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your price is ${isAboveMarket ? 'above' : 'below'} the market average. ${isAboveMarket ? 'Consider lowering your price to attract more buyers.' : 'You could potentially increase your price.'}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 24),

                  // Save Button (replacing Contact Seller button)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : _saveListing,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.bookmark),
                      label: Text(_isSaving ? 'Saving...' : 'Save Listing'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
