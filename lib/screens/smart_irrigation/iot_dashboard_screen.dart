import 'package:flutter/material.dart';
import 'package:kisaan_mitra/models/iot_sensor_models.dart';
import 'package:kisaan_mitra/services/iot_service.dart';
import 'package:kisaan_mitra/services/localization_service.dart';

/// IoT Dashboard showing sensor readings with premium lock overlay
class IoTDashboardScreen extends StatefulWidget {
  const IoTDashboardScreen({super.key});

  @override
  State<IoTDashboardScreen> createState() => _IoTDashboardScreenState();
}

class _IoTDashboardScreenState extends State<IoTDashboardScreen> {
  final IoTService _iotService = IoTService();
  String _selectedFieldId = 'field_1';

  @override
  Widget build(BuildContext context) {
    final isPremium = _iotService.isPremium;
    final fields = _iotService.fields;

    return Stack(
      children: [
        // Main Content
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Premium badge if unlocked
              if (isPremium) _buildPremiumBadge(),

              // Field Selector
              _buildFieldSelector(fields),
              const SizedBox(height: 20),

              // Sensor Status
              _buildSensorStatus(),
              const SizedBox(height: 20),

              // Soil Moisture Gauge
              _buildSoilMoistureCard(),
              const SizedBox(height: 16),

              // Soil Nutrients Card
              _buildSoilNutrientsCard(),
              const SizedBox(height: 16),

              // Device Status
              _buildDeviceStatusCard(),
            ],
          ),
        ),

