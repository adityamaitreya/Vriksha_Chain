import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../providers/batch_provider.dart';
import '../models/batch_model.dart';
import '../widgets/nfc_validation_widget.dart';

class BatchDetailScreen extends StatefulWidget {
  final String batchId;

  const BatchDetailScreen({
    super.key,
    required this.batchId,
  });

  @override
  State<BatchDetailScreen> createState() => _BatchDetailScreenState();
}

class _BatchDetailScreenState extends State<BatchDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Batch Details'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/batches'),
        ),
      ),
      body: Consumer<BatchProvider>(
        builder: (context, batchProvider, child) {
          final batch = batchProvider.batches.firstWhere(
            (b) => b.id == widget.batchId,
            orElse: () => Batch(
              id: '',
              batchNumber: '',
              productName: '',
              quantity: '',
              origin: '',
              harvestDate: '',
              status: '',
              quality: '',
              currentLocation: '',
              lastUpdated: '',
            ),
          );

          if (batch.id.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Batch not found'),
                ],
              ),
            );
          }

          final statusColor = _getStatusColor(batch.status);
          final publicUrl = '${Uri.base.origin}/public/batch/${batch.id}';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Batch Info Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.inventory_2,
                                color: statusColor,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    batch.productName.isNotEmpty
                                        ? batch.productName
                                        : 'Unnamed Product',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Batch: ${batch.batchNumber}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                batch.status,
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildInfoRow(
                          Icons.location_on,
                          'Origin',
                          batch.origin.isNotEmpty ? batch.origin : 'Not set',
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          Icons.place,
                          'Current Location',
                          batch.currentLocation.isNotEmpty
                              ? batch.currentLocation
                              : 'Not set',
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoRow(
                                Icons.scale,
                                'Quantity',
                                batch.quantity.isNotEmpty ? batch.quantity : 'N/A',
                              ),
                            ),
                            Expanded(
                              child: _buildInfoRow(
                                Icons.star,
                                'Quality',
                                batch.quality.isNotEmpty ? batch.quality : 'Unknown',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          Icons.calendar_today,
                          'Harvest Date',
                          batch.harvestDate.isNotEmpty
                              ? batch.harvestDate
                              : 'Not set',
                        ),
                        if (batch.nfcTagId.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            Icons.nfc,
                            'NFC Tag ID',
                            batch.nfcTagId.length > 30
                                ? '${batch.nfcTagId.substring(0, 30)}...'
                                : batch.nfcTagId,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Route Timeline Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Route Timeline',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Chronological journey of the batch',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildTimeline(batch),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // QR Code Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text(
                          'Batch QR Code',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: QrImageView(
                            data: publicUrl,
                            version: QrVersions.auto,
                            size: 200.0,
                            backgroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Scan to view batch details',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // NFC Validation Card (if NFC tag is registered)
                if (batch.nfcTagId.isNotEmpty)
                  Column(
                    children: [
                      NFCValidationWidget(
                        batch: batch,
                        step: batch.status,
                        onValidationSuccess: () {
                          // Refresh the batch data after successful validation
                          // The provider will update automatically via stream
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),

                // Status Update Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Update Status',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: batch.status,
                          decoration: const InputDecoration(
                            labelText: 'Status',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'Created', child: Text('Created')),
                            DropdownMenuItem(value: 'Harvested', child: Text('Harvested')),
                            DropdownMenuItem(value: 'Processing', child: Text('Processing')),
                            DropdownMenuItem(value: 'Quality Check', child: Text('Quality Check')),
                            DropdownMenuItem(value: 'Packaged', child: Text('Packaged')),
                            DropdownMenuItem(value: 'In Transit', child: Text('In Transit')),
                            DropdownMenuItem(value: 'In Distribution', child: Text('In Distribution')),
                            DropdownMenuItem(value: 'Delivered', child: Text('Delivered')),
                            DropdownMenuItem(value: 'Completed', child: Text('Completed')),
                            DropdownMenuItem(value: 'Cancelled', child: Text('Cancelled')),
                          ],
                          onChanged: (value) async {
                            if (value != null && value != batch.status) {
                              final batchProvider = Provider.of<BatchProvider>(
                                context,
                                listen: false,
                              );
                              final success = await batchProvider.updateBatch(
                                batch.id,
                                {'status': value},
                              );
                              if (success && mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Status updated to $value'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Delivered':
      case 'Completed':
        return Colors.green;
      case 'In Transit':
      case 'In Distribution':
        return Colors.blue;
      case 'Quality Check':
        return Colors.orange;
      case 'Processing':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Widget _buildTimeline(Batch batch) {
    final steps = _buildTimelineSteps(batch);
    
    return Column(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        final isLast = index == steps.length - 1;
        
        return _buildTimelineItem(
          step: step,
          isLast: isLast,
          index: index + 1,
        );
      }).toList(),
    );
  }

  List<TimelineStep> _buildTimelineSteps(Batch batch) {
    final statusOrder = [
      'Created',
      'Harvested',
      'Processing',
      'Quality Check',
      'Packaged',
      'In Transit',
      'In Distribution',
      'Delivered',
      'Completed'
    ];
    
    final currentStatus = batch.status.isNotEmpty ? batch.status : 'Created';
    final currentIndex = statusOrder.indexOf(currentStatus);
    
    final steps = [
      TimelineStep(
        label: 'Harvested',
        icon: Icons.eco,
        location: currentStatus == 'Harvested' && batch.currentLocation.isNotEmpty
            ? batch.currentLocation
            : batch.origin.isNotEmpty
                ? batch.origin
                : 'Farm',
      ),
      TimelineStep(
        label: 'Processing',
        icon: Icons.factory,
        location: currentStatus == 'Processing' && batch.currentLocation.isNotEmpty
            ? batch.currentLocation
            : 'Processing Facility',
      ),
      TimelineStep(
        label: 'Quality Check',
        icon: Icons.verified,
        location: currentStatus == 'Quality Check' && batch.currentLocation.isNotEmpty
            ? batch.currentLocation
            : 'Quality Assurance',
      ),
      TimelineStep(
        label: 'Packaged',
        icon: Icons.inventory_2,
        location: currentStatus == 'Packaged' && batch.currentLocation.isNotEmpty
            ? batch.currentLocation
            : 'Packaging Unit',
      ),
      TimelineStep(
        label: 'In Distribution',
        icon: Icons.local_shipping,
        location: currentStatus == 'In Distribution' && batch.currentLocation.isNotEmpty
            ? batch.currentLocation
            : 'Distribution Center',
      ),
      TimelineStep(
        label: 'Delivered',
        icon: Icons.check_circle,
        location: currentStatus == 'Delivered' && batch.currentLocation.isNotEmpty
            ? batch.currentLocation
            : 'Destination',
      ),
    ];
    
    // Set status for each step
    for (var i = 0; i < steps.length; i++) {
      final stepIndex = statusOrder.indexOf(steps[i].label);
      
      if (stepIndex < currentIndex) {
        steps[i].status = TimelineStatus.completed;
        // Simulate timestamps for completed steps
        final daysAgo = (steps.length - i) * 2;
        steps[i].timestamp = DateTime.now()
            .subtract(Duration(days: daysAgo))
            .toString()
            .split('.')[0];
      } else if (stepIndex == currentIndex) {
        steps[i].status = TimelineStatus.current;
        steps[i].timestamp = batch.lastUpdated.isNotEmpty
            ? batch.lastUpdated
            : 'In Progress';
      } else {
        steps[i].status = TimelineStatus.upcoming;
        steps[i].timestamp = 'Pending';
      }
    }
    
    return steps;
  }

  Widget _buildTimelineItem({
    required TimelineStep step,
    required bool isLast,
    required int index,
  }) {
    Color iconColor;
    Color bgColor;
    
    switch (step.status) {
      case TimelineStatus.completed:
        iconColor = Colors.white;
        bgColor = Colors.green;
        break;
      case TimelineStatus.current:
        iconColor = Colors.white;
        bgColor = Colors.blue;
        break;
      case TimelineStatus.upcoming:
        iconColor = Colors.grey[600]!;
        bgColor = Colors.grey[300]!;
        break;
    }
    
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator column
          Column(
            children: [
              // Circle with icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                  boxShadow: step.status == TimelineStatus.current
                      ? [
                          BoxShadow(
                            color: bgColor.withOpacity(0.4),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  step.icon,
                  size: 20,
                  color: iconColor,
                ),
              ),
              // Connecting line
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          bgColor,
                          step.status == TimelineStatus.upcoming
                              ? Colors.grey[300]!
                              : Colors.green.withOpacity(0.5),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Content column
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: isLast ? 0 : 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$index. ${step.label}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: step.status == TimelineStatus.upcoming
                              ? Colors.grey[600]
                              : Colors.black87,
                        ),
                      ),
                      if (step.status != TimelineStatus.upcoming)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: bgColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            step.status == TimelineStatus.completed
                                ? 'Completed'
                                : 'Current',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: bgColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          step.location,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatTimestamp(step.timestamp),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(String timestamp) {
    if (timestamp == 'Pending' || timestamp == 'In Progress') {
      return timestamp;
    }
    
    try {
      final date = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return timestamp;
    }
  }
}

// Timeline models
enum TimelineStatus { completed, current, upcoming }

class TimelineStep {
  final String label;
  final IconData icon;
  final String location;
  TimelineStatus status;
  String timestamp;

  TimelineStep({
    required this.label,
    required this.icon,
    required this.location,
    this.status = TimelineStatus.upcoming,
    this.timestamp = '',
  });
}


