import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/quality_metrics_provider.dart';
import '../providers/batch_provider.dart';
import '../models/batch_model.dart';
import '../widgets/quality_metric_form_dialog.dart';
import '../widgets/certification_form_dialog.dart';

class QualityMetricsScreen extends StatefulWidget {
  const QualityMetricsScreen({super.key});

  @override
  State<QualityMetricsScreen> createState() => _QualityMetricsScreenState();
}

class _QualityMetricsScreenState extends State<QualityMetricsScreen> {
  String _batchFilter = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quality Metrics & Certifications'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/batches'),
        ),
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              labelColor: Colors.green,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.green,
              tabs: [
                Tab(text: 'Quality Metrics'),
                Tab(text: 'Certifications'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildQualityMetricsTab(),
                  _buildCertificationsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 3,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go('/dashboard');
              break;
            case 1:
              context.go('/batches');
              break;
            case 2:
              context.go('/analytics');
              break;
            case 3:
              context.go('/quality');
              break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Batches',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: Icon(Icons.verified_outlined),
            selectedIcon: Icon(Icons.verified),
            label: 'Quality',
          ),
        ],
      ),
    );
  }

  Widget _buildQualityMetricsTab() {
    return Consumer2<QualityMetricsProvider, BatchProvider>(
      builder: (context, metricsProvider, batchProvider, child) {
        if (metricsProvider.isLoadingMetrics) {
          return const Center(child: CircularProgressIndicator());
        }

        var metrics = metricsProvider.qualityMetrics;
        if (_batchFilter != 'all') {
          metrics = metrics
              .where((m) => m.batchId == _batchFilter)
              .toList();
        }

        return Column(
          children: [
            // Filter and Add Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _batchFilter,
                      decoration: const InputDecoration(
                        labelText: 'Filter by Batch',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: [
                        const DropdownMenuItem(value: 'all', child: Text('All Batches')),
                        ...batchProvider.batches.map((batch) {
                          return DropdownMenuItem(
                            value: batch.id,
                            child: Text(
                              '${batch.batchNumber} - ${batch.productName}',
                            ),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _batchFilter = value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => const QualityMetricFormDialog(),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Metric'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Metrics List
            Expanded(
              child: metrics.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.assessment_outlined,
                              size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No quality metrics yet'),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: metrics.length,
                      itemBuilder: (context, index) {
                        final metric = metrics[index];
                        Batch? linkedBatch;
                        if (metric.batchId != null && metric.batchId!.isNotEmpty) {
                          try {
                            linkedBatch = batchProvider.batches.firstWhere(
                              (b) => b.id == metric.batchId,
                            );
                          } catch (e) {
                            linkedBatch = null;
                          }
                        }

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.green.shade100,
                              child: const Icon(Icons.assessment, color: Colors.green),
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    metric.category,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (linkedBatch != null)
                                  Chip(
                                    label: Text(linkedBatch.batchNumber),
                                    backgroundColor: Colors.blue.shade50,
                                    labelStyle: const TextStyle(fontSize: 10),
                                  ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text('Score: ${metric.score}%'),
                                    const SizedBox(width: 16),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: metric.score >= 90
                                            ? Colors.green.shade100
                                            : Colors.orange.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        metric.status,
                                        style: TextStyle(
                                          color: metric.score >= 90
                                              ? Colors.green
                                              : Colors.orange,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (metric.notes != null && metric.notes!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      metric.notes!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) =>
                                          QualityMetricFormDialog(metric: metric),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Delete Metric'),
                                        content: const Text(
                                          'Are you sure you want to delete this quality metric?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: const Text(
                                              'Delete',
                                              style: TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirm == true && mounted) {
                                      await metricsProvider.deleteQualityMetric(
                                        metric.id,
                                      );
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Metric deleted'),
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
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCertificationsTab() {
    return Consumer<QualityMetricsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingCertifications) {
          return const Center(child: CircularProgressIndicator());
        }

        final certifications = provider.certifications;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const CertificationFormDialog(),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Certification'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ),
            Expanded(
              child: certifications.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.verified_user_outlined,
                              size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No certifications yet'),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: certifications.length,
                      itemBuilder: (context, index) {
                        final cert = certifications[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: cert.active
                                  ? Colors.green.shade100
                                  : Colors.grey.shade200,
                              child: Icon(
                                cert.active ? Icons.verified : Icons.pending,
                                color: cert.active ? Colors.green : Colors.grey,
                              ),
                            ),
                            title: Text(
                              cert.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: cert.active ? Colors.black : Colors.grey,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (cert.issuingBody != null)
                                  Text('Issued by: ${cert.issuingBody}'),
                                if (cert.expiryDate != null)
                                  Text(
                                    'Expires: ${DateTime.parse(cert.expiryDate!).toLocal().toString().split(' ')[0]}',
                                  ),
                                if (cert.certificateNumber != null)
                                  Text('Certificate #: ${cert.certificateNumber}'),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Switch(
                                  value: cert.active,
                                  onChanged: (value) async {
                                    await provider.updateCertification(
                                      cert.id,
                                      {'active': value},
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) =>
                                          CertificationFormDialog(certification: cert),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Delete Certification'),
                                        content: const Text(
                                          'Are you sure you want to delete this certification?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: const Text(
                                              'Delete',
                                              style: TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirm == true && mounted) {
                                      await provider.deleteCertification(cert.id);
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Certification deleted'),
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
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

