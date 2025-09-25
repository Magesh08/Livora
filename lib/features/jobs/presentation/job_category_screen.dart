import 'package:flutter/material.dart';
import '../../../design_system.dart';
import '../data/jobs_api.dart';
import '../data/jobs_models.dart';
import 'job_service_selection_screen.dart';

class JobCategoryScreen extends StatefulWidget {
  const JobCategoryScreen({super.key});

  @override
  State<JobCategoryScreen> createState() => _JobCategoryScreenState();
}

class _JobCategoryScreenState extends State<JobCategoryScreen> {
  final JobsApiClient _apiClient = JobsApiClient();
  List<ServiceItem> _services = [];
  List<String> _categories = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final response = await _apiClient.fetchServices();
      final servicesResponse = ServicesResponse.fromJson(response.data);

      setState(() {
        _services = servicesResponse.records;
        _categories = _services.map((s) => s.category).toSet().toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Select Category',
          style: DesignSystem.textTheme.headlineMedium,
        ),
        backgroundColor: DesignSystem.backgroundLight,
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: DesignSystem.primaryColor),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: DesignSystem.errorColor),
            const SizedBox(height: DesignSystem.spacing16),
            Text(
              'Error loading categories',
              style: DesignSystem.textTheme.headlineSmall,
            ),
            const SizedBox(height: DesignSystem.spacing8),
            Text(
              _error!,
              style: DesignSystem.textTheme.bodyMedium?.copyWith(
                color: DesignSystem.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DesignSystem.spacing24),
            ElevatedButton(
              onPressed: _loadServices,
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignSystem.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(DesignSystem.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose a category for your job',
            style: DesignSystem.textTheme.headlineSmall,
          ),
          const SizedBox(height: DesignSystem.spacing8),
          Text(
            'Select the category that best matches your job requirements',
            style: DesignSystem.textTheme.bodyMedium?.copyWith(
              color: DesignSystem.textSecondary,
            ),
          ),
          const SizedBox(height: DesignSystem.spacing24),
          Expanded(
            child: ListView.builder(
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final categoryServices = _services
                    .where((s) => s.category == category)
                    .toList();

                return _buildCategoryCard(category, categoryServices);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String category, List<ServiceItem> services) {
    return Card(
      margin: const EdgeInsets.only(bottom: DesignSystem.spacing12),
      color: DesignSystem.backgroundLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
      ),
      child: InkWell(
        onTap: () => _navigateToServiceSelection(category, services),
        borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(DesignSystem.spacing16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: DesignSystem.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(DesignSystem.radiusSmall),
                ),
                child: Icon(
                  _getCategoryIcon(category),
                  color: DesignSystem.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: DesignSystem.spacing16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(category, style: DesignSystem.textTheme.titleLarge),
                    const SizedBox(height: DesignSystem.spacing4),
                    Text(
                      '${services.length} services available',
                      style: DesignSystem.textTheme.bodySmall?.copyWith(
                        color: DesignSystem.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: DesignSystem.textSecondary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'education & learning':
        return Icons.school;
      case 'family care':
        return Icons.family_restroom;
      case 'family & lifestyle':
        return Icons.home;
      case 'health & wellness':
        return Icons.health_and_safety;
      case 'technology':
        return Icons.computer;
      case 'business':
        return Icons.business;
      default:
        return Icons.category;
    }
  }

  void _navigateToServiceSelection(
    String category,
    List<ServiceItem> services,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            JobServiceSelectionScreen(category: category, services: services),
      ),
    );
  }
}
