import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/batch_provider.dart';

class StatsCards extends StatelessWidget {
  const StatsCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BatchProvider>(
      builder: (context, batchProvider, child) {
        final batches = batchProvider.batches;
        final activeBatches = batches.where((b) => 
          !['Delivered', 'Completed', 'Cancelled'].contains(b.status)
        ).length;

        final uniqueOrigins = batches
            .where((b) => b.origin.isNotEmpty)
            .map((b) => b.origin)
            .toSet()
            .length;

        final qualityScores = batches
            .where((b) => b.quality.isNotEmpty && b.quality != 'Unknown')
            .map((b) {
              if (b.quality == 'Premium') return 95;
              if (b.quality == 'Standard') return 85;
              return 75;
            })
            .toList();

        final avgQualityScore = qualityScores.isEmpty
            ? 0.0
            : qualityScores.reduce((a, b) => a + b) / qualityScores.length;

        final traceableBatches = batches.where((b) => 
          b.batchNumber.isNotEmpty &&
          b.productName.isNotEmpty &&
          b.origin.isNotEmpty &&
          b.harvestDate.isNotEmpty &&
          b.status.isNotEmpty &&
          b.currentLocation.isNotEmpty
        ).length;

        final traceabilityRate = batches.isEmpty
            ? 0.0
            : (traceableBatches / batches.length) * 100;

        final stats = [
          {
            'title': 'Total Batches',
            'value': batches.length.toString(),
            'icon': Icons.inventory_2,
            'color': Colors.blue,
          },
          {
            'title': 'Active Batches',
            'value': activeBatches.toString(),
            'icon': Icons.check_circle,
            'color': Colors.green,
          },
          {
            'title': 'Supply Partners',
            'value': uniqueOrigins.toString(),
            'icon': Icons.people,
            'color': Colors.orange,
          },
          {
            'title': 'Quality Score',
            'value': avgQualityScore.toStringAsFixed(1),
            'icon': Icons.star,
            'color': Colors.purple,
          },
          {
            'title': 'Traceability',
            'value': '${traceabilityRate.toStringAsFixed(1)}%',
            'icon': Icons.verified,
            'color': Colors.teal,
          },
        ];

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.6, // Increased to fix overflow
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: stats.length,
          itemBuilder: (context, index) {
            final stat = stats[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 2), // Added margin to prevent overflow
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14), // Reduced padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      stat['icon'] as IconData,
                      color: stat['color'] as Color,
                      size: 26, // Reduced size
                    ),
                    const SizedBox(height: 4), // Added spacing
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stat['value'] as String,
                          style: TextStyle(
                            fontSize: 20, // Reduced size
                            fontWeight: FontWeight.bold,
                            color: stat['color'] as Color,
                          ),
                        ),
                        Text(
                          stat['title'] as String,
                          style: TextStyle(
                            fontSize: 10, // Reduced size
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}