        // Premium Lock Overlay (if not premium)
        if (!isPremium) _buildPremiumLockOverlay(),
      ],
    );
  }

  Widget _buildPremiumBadge() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade600, Colors.orange.shade700],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.workspace_premium, color: Colors.white, size: 18),
          const SizedBox(width: 6),
          Text(
            loc.isHindi ? 'प्रीमियम सक्रिय' : 'Premium Active',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldSelector(List<FieldModel> fields) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedFieldId,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          items: fields.map((field) {
            return DropdownMenuItem(
              value: field.id,
              child: Row(
                children: [
                  const Icon(Icons.grass, color: Colors.green),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(field.name,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text('${field.currentCrop} • ${field.areaAcres} acres',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedFieldId = value);
            }
          },
        ),
      ),
    );
  }

  Widget _buildSensorStatus() {
    final sensors = _iotService.getSensorsForField(_selectedFieldId);
    final onlineCount = sensors.where((s) => s.isOnline).length;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: onlineCount == sensors.length
                ? Colors.green.shade100
                : Colors.orange.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.sensors,
            color: onlineCount == sensors.length ? Colors.green : Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                loc.isHindi
                    ? '$onlineCount/${sensors.length} सेंसर ऑनलाइन'
                    : '$onlineCount/${sensors.length} Sensors Online',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(
                loc.isHindi
                    ? 'अंतिम सिंक: ${_formatLastSync(sensors)}'
                    : 'Last sync: ${_formatLastSync(sensors)}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ],
        ),
      ],
    );
  }

  String _formatLastSync(List<SensorDevice> sensors) {
    if (sensors.isEmpty) return 'No sensors';
    final mostRecent =
        sensors.reduce((a, b) => a.lastSync.isAfter(b.lastSync) ? a : b);
    final diff = DateTime.now().difference(mostRecent.lastSync);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    return '${diff.inHours} hours ago';
  }

  Widget _buildSoilMoistureCard() {
    final moisture = _iotService.getSoilMoisture(_selectedFieldId);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.water_drop, color: Colors.blue.shade600),
                const SizedBox(width: 8),
                Text(loc.soilMoisture,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),

            // Moisture Gauge
            Center(
              child: SizedBox(
                height: 150,
                width: 150,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 140,
                      width: 140,
                      child: CircularProgressIndicator(
                        value: moisture.moisturePercent / 100,
                        strokeWidth: 14,
                        backgroundColor: Colors.grey.shade200,
                        valueColor:
                            AlwaysStoppedAnimation(moisture.statusColor),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${moisture.moisturePercent.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: moisture.statusColor,
                          ),
                        ),
                        Text(
                          moisture.status,
                          style: TextStyle(
                            fontSize: 12,
                            color: moisture.statusColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Optimal range indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Optimal: ${moisture.optimalMin.toInt()}% - ${moisture.optimalMax.toInt()}%',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSoilNutrientsCard() {
    final nutrients = _iotService.getSoilNutrients(_selectedFieldId);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.science, color: Colors.purple.shade600),
                const SizedBox(width: 8),
                const Text('Soil Nutrients (NPK)',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),

            // NPK Bars
            _buildNutrientBar('Nitrogen (N)', nutrients.nitrogen, 300,
                nutrients.nitrogenLevel, Colors.green),
            const SizedBox(height: 12),
            _buildNutrientBar('Phosphorus (P)', nutrients.phosphorus, 80,
                nutrients.phosphorusLevel, Colors.orange),
            const SizedBox(height: 12),
            _buildNutrientBar('Potassium (K)', nutrients.potassium, 300,
                nutrients.potassiumLevel, Colors.purple),

            const Divider(height: 32),

            // pH and other readings
            Row(
              children: [
                Expanded(
                  child: _buildSmallMetric(
                      'pH Level',
                      nutrients.ph.toStringAsFixed(1),
                      nutrients.phStatus,
                      nutrients.phColor),
                ),
                Expanded(
                  child: _buildSmallMetric(
                      'Soil Temp',
                      '${nutrients.temperature.toStringAsFixed(1)}°C',
                      'Normal',
                      Colors.blue),
                ),
                Expanded(
                  child: _buildSmallMetric(
                      'EC',
                      '${nutrients.electricalConductivity.toStringAsFixed(2)}',
                      'mS/cm',
                      Colors.teal),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientBar(
      String name, double value, double max, String level, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text('${value.toStringAsFixed(0)} mg/kg ($level)',
                style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (value / max).clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }

  Widget _buildSmallMetric(
      String label, String value, String status, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(label,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          Text(status, style: TextStyle(fontSize: 10, color: color)),
        ],
      ),
    );
  }

  Widget _buildDeviceStatusCard() {
    final sensors = _iotService.getSensorsForField(_selectedFieldId);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.devices, color: Colors.grey.shade700),
                const SizedBox(width: 8),
                const Text('Connected Devices',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            ...sensors.map((sensor) => _buildDeviceRow(sensor)),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceRow(SensorDevice sensor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: sensor.isOnline ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(sensor.name,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(sensor.type.toUpperCase(),
                    style:
                        TextStyle(fontSize: 11, color: Colors.grey.shade600)),
              ],
            ),
          ),
          Row(
            children: [
              Icon(
                sensor.needsBatteryReplace
                    ? Icons.battery_alert
                    : Icons.battery_full,
                size: 16,
                color: sensor.needsBatteryReplace ? Colors.red : Colors.green,
              ),
              const SizedBox(width: 4),
              Text('${sensor.batteryPercent}%',
                  style: const TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumLockOverlay() {
    return Container(
      color: Colors.white.withValues(alpha: 0.95),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.lock_outline,
                    size: 64, color: Colors.amber.shade700),
              ),
              const SizedBox(height: 24),
              const Text(
                '🔒 Premium Feature',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Unlock IoT Sensor Integration to get real-time soil moisture, NPK levels, and automated irrigation control.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  // Demo: Toggle premium for testing
                  setState(() {
                    _iotService.setPremiumStatus(true);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('🎉 Premium unlocked (demo mode)')),
                  );
                },
                icon: const Icon(Icons.workspace_premium),
                label: const Text('Upgrade to Premium - ₹299/month'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade700,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Maybe Later'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
