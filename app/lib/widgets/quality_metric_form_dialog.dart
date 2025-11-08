import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quality_metrics_provider.dart';
import '../providers/batch_provider.dart';
import '../models/batch_model.dart';
import '../models/quality_metric_model.dart';

class QualityMetricFormDialog extends StatefulWidget {
  final QualityMetric? metric;

  const QualityMetricFormDialog({
    super.key,
    this.metric,
  });

  @override
  State<QualityMetricFormDialog> createState() => _QualityMetricFormDialogState();
}

class _QualityMetricFormDialogState extends State<QualityMetricFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _categoryController = TextEditingController();
  final _notesController = TextEditingController();
  
  String? _batchId;
  String _status = 'Passed';
  int _score = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.metric != null) {
      _categoryController.text = widget.metric!.category;
      _notesController.text = widget.metric?.notes ?? '';
      _batchId = widget.metric!.batchId;
      _status = widget.metric!.status;
      _score = widget.metric!.score;
    }
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final batchProvider = Provider.of<BatchProvider>(context, listen: false);
    Batch? selectedBatch;
    if (_batchId != null && _batchId!.isNotEmpty) {
      try {
        selectedBatch = batchProvider.batches.firstWhere(
          (b) => b.id == _batchId,
        );
      } catch (e) {
        selectedBatch = null;
      }
    }

    final metric = QualityMetric(
      id: widget.metric?.id ?? '',
      batchId: _batchId?.isEmpty ?? true ? null : _batchId,
      productName: selectedBatch?.productName,
      category: _categoryController.text.trim(),
      score: _score,
      status: _status,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      lastUpdated: DateTime.now().toIso8601String(),
    );

    final provider = Provider.of<QualityMetricsProvider>(context, listen: false);

    if (widget.metric != null) {
      // Update existing metric
      final success = await provider.updateQualityMetric(
        widget.metric!.id,
        {
          'batchId': metric.batchId,
          'productName': metric.productName,
          'category': metric.category,
          'score': metric.score,
          'status': metric.status,
          'notes': metric.notes,
        },
      );

      setState(() => _isLoading = false);

      if (success && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Quality metric updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      // Create new metric
      final metricId = await provider.createQualityMetric(metric);

      setState(() => _isLoading = false);

      if (metricId != null && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Quality metric created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }

    if (mounted && _isLoading) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save metric. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Icon(Icons.assessment, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.metric != null
                            ? 'Edit Quality Metric'
                            : 'Add Quality Metric',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Consumer<BatchProvider>(
                        builder: (context, batchProvider, child) {
                          return DropdownButtonFormField<String>(
                            value: _batchId ?? '',
                            decoration: const InputDecoration(
                              labelText: 'Link to Batch (Optional)',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.inventory_2),
                            ),
                            items: [
                              const DropdownMenuItem(
                                value: '',
                                child: Text('None (Global Metric)'),
                              ),
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
                              setState(() {
                                _batchId = value;
                              });
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _categoryController,
                        decoration: const InputDecoration(
                          labelText: 'Category *',
                          hintText: 'e.g., Organic Certification, Purity Analysis',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.category),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter category';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: _score.toString(),
                              decoration: const InputDecoration(
                                labelText: 'Score (0-100) *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.star),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                final score = int.tryParse(value) ?? 0;
                                setState(() {
                                  _score = score.clamp(0, 100);
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _status,
                              decoration: const InputDecoration(
                                labelText: 'Status *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.info),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'Certified',
                                  child: Text('Certified'),
                                ),
                                DropdownMenuItem(
                                  value: 'Passed',
                                  child: Text('Passed'),
                                ),
                                DropdownMenuItem(
                                  value: 'Clear',
                                  child: Text('Clear'),
                                ),
                                DropdownMenuItem(
                                  value: 'Monitoring',
                                  child: Text('Monitoring'),
                                ),
                                DropdownMenuItem(
                                  value: 'Failed',
                                  child: Text('Failed'),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _status = value);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Notes (Optional)',
                          hintText: 'Additional notes about this metric...',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.note),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(widget.metric != null ? 'Update' : 'Add'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

