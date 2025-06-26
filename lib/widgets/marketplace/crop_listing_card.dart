import 'package:flutter/material.dart';
import 'package:kisaan_mitra/models/marketplace_model.dart';
import 'package:intl/intl.dart';

class CropListingCard extends StatelessWidget {
  final CropListingModel listing;
  final VoidCallback onTap;
  final bool isUserListing;
  final Function(String)? onDelete;

  String getImagePath(String cropType) {
    switch (cropType.toLowerCase()) {
      case 'wheat':
        return 'assets/images/wheat.jpg';
      case 'rice':
        return 'assets/images/rice.jpg';
      case 'cotton':
        return 'assets/images/cotton.jpg';
      default:
        return ''; // Empty string will trigger the placeholder icon
    }
  }

  const CropListingCard({
    Key? key,
    required this.listing,
    required this.onTap,
    this.isUserListing = false,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      symbol: '₹',
      decimalDigits: 2,
    );

    // Calculate mock market average (95% of listing price for demonstration)
    final marketAverage = listing.price * 0.95;
    final priceDifference = listing.price - marketAverage;
    final isAboveMarket = priceDifference > 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Crop Image with price badge
            Stack(
              children: [
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    image: getImagePath(listing.cropType).isNotEmpty
                        ? DecorationImage(
                            image: AssetImage(getImagePath(listing.cropType)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: getImagePath(listing.cropType).isEmpty
                      ? const Center(
                          child: Icon(
                            Icons.image,
                            size: 50,
                            color: Colors.grey,
                          ),
                        )
                      : null,
                ),
                // Price comparison badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isAboveMarket
                          ? Colors.blue.shade100
                          : Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isAboveMarket
                            ? Colors.blue.shade400
                            : Colors.green.shade400,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isAboveMarket
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          size: 14,
                          color: isAboveMarket
                              ? Colors.blue.shade700
                              : Colors.green.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isAboveMarket ? 'Above Market' : 'Below Market',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isAboveMarket
                                ? Colors.blue.shade700
                                : Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Crop Type and Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        listing.cropType,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${currencyFormat.format(listing.price)}/${listing.quantityUnit}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Market price comparison
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Market avg: ${currencyFormat.format(marketAverage)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Quantity and Location
                  Row(
                    children: [
                      Icon(
                        Icons.scale,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${listing.quantity} ${listing.quantityUnit}',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          listing.location,
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Harvest Date
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Harvested: ${DateFormat('MMM d, yyyy').format(listing.harvestDate)}',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Description
                  Text(
                    listing.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 12),

                  // Seller Info with View Details button
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.green.shade100,
                        child: Text(
                          listing.userName.substring(0, 1),
                          style: TextStyle(
                            color: Colors.green.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        listing.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      if (isUserListing || onDelete != null)
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => onDelete!(listing.id),
                          tooltip: 'Delete listing',
                        ),
                      ElevatedButton.icon(
                        onPressed: onTap,
                        icon: Icon(
                            isUserListing
                                ? Icons.edit
                                : Icons.visibility_outlined,
                            size: 16),
                        label: Text(isUserListing ? 'Edit' : 'View Details'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
