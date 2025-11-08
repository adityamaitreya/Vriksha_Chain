import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/quality_metrics_provider.dart';
import '../models/quality_metric_model.dart';

class CertificationFormDialog extends StatefulWidget {
  final Certification? certification;

  const CertificationFormDialog({
    super.key,
    this.certification,
  });

  @override
  State<CertificationFormDialog> createState() => _CertificationFormDialogState();
}

class _CertificationFormDialogState extends State<CertificationFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _issuingBodyController = TextEditingController();
  final _certificateNumberController = TextEditingController();
  
  DateTime? _issuedDate;
  DateTime? _expiryDate;
  bool _active = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.certification != null) {
      _nameController.text = widget.certification!.name;
      _issuingBodyController.text = widget.certification?.issuingBody ?? '';
      _certificateNumberController.text =
          widget.certification?.certificateNumber ?? '';
      _active = widget.certification!.active;
      if (widget.certification!.issuedDate != null) {
        _issuedDate = DateTime.parse(widget.certification!.issuedDate!);
      }
      if (widget.certification!.expiryDate != null) {
        _expiryDate = DateTime.parse(widget.certification!.expiryDate!);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _issuingBodyController.dispose();
    _certificateNumberController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isIssuedDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isIssuedDate
          ? (_issuedDate ?? DateTime.now())
          : (_expiryDate ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isIssuedDate) {
          _issuedDate = picked;
        } else {
          _expiryDate = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final certification = Certification(
      id: widget.certification?.id ?? '',
      name: _nameController.text.trim(),
      active: _active,
      issuedDate: _issuedDate != null
          ? DateFormat('yyyy-MM-dd').format(_issuedDate!)
          : null,
      expiryDate: _expiryDate != null
          ? DateFormat('yyyy-MM-dd').format(_expiryDate!)
          : null,
      issuingBody: _issuingBodyController.text.trim().isEmpty
          ? null
          : _issuingBodyController.text.trim(),
      certificateNumber: _certificateNumberController.text.trim().isEmpty
          ? null
          : _certificateNumberController.text.trim(),
      lastUpdated: DateTime.now().toIso8601String(),
    );

    final provider = Provider.of<QualityMetricsProvider>(context, listen: false);

    if (widget.certification != null) {
      // Update existing certification
      final success = await provider.updateCertification(
        widget.certification!.id,
        {
          'name': certification.name,
          'active': certification.active,
          'issuedDate': certification.issuedDate,
          'expiryDate': certification.expiryDate,
          'issuingBody': certification.issuingBody,
          'certificateNumber': certification.certificateNumber,
        },
      );

      setState(() => _isLoading = false);

      if (success && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Certification updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      // Create new certification
      final certId = await provider.createCertification(certification);

      setState(() => _isLoading = false);

      if (certId != null && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Certification created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }

    if (mounted && _isLoading) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save certification. Please try again.'),
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
                    const Icon(Icons.verified_user, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.certification != null
                            ? 'Edit Certification'
                            : 'Add Certification',
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
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Certification Name *',
                          hintText: 'e.g., USDA Organic, Fair Trade',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.verified_user),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter certification name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _issuingBodyController,
                        decoration: const InputDecoration(
                          labelText: 'Issuing Body (Optional)',
                          hintText: 'e.g., Control Union, IMO',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.business),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _certificateNumberController,
                        decoration: const InputDecoration(
                          labelText: 'Certificate Number (Optional)',
                          hintText: 'e.g., CERT-12345',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.confirmation_number),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectDate(context, true),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Issued Date (Optional)',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.calendar_today),
                                ),
                                child: Text(
                                  _issuedDate != null
                                      ? DateFormat('yyyy-MM-dd').format(_issuedDate!)
                                      : 'Select date',
                                  style: TextStyle(
                                    color: _issuedDate != null
                                        ? Colors.black
                                        : Colors.grey[600],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectDate(context, false),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Expiry Date (Optional)',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.event_busy),
                                ),
                                child: Text(
                                  _expiryDate != null
                                      ? DateFormat('yyyy-MM-dd').format(_expiryDate!)
                                      : 'Select date',
                                  style: TextStyle(
                                    color: _expiryDate != null
                                        ? Colors.black
                                        : Colors.grey[600],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Switch(
                            value: _active,
                            onChanged: (value) {
                              setState(() => _active = value);
                            },
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text('Active Certification'),
                          ),
                        ],
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
                          : Text(widget.certification != null ? 'Update' : 'Add'),
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


