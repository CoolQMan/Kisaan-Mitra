import 'package:flutter/material.dart';
import 'package:kisaan_mitra/config/routes.dart';
import 'package:kisaan_mitra/models/marketplace_model.dart';
import 'package:kisaan_mitra/services/marketplace_service.dart';
import 'package:kisaan_mitra/widgets/marketplace/crop_listing_card.dart';
import 'package:intl/intl.dart';

import '../../services/storage_service.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({Key? key}) : super(key: key);

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen>
    with SingleTickerProviderStateMixin {
  final MarketplaceService _marketplaceService = MarketplaceService();
  late TabController _tabController;

  List<CropListingModel> _allListings = [];
  List<CropListingModel> _myListings = [];
  List<MarketPriceModel> _marketPrices = [];

  bool _isLoading = true;
  String _searchQuery = '';
  bool _isMarketPricesExpanded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    _loadMarketplaceData();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      setState(() {});
    }
  }

  Future<void> _loadMarketplaceData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final storageService = StorageService();

      // Get listings from storage
      final myListings = await storageService.getMyListings();

      // Initialize mock data for all listings if needed
      if (_allListings.isEmpty) {
        _marketplaceService.initMockData();
        _allListings = _marketplaceService.getAllListings();
      }

      setState(() {
        _myListings = myListings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading marketplace data: $e')),
      );
    }
  }

  void _filterListings(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  List<CropListingModel> get _filteredListings {
    final listings = _tabController.index == 0 ? _allListings : _myListings;

    if (_searchQuery.isEmpty) {
      return listings;
    }

    return listings
        .where((listing) =>
            listing.cropType
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            listing.description
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            listing.location.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  Widget _buildPriceInfo(String crop, String price) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            crop,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            price,
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  //Delete Listing from My Listing
  void _deleteMyListing(String listingId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Listing'),
          content: const Text('Are you sure you want to delete this listing?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(context).pop();

                try {
                  final storageService = StorageService();
                  await storageService.removeFromMyListings(listingId);

                  // Refresh the listings
                  _loadMarketplaceData();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Listing deleted successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting listing: $e')),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark),
            tooltip: 'Saved Listings',
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.savedListings);
            },
          ),
        ],
        title: const Text('Crop Marketplace'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All Listings'),
            Tab(text: 'My Listings'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadMarketplaceData,
              child: Column(
                children: [
                  // Search bar with improved styling
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search by crop, location, or description...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                              _filterListings('');
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12.0),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                          _filterListings(value);
                        });
                      },
                    ),
                  ),

                  // Enhanced Market price section
                  if (_tabController.index == 0)
                    Column(
                      children: [
                        // Collapsible header
                        InkWell(
                          onTap: () {
                            setState(() {
                              _isMarketPricesExpanded =
                                  !_isMarketPricesExpanded;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Current Market Prices',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Icon(
                                  _isMarketPricesExpanded
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: Colors.grey[700],
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Expandable content
                        if (_isMarketPricesExpanded)
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                  context, AppRoutes.marketPrices);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blue.shade200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      _buildPriceInfo('Wheat', '₹22.50/kg'),
                                      const SizedBox(width: 16),
                                      _buildPriceInfo('Rice', '₹35.00/kg'),
                                      const SizedBox(width: 16),
                                      _buildPriceInfo('Cotton', '₹65.00/kg'),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Tap to view all prices',
                                        style: TextStyle(
                                          color: Colors.blue[700],
                                          fontSize: 12,
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward,
                                        size: 12,
                                        color: Colors.blue[700],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),

                  // Listings with improved styling
                  Expanded(
                    child: _filteredListings.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _tabController.index == 0
                                      ? Icons.search_off
                                      : Icons.add_circle_outline,
                                  size: 48,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _tabController.index == 0
                                      ? 'No crop listings match your search'
                                      : 'You haven\'t listed any crops yet',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (_tabController.index == 1)
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                              context, AppRoutes.sellCrop)
                                          .then((_) {
                                        _loadMarketplaceData();
                                      });
                                    },
                                    icon: const Icon(Icons.add),
                                    label: const Text('Add Listing'),
                                  ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredListings.length,
                            itemBuilder: (context, index) {
                              final listing = _filteredListings[index];
                              return CropListingCard(
                                listing: listing,
                                isUserListing: _tabController.index == 1,
                                onDelete: _tabController.index == 1
                                    ? _deleteMyListing
                                    : null,
                                onTap: () {
                                  if (_tabController.index == 1) {
                                    // Navigate to edit screen for user's own listings
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.editListing,
                                      arguments: listing,
                                    ).then((result) {
                                      if (result == true) {
                                        // Refresh listings if update was successful
                                        _loadMarketplaceData();
                                      }
                                    });
                                  } else {
                                    // Navigate to view details for other listings
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.cropListings,
                                      arguments: listing,
                                    );
                                  }
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.sellCrop).then((_) {
            _loadMarketplaceData();
          });
        },
        child: const Icon(Icons.add),
        tooltip: 'Add new crop listing',
      ),
    );
  }
}
