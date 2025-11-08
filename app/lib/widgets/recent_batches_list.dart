import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/batch_provider.dart';
import '../models/batch_model.dart';

class RecentBatchesList extends StatelessWidget {
  const RecentBatchesList({super.key});

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

  @override
  Widget build(BuildContext context) {
    return Consumer<BatchProvider>(
      builder: (context, batchProvider, child) {
        if (batchProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (batchProvider.error != null) {
          return Card(
            color: Colors.red.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Error: ${batchProvider.error}',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        final batches = batchProvider.batches;
        
        if (batches.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No batches yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your first batch to get started',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Get recent batches (last 5, sorted by lastUpdated)
        final recentBatches = List<Batch>.from(batches)
          ..sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));
        
        final displayBatches = recentBatches.take(5).toList();

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: displayBatches.length,
          itemBuilder: (context, index) {
            final batch = displayBatches[index];
            final statusColor = _getStatusColor(batch.status);

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: statusColor.withOpacity(0.2),
                  child: Icon(
                    Icons.inventory_2,
                    color: statusColor,
                  ),
                ),
                title: Text(
                  batch.productName.isNotEmpty ? batch.productName : 'Unnamed Product',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Batch: ${batch.batchNumber}'),
                    Text('Origin: ${batch.origin.isNotEmpty ? batch.origin : "Not set"}'),
                    if (batch.currentLocation.isNotEmpty)
                      Text('Location: ${batch.currentLocation}'),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        batch.status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Icon(
                      Icons.chevron_right,
                      color: Colors.grey[400],
                    ),
                  ],
                ),
                onTap: () {
                  context.go('/batch/${batch.id}');
                },
              ),
            );
          },
        );
      },
    );
  }
}


