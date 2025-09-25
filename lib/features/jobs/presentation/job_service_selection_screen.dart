import 'package:flutter/material.dart';
import '../../../design_system.dart';
import '../data/jobs_models.dart';
import 'job_details_form_screen.dart';

class JobServiceSelectionScreen extends StatefulWidget {
  final String category;
  final List<ServiceItem> services;

  const JobServiceSelectionScreen({
    super.key,
    required this.category,
    required this.services,
  });

  @override
  State<JobServiceSelectionScreen> createState() =>
      _JobServiceSelectionScreenState();
}

class _JobServiceSelectionScreenState extends State<JobServiceSelectionScreen> {
  ServiceItem? _selectedService;
  final TextEditingController _searchController = TextEditingController();
  List<ServiceItem> _filteredServices = [];

  @override
  void initState() {
    super.initState();
    _filteredServices = widget.services;
    _searchController.addListener(_filterServices);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterServices() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredServices = widget.services.where((service) {
        return service.name.toLowerCase().contains(query) ||
            service.tags.any((tag) => tag.toLowerCase().contains(query));
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.backgroundLighter,
      appBar: AppBar(
        title: Text(
          'Select Service',
          style: DesignSystem.textTheme.headlineMedium,
        ),
        backgroundColor: DesignSystem.backgroundLight,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchBar(),
          Expanded(child: _buildServicesList()),
          _buildContinueButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(DesignSystem.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.category, style: DesignSystem.textTheme.headlineSmall),
          const SizedBox(height: DesignSystem.spacing8),
          Text(
            'Choose the specific service you need',
            style: DesignSystem.textTheme.bodyMedium?.copyWith(
              color: DesignSystem.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DesignSystem.spacing16),
      child: TextField(
        controller: _searchController,
        style: DesignSystem.textTheme.bodyMedium,
        decoration: InputDecoration(
          hintText: 'Search services...',
          prefixIcon: const Icon(
            Icons.search,
            color: DesignSystem.textSecondary,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.clear,
                    color: DesignSystem.textSecondary,
                  ),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildServicesList() {
    if (_filteredServices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: DesignSystem.textSecondary),
            const SizedBox(height: DesignSystem.spacing16),
            Text('No services found', style: DesignSystem.textTheme.titleLarge),
            const SizedBox(height: DesignSystem.spacing8),
            Text(
              'Try adjusting your search terms',
              style: DesignSystem.textTheme.bodyMedium?.copyWith(
                color: DesignSystem.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(DesignSystem.spacing16),
      itemCount: _filteredServices.length,
      itemBuilder: (context, index) {
        final service = _filteredServices[index];
        final isSelected = _selectedService?.id == service.id;

        return _buildServiceCard(service, isSelected);
      },
    );
  }

  Widget _buildServiceCard(ServiceItem service, bool isSelected) {
    return Card(
      margin: const EdgeInsets.only(bottom: DesignSystem.spacing12),
      color: isSelected
          ? DesignSystem.primaryColor.withOpacity(0.1)
          : DesignSystem.backgroundLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
        side: BorderSide(
          color: isSelected ? DesignSystem.primaryColor : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () => _selectService(service),
        borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(DesignSystem.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      service.name,
                      style: DesignSystem.textTheme.titleLarge?.copyWith(
                        color: isSelected
                            ? DesignSystem.primaryColor
                            : DesignSystem.textPrimary,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: DesignSystem.primaryColor,
                      size: 24,
                    ),
                ],
              ),
              if (service.tags.isNotEmpty) ...[
                const SizedBox(height: DesignSystem.spacing8),
                Wrap(
                  spacing: DesignSystem.spacing8,
                  runSpacing: DesignSystem.spacing4,
                  children: service.tags.take(3).map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: DesignSystem.spacing8,
                        vertical: DesignSystem.spacing4,
                      ),
                      decoration: BoxDecoration(
                        color: DesignSystem.backgroundLight,
                        borderRadius: BorderRadius.circular(
                          DesignSystem.radiusSmall,
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
              ],
            ],
          ),
        ),
      ),
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
          onPressed: _selectedService != null ? _continueToJobDetails : null,
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
          child: Text(
            'Continue',
            style: DesignSystem.textTheme.titleMedium?.copyWith(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void _selectService(ServiceItem service) {
    setState(() {
      _selectedService = service;
    });
  }

  void _continueToJobDetails() {
    if (_selectedService != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => JobDetailsFormScreen(
            category: widget.category,
            service: _selectedService!,
          ),
        ),
      );
    }
  }
}
