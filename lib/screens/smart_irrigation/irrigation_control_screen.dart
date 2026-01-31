import 'package:flutter/material.dart';
import 'package:kisaan_mitra/models/iot_sensor_models.dart';
import 'package:kisaan_mitra/services/iot_service.dart';

/// Irrigation Control Screen with auto/manual modes and scheduling
class IrrigationControlScreen extends StatefulWidget {
  const IrrigationControlScreen({super.key});

  @override
  State<IrrigationControlScreen> createState() =>
      _IrrigationControlScreenState();
}

class _IrrigationControlScreenState extends State<IrrigationControlScreen> {
  final IoTService _iotService = IoTService();
  String _selectedFieldId = 'field_1';

  @override
  Widget build(BuildContext context) {
    final isPremium = _iotService.isPremium;
    final currentMode = _iotService.currentMode;
    final fields = _iotService.fields;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Field Selector
          _buildFieldSelector(fields),
          const SizedBox(height: 20),

          // Current Status Card
          _buildCurrentStatusCard(currentMode),
          const SizedBox(height: 20),

          // Irrigation Mode Selector
          const Text('Irrigation Mode',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildModeSelector(currentMode, isPremium),
          const SizedBox(height: 24),

          // Mode-specific controls
          if (currentMode == IrrigationMode.auto) _buildAutoControls(),
          if (currentMode == IrrigationMode.manual) _buildManualControls(),
          if (currentMode == IrrigationMode.scheduled) _buildScheduleControls(),

          const SizedBox(height: 24),

          // Quick Actions
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildFieldSelector(List<FieldModel> fields) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedFieldId,
          isExpanded: true,
          items: fields.map((field) {
            return DropdownMenuItem(
              value: field.id,
              child: Text('${field.name} (${field.currentCrop})'),
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

  Widget _buildCurrentStatusCard(IrrigationMode mode) {
    final activeCommand = _iotService.activeManualCommand;
    final isActive = mode == IrrigationMode.manual && activeCommand != null;
    final moisture = _iotService.getSoilMoisture(_selectedFieldId);

    return Card(
      color: isActive ? Colors.blue.shade50 : null,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.blue : Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isActive ? Icons.water_drop : Icons.water_drop_outlined,
                    color: isActive ? Colors.white : Colors.grey,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isActive ? 'Irrigation Active' : 'Irrigation Off',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isActive
                              ? Colors.blue.shade700
                              : Colors.grey.shade700,
                        ),
                      ),
                      Text(
                        isActive
                            ? '${activeCommand.remainingMinutes} min remaining'
                            : 'Soil moisture: ${moisture.moisturePercent.toStringAsFixed(0)}%',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                if (isActive)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _iotService.stopManualIrrigation();
                      });
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('STOP'),
                  ),
              ],
            ),
            if (moisture.needsWater && !isActive) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.orange.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Soil moisture is low. Consider starting irrigation.',
                        style: TextStyle(color: Colors.orange.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildModeSelector(IrrigationMode currentMode, bool isPremium) {
    return Column(
      children: IrrigationMode.values.map((mode) {
        final isSelected = currentMode == mode;
        final isLocked = mode == IrrigationMode.auto && !isPremium;

        return GestureDetector(
          onTap: isLocked
              ? () => _showPremiumDialog()
              : () {
                  setState(() {
                    _iotService.setIrrigationMode(mode);
                  });
                },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? Colors.green.shade50 : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.green : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.green.shade100
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    mode.icon,
                    color: isSelected ? Colors.green : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            mode.displayName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.green.shade700 : null,
                            ),
                          ),
                          if (isLocked) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.lock,
                                      size: 12, color: Colors.amber.shade700),
                                  const SizedBox(width: 4),
                                  Text('Premium',
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.amber.shade700)),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        mode.description,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle, color: Colors.green),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAutoControls() {
    final settings = _iotService.autoSettings;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_mode, color: Colors.green.shade600),
                const SizedBox(width: 8),
                const Text('Auto-Irrigation Settings',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),

            // Moisture Thresholds
            const Text('Start irrigation when moisture below:'),
            Slider(
              value: settings.moistureThresholdLow,
              min: 20,
              max: 50,
              divisions: 6,
              label: '${settings.moistureThresholdLow.toInt()}%',
              onChanged: (value) {
                setState(() {
                  _iotService.updateAutoSettings(
                      settings.copyWith(moistureThresholdLow: value));
                });
              },
            ),

            const Text('Stop irrigation when moisture above:'),
            Slider(
              value: settings.moistureThresholdHigh,
              min: 50,
              max: 80,
              divisions: 6,
              label: '${settings.moistureThresholdHigh.toInt()}%',
              onChanged: (value) {
                setState(() {
                  _iotService.updateAutoSettings(
                      settings.copyWith(moistureThresholdHigh: value));
                });
              },
            ),

            const Divider(),

            // Smart pausing options
            SwitchListTile(
              title: const Text('Pause on rain prediction'),
              subtitle: const Text('Stop irrigation if rain is forecasted'),
              value: settings.pauseOnRain,
              onChanged: (value) {
                setState(() {
                  _iotService.updateAutoSettings(
                      settings.copyWith(pauseOnRain: value));
                });
              },
            ),
            SwitchListTile(
              title: const Text('Pause on high humidity'),
              subtitle: const Text('Stop irrigation if humidity > 80%'),
              value: settings.pauseOnHighHumidity,
              onChanged: (value) {
                setState(() {
                  _iotService.updateAutoSettings(
                      settings.copyWith(pauseOnHighHumidity: value));
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualControls() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.touch_app, color: Colors.blue.shade600),
                const SizedBox(width: 8),
                const Text('Manual Control',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Select irrigation duration:'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [15, 30, 45, 60].map((minutes) {
                return ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _iotService.startManualIrrigation(
                          _selectedFieldId, minutes);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Started $minutes min irrigation')),
                    );
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: Text('$minutes min'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Tap a button to start irrigation for the selected field. You can stop it anytime.',
                      style:
                          TextStyle(color: Colors.blue.shade700, fontSize: 12),
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

  Widget _buildScheduleControls() {
    final schedules = _iotService.getSchedulesForField(_selectedFieldId);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.schedule, color: Colors.purple.shade600),
                    const SizedBox(width: 8),
                    const Text('Irrigation Schedule',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => _showAddScheduleDialog(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (schedules.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                child: const Center(
                  child: Text('No schedules set. Tap + to add one.'),
                ),
              )
            else
              ...schedules.map((schedule) => _buildScheduleItem(schedule)),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleItem(IrrigationSchedule schedule) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            schedule.isEnabled ? Colors.purple.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.purple.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              schedule.dayName,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.purple.shade700),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${schedule.startTime.format(context)}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${schedule.durationMinutes} minutes',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () {
              setState(() {
                _iotService.removeSchedule(schedule.id);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Actions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionButton(
                Icons.water_drop,
                'Water Now',
                Colors.blue,
                () => _iotService.startManualIrrigation(_selectedFieldId, 15),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionButton(
                Icons.stop_circle_outlined,
                'Stop All',
                Colors.red,
                () {
                  setState(() {
                    _iotService.stopManualIrrigation();
                    _iotService.setIrrigationMode(IrrigationMode.off);
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        onTap();
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(label)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  void _showPremiumDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.workspace_premium, color: Colors.amber),
            SizedBox(width: 8),
            Text('Premium Feature'),
          ],
        ),
        content: const Text(
          'Auto-irrigation requires IoT sensors and a premium subscription. '
          'Upgrade to unlock smart automatic irrigation based on real-time soil moisture.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Maybe Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _iotService.setPremiumStatus(true);
              });
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber.shade700),
            child: const Text('Upgrade Now'),
          ),
        ],
      ),
    );
  }

  void _showAddScheduleDialog() {
    TimeOfDay selectedTime = const TimeOfDay(hour: 6, minute: 0);
    int selectedDay = 1;
    int duration = 30;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Schedule'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                value: selectedDay,
                decoration: const InputDecoration(labelText: 'Day'),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('Monday')),
                  DropdownMenuItem(value: 2, child: Text('Tuesday')),
                  DropdownMenuItem(value: 3, child: Text('Wednesday')),
                  DropdownMenuItem(value: 4, child: Text('Thursday')),
                  DropdownMenuItem(value: 5, child: Text('Friday')),
                  DropdownMenuItem(value: 6, child: Text('Saturday')),
                  DropdownMenuItem(value: 7, child: Text('Sunday')),
                ],
                onChanged: (v) => setDialogState(() => selectedDay = v!),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Start Time'),
                trailing: Text(selectedTime.format(context)),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: selectedTime,
                  );
                  if (time != null) {
                    setDialogState(() => selectedTime = time);
                  }
                },
              ),
              DropdownButtonFormField<int>(
                value: duration,
                decoration:
                    const InputDecoration(labelText: 'Duration (minutes)'),
                items: const [
                  DropdownMenuItem(value: 15, child: Text('15 minutes')),
                  DropdownMenuItem(value: 30, child: Text('30 minutes')),
                  DropdownMenuItem(value: 45, child: Text('45 minutes')),
                  DropdownMenuItem(value: 60, child: Text('60 minutes')),
                ],
                onChanged: (v) => setDialogState(() => duration = v!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _iotService.addSchedule(IrrigationSchedule(
                  id: 'sched_${DateTime.now().millisecondsSinceEpoch}',
                  fieldId: _selectedFieldId,
                  dayOfWeek: selectedDay,
                  startTime: selectedTime,
                  durationMinutes: duration,
                ));
                Navigator.pop(context);
                setState(() {});
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
