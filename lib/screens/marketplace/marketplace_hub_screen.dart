import 'package:flutter/material.dart';
import 'package:kisaan_mitra/config/routes.dart';
import 'package:kisaan_mitra/models/marketplace_models.dart';
import 'package:kisaan_mitra/services/product_service.dart';
import 'package:kisaan_mitra/services/price_intelligence_service.dart';
import 'package:kisaan_mitra/services/recommendation_service.dart';
import 'package:kisaan_mitra/services/localization_service.dart';
import 'package:kisaan_mitra/widgets/common/language_toggle.dart';

/// Main marketplace hub screen with quick access to all features
class MarketplaceHubScreen extends StatelessWidget {
  const MarketplaceHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final recommendationService = RecommendationService();
    final priceService = PriceIntelligenceService();
    final productService = ProductService();

    final criticalAlerts = recommendationService.getCriticalAlerts();
    final trendingUp = priceService.getTrendingUpCrops();
    final cartCount = productService.getCartItemCount();

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.marketplace),
        actions: [
          const LanguageToggle(),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () => Navigator.pushNamed(context, AppRoutes.cart),
              ),
              if (cartCount > 0)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$cartCount',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Critical Alert Banner
            if (criticalAlerts.isNotEmpty)
              _buildAlertBanner(context, criticalAlerts.first),

            // Main Feature Cards
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Actions Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickActionCard(
                          context,
                          icon: Icons.storefront,
                          title: loc.shop,
                          subtitle: loc.buyFarmInputs,
                          color: Colors.green,
                          route: AppRoutes.productCatalog,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickActionCard(
                          context,
                          icon: Icons.sell,
                          title: loc.sellCrops,
                          subtitle: loc.listYourProduce,
                          color: Colors.blue,
                          route: AppRoutes.sellCrop,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickActionCard(
                          context,
                          icon: Icons.analytics,
                          title: loc.prices,
                          subtitle: loc.mspVsMarket,
                          color: Colors.purple,
                          route: AppRoutes.priceComparison,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickActionCard(
                          context,
                          icon: Icons.psychology,
                          title: loc.aiInsights,
                          subtitle: loc.recommendations,
                          color: Colors.orange,
                          route: AppRoutes.recommendations,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Trending Crops Section
                  Text(
                    '📈 ${loc.trendingUp}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: trendingUp.length,
                      itemBuilder: (context, index) =>
                          _buildTrendingCard(trendingUp[index]),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Featured Products Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '⭐ ${loc.featuredProducts}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(
                            context, AppRoutes.productCatalog),
                        child: Text(loc.seeAll),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildFeaturedProducts(context, productService),

                  const SizedBox(height: 24),

                  // More Actions
                  Text(
                    loc.moreActions,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildActionTile(
                    context,
                    icon: Icons.list_alt,
                    title: loc.myListings,
                    subtitle: loc.manageYourListings,
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.savedListings),
                  ),
                  _buildActionTile(
                    context,
                    icon: Icons.trending_up,
                    title: loc.marketPrices,
                    subtitle: loc.viewAllMandiPrices,
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.marketPrices),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertBanner(BuildContext context, LocalStockAlertModel alert) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.recommendations),
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red.shade400, Colors.red.shade600],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '⚠️ ${alert.cropName} Overstock Alert',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    alert.message,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required String route,
  }) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.1),
              color.withValues(alpha: 0.05)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: color,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: color.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingCard(MarketTrendModel trend) {
    final isUp = trend.trend == PriceTrend.up;

    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUp ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUp ? Colors.green.shade200 : Colors.red.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            trend.cropName,
            style: const TextStyle(fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '₹${trend.currentPrice.toStringAsFixed(1)}/kg',
            style: TextStyle(
              color: isUp ? Colors.green.shade700 : Colors.red.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              Icon(
                isUp ? Icons.trending_up : Icons.trending_down,
                color: isUp ? Colors.green : Colors.red,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '${trend.priceChange7d >= 0 ? '+' : ''}${trend.priceChange7d.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: isUp ? Colors.green : Colors.red,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedProducts(
      BuildContext context, ProductService productService) {
    final featured = productService.getFeaturedProducts();

    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: featured.length,
        itemBuilder: (context, index) {
          final product = featured[index];
          return Container(
            width: 130,
            margin: const EdgeInsets.only(right: 12),
            child: Card(
              child: InkWell(
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.productCatalog),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.category.icon,
                        style: const TextStyle(fontSize: 32),
                      ),
                      const Spacer(),
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '₹${product.price.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey.shade100,
          child: Icon(icon, color: Colors.grey.shade700),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
