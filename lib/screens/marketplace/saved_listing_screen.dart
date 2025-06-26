import 'package:flutter/material.dart';
import 'package:kisaan_mitra/config/routes.dart';
import 'package:kisaan_mitra/models/marketplace_model.dart';
import 'package:kisaan_mitra/services/storage_service.dart';
import 'package:kisaan_mitra/widgets/marketplace/crop_listing_card.dart';

class SavedListingsScreen extends StatefulWidget {
  const SavedListingsScreen({Key? key}) : super(key: key);

  @override
  State<SavedListingsScreen> createState() => _SavedListingsScreenState();
}

class _SavedListingsScreenState extends State<SavedListingsScreen> {
  final StorageService _storageService = StorageService();
  List<CropListingModel> _savedListings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedListings();
  }

  Future<void> _loadSavedListings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final savedListings = await _storageService.getSavedListings();

      setState(() {
        _savedListings = savedListings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading saved listings: $e')),
      );
    }
  }

  //Delete Listing from saved listing
  void _deleteSavedListing(String listingId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove from Saved'),
          content: const Text(
              'Are you sure you want to remove this listing from your saved items?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Remove', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(context).pop();

                try {
                  await _storageService.removeFromSavedListings(listingId);

                  // Refresh the listings
                  _loadSavedListings();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Listing removed from saved items')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error removing listing: $e')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Listings'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _savedListings.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bookmark_border,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No saved listings yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Browse Listings'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadSavedListings,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _savedListings.length,
                    itemBuilder: (context, index) {
                      final listing = _savedListings[index];
                      return CropListingCard(
                        listing: listing,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.cropListings,
                            arguments: listing,
                          ).then((_) => _loadSavedListings());
                        },
                        onDelete: (id) => _deleteSavedListing(id),
                      );
                    },
                  ),
                ),
    );
  }
}
