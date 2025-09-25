import 'package:flutter/material.dart';
import '../../../design_system.dart';
import '../data/jobs_models.dart';
import 'job_address_form_screen.dart';

class JobDetailsFormScreen extends StatefulWidget {
  final String category;
  final ServiceItem service;

  const JobDetailsFormScreen({
    super.key,
    required this.category,
    required this.service,
  });

  @override
  State<JobDetailsFormScreen> createState() => _JobDetailsFormScreenState();
}

class _JobDetailsFormScreenState extends State<JobDetailsFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _detailsController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _priceController = TextEditingController();
  final _tagsController = TextEditingController();

  String _pricingType = 'per_day';
  DateTime? _startDate;
  DateTime? _endDate;
  List<String> _customTags = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
    _contactNameController.dispose();
    _contactPhoneController.dispose();
    _priceController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.backgroundLighter,
      appBar: AppBar(
        title: Text(
          'Job Details',
          style: DesignSystem.textTheme.headlineMedium,
        ),
        backgroundColor: DesignSystem.backgroundLight,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(DesignSystem.spacing16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildServiceInfo(),
                    const SizedBox(height: DesignSystem.spacing24),
                    _buildJobTitleField(),
                    const SizedBox(height: DesignSystem.spacing16),
                    _buildJobDetailsField(),
                    const SizedBox(height: DesignSystem.spacing16),
                    _buildPricingSection(),
                    const SizedBox(height: DesignSystem.spacing16),
                    _buildScheduleSection(),
                    const SizedBox(height: DesignSystem.spacing16),
                    _buildContactSection(),
                    const SizedBox(height: DesignSystem.spacing16),
                    _buildTagsSection(),
                  ],
                ),
              ),
            ),
            _buildContinueButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceInfo() {
    return Container(
      padding: const EdgeInsets.all(DesignSystem.spacing16),
      decoration: BoxDecoration(
        color: DesignSystem.backgroundLight,
        borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selected Service',
            style: DesignSystem.textTheme.titleMedium?.copyWith(
              color: DesignSystem.textSecondary,
            ),
          ),
          const SizedBox(height: DesignSystem.spacing8),
          Text(widget.service.name, style: DesignSystem.textTheme.titleLarge),
          const SizedBox(height: DesignSystem.spacing4),
          Text(
            widget.category,
            style: DesignSystem.textTheme.bodyMedium?.copyWith(
              color: DesignSystem.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobTitleField() {
    return TextFormField(
      controller: _titleController,
      style: DesignSystem.textTheme.bodyMedium,
      decoration: const InputDecoration(
        labelText: 'Job Title',
        hintText: 'Enter a descriptive title for your job',
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a job title';
        }
        return null;
      },
    );
  }

  Widget _buildJobDetailsField() {
    return TextFormField(
      controller: _detailsController,
      style: DesignSystem.textTheme.bodyMedium,
      maxLines: 4,
      decoration: const InputDecoration(
        labelText: 'Job Details',
        hintText: 'Describe what you need in detail',
        alignLabelWithHint: true,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter job details';
        }
        return null;
      },
    );
  }

  Widget _buildPricingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pricing', style: DesignSystem.textTheme.titleMedium),
        const SizedBox(height: DesignSystem.spacing12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _priceController,
                style: DesignSystem.textTheme.bodyMedium,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  hintText: '0',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: DesignSystem.spacing16),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _pricingType,
                style: DesignSystem.textTheme.bodyMedium,
                decoration: const InputDecoration(labelText: 'Pricing Type'),
                items: const [
                  DropdownMenuItem(value: 'per_day', child: Text('Per Day')),
                  DropdownMenuItem(value: 'per_hour', child: Text('Per Hour')),
                  DropdownMenuItem(
                    value: 'per_project',
                    child: Text('Per Project'),
                  ),
                  DropdownMenuItem(value: 'fixed', child: Text('Fixed Price')),
                ],
                onChanged: (value) {
                  setState(() {
                    _pricingType = value ?? 'per_day';
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScheduleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Schedule', style: DesignSystem.textTheme.titleMedium),
        const SizedBox(height: DesignSystem.spacing12),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: _selectStartDate,
                child: Container(
                  padding: const EdgeInsets.all(DesignSystem.spacing16),
                  decoration: BoxDecoration(
                    color: DesignSystem.backgroundLight,
                    borderRadius: BorderRadius.circular(
                      DesignSystem.radiusMedium,
                    ),
                    border: Border.all(
                      color: DesignSystem.textTertiary.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Start Date',
                        style: DesignSystem.textTheme.bodySmall?.copyWith(
                          color: DesignSystem.textSecondary,
                        ),
                      ),
                      const SizedBox(height: DesignSystem.spacing4),
                      Text(
                        _startDate != null
                            ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                            : 'Select start date',
                        style: DesignSystem.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: DesignSystem.spacing16),
            Expanded(
              child: InkWell(
                onTap: _selectEndDate,
                child: Container(
                  padding: const EdgeInsets.all(DesignSystem.spacing16),
                  decoration: BoxDecoration(
                    color: DesignSystem.backgroundLight,
                    borderRadius: BorderRadius.circular(
                      DesignSystem.radiusMedium,
                    ),
                    border: Border.all(
                      color: DesignSystem.textTertiary.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'End Date',
                        style: DesignSystem.textTheme.bodySmall?.copyWith(
                          color: DesignSystem.textSecondary,
                        ),
                      ),
                      const SizedBox(height: DesignSystem.spacing4),
                      Text(
                        _endDate != null
                            ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                            : 'Select end date',
                        style: DesignSystem.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Contact Information', style: DesignSystem.textTheme.titleMedium),
        const SizedBox(height: DesignSystem.spacing12),
        TextFormField(
          controller: _contactNameController,
          style: DesignSystem.textTheme.bodyMedium,
          decoration: const InputDecoration(
            labelText: 'Your Name',
            hintText: 'Enter your full name',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your name';
            }
            return null;
          },
        ),
        const SizedBox(height: DesignSystem.spacing16),
        TextFormField(
          controller: _contactPhoneController,
          style: DesignSystem.textTheme.bodyMedium,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Phone Number',
            hintText: 'Enter your phone number',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your phone number';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tags', style: DesignSystem.textTheme.titleMedium),
        const SizedBox(height: DesignSystem.spacing8),
        Text(
          'Service tags: ${widget.service.tags.join(', ')}',
          style: DesignSystem.textTheme.bodySmall?.copyWith(
            color: DesignSystem.textSecondary,
          ),
        ),
        const SizedBox(height: DesignSystem.spacing12),

        // Service tags display
        if (widget.service.tags.isNotEmpty) ...[
          Wrap(
            spacing: DesignSystem.spacing8,
            runSpacing: DesignSystem.spacing4,
            children: widget.service.tags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignSystem.spacing8,
                  vertical: DesignSystem.spacing4,
                ),
                decoration: BoxDecoration(
                  color: DesignSystem.backgroundLight,
                  borderRadius: BorderRadius.circular(DesignSystem.radiusSmall),
                  border: Border.all(
                    color: DesignSystem.textTertiary.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  tag,
                  style: DesignSystem.textTheme.bodySmall?.copyWith(
                    color: DesignSystem.textSecondary,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: DesignSystem.spacing12),
        ],

        // Custom tags input
        TextFormField(
          controller: _tagsController,
          style: DesignSystem.textTheme.bodyMedium,
          decoration: const InputDecoration(
            labelText: 'Add Custom Tags',
            hintText: 'Type tag and press Enter (comma separated)',
            suffixIcon: Icon(Icons.add),
          ),
          onChanged: (value) {
            setState(() {
              _customTags = value
                  .split(',')
                  .map((tag) => tag.trim())
                  .where((tag) => tag.isNotEmpty)
                  .toList();
            });
          },
        ),

        // Custom tags display
        if (_customTags.isNotEmpty) ...[
          const SizedBox(height: DesignSystem.spacing12),
          Text(
            'Custom Tags:',
            style: DesignSystem.textTheme.bodySmall?.copyWith(
              color: DesignSystem.textSecondary,
            ),
          ),
          const SizedBox(height: DesignSystem.spacing8),
          Wrap(
            spacing: DesignSystem.spacing8,
            runSpacing: DesignSystem.spacing4,
            children: _customTags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignSystem.spacing8,
                  vertical: DesignSystem.spacing4,
                ),
                decoration: BoxDecoration(
                  color: DesignSystem.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(DesignSystem.radiusSmall),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tag,
                      style: DesignSystem.textTheme.bodySmall?.copyWith(
                        color: DesignSystem.primaryColor,
                      ),
                    ),
                    const SizedBox(width: DesignSystem.spacing4),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _customTags.remove(tag);
                          _tagsController.text = _customTags.join(', ');
                        });
                      },
                      child: Icon(
                        Icons.close,
                        size: 14,
                        color: DesignSystem.primaryColor,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildContinueButton() {
    return Container(
      padding: const EdgeInsets.all(DesignSystem.spacing16),
      decoration: BoxDecoration(
        color: DesignSystem.backgroundLight,
        border: Border(
          top: BorderSide(
            color: DesignSystem.textTertiary.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _continueToAddress,
          style: ElevatedButton.styleFrom(
            backgroundColor: DesignSystem.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              vertical: DesignSystem.spacing16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  'Continue to Address',
                  style: DesignSystem.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _startDate = date;
      });
    }
  }

  Future<void> _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _endDate = date;
      });
    }
  }

  void _continueToAddress() {
    if (_formKey.currentState!.validate() &&
        _startDate != null &&
        _endDate != null) {
      final jobData = JobFormData(
        title: _titleController.text.trim(),
        details: _detailsController.text.trim(),
        price: double.parse(_priceController.text),
        pricingType: _pricingType,
        startDate: _startDate!,
        endDate: _endDate!,
        contactName: _contactNameController.text.trim(),
        contactPhone: _contactPhoneController.text.trim(),
        customTags: _customTags,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => JobAddressFormScreen(
            category: widget.category,
            service: widget.service,
            jobData: jobData,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: DesignSystem.errorColor,
        ),
      );
    }
  }
}

class JobFormData {
  final String title;
  final String details;
  final double price;
  final String pricingType;
  final DateTime startDate;
  final DateTime endDate;
  final String contactName;
  final String contactPhone;
  final List<String> customTags;

  JobFormData({
    required this.title,
    required this.details,
    required this.price,
    required this.pricingType,
    required this.startDate,
    required this.endDate,
    required this.contactName,
    required this.contactPhone,
    required this.customTags,
  });
}
