import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../design_system.dart';
import '../data/jobs_models.dart';
import '../data/jobs_api.dart';
import 'job_details_form_screen.dart';

class JobAddressFormScreen extends StatefulWidget {
  final String category;
  final ServiceItem service;
  final JobFormData jobData;

  const JobAddressFormScreen({
    super.key,
    required this.category,
    required this.service,
    required this.jobData,
  });

  @override
  State<JobAddressFormScreen> createState() => _JobAddressFormScreenState();
}

class _JobAddressFormScreenState extends State<JobAddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _buildingController = TextEditingController();
  final _areaController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();

  AddressData _addressData = AddressData();
  bool _isLoading = false;
  bool _locationPermissionGranted = false;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  @override
  void dispose() {
    _buildingController.dispose();
    _areaController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _checkLocationPermission() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requestPermission = await Geolocator.requestPermission();
        setState(() {
          _locationPermissionGranted =
              requestPermission == LocationPermission.whileInUse ||
              requestPermission == LocationPermission.always;
        });
      } else {
        setState(() {
          _locationPermissionGranted =
              permission == LocationPermission.whileInUse ||
              permission == LocationPermission.always;
        });
      }
    } catch (e) {
      setState(() {
        _locationError = e.toString();
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    if (!_locationPermissionGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location permission is required'),
          backgroundColor: DesignSystem.errorColor,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _locationError = null;
    });

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _addressData = _addressData.copyWith(
          lat: position.latitude,
          lng: position.longitude,
        );
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location obtained successfully'),
          backgroundColor: DesignSystem.success,
        ),
      );
    } catch (e) {
      setState(() {
        _locationError = e.toString();
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to get location: ${e.toString()}'),
          backgroundColor: DesignSystem.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.backgroundLighter,
      appBar: AppBar(
        title: Text(
          'Job Location',
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
                    _buildLocationPermissionCard(),
                    const SizedBox(height: DesignSystem.spacing24),
                    _buildAddressFields(),
                    const SizedBox(height: DesignSystem.spacing24),
                    _buildLocationInfo(),
                  ],
                ),
              ),
            ),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationPermissionCard() {
    return Card(
      color: _locationPermissionGranted
          ? DesignSystem.success.withOpacity(0.1)
          : DesignSystem.warning.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _locationPermissionGranted
                      ? Icons.location_on
                      : Icons.location_off,
                  color: _locationPermissionGranted
                      ? DesignSystem.success
                      : DesignSystem.warning,
                ),
                const SizedBox(width: DesignSystem.spacing12),
                Expanded(
                  child: Text(
                    _locationPermissionGranted
                        ? 'Location permission granted'
                        : 'Location permission required',
                    style: DesignSystem.textTheme.titleMedium?.copyWith(
                      color: _locationPermissionGranted
                          ? DesignSystem.success
                          : DesignSystem.warning,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: DesignSystem.spacing8),
            Text(
              _locationPermissionGranted
                  ? 'We can automatically get your current location'
                  : 'Please grant location permission to automatically get your current location',
              style: DesignSystem.textTheme.bodySmall?.copyWith(
                color: DesignSystem.textSecondary,
              ),
            ),
            if (!_locationPermissionGranted) ...[
              const SizedBox(height: DesignSystem.spacing12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _checkLocationPermission,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignSystem.warning,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Grant Permission'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAddressFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Address Details', style: DesignSystem.textTheme.titleMedium),
        const SizedBox(height: DesignSystem.spacing8),
        Text(
          'Fill in your address details below',
          style: DesignSystem.textTheme.bodySmall?.copyWith(
            color: DesignSystem.textSecondary,
          ),
        ),
        const SizedBox(height: DesignSystem.spacing16),
        TextFormField(
          controller: _buildingController,
          style: DesignSystem.textTheme.bodyMedium,
          decoration: const InputDecoration(
            labelText: 'Building Number/Name',
            hintText: 'e.g., 123 Main St, Apt 4B',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter building details';
            }
            return null;
          },
          onChanged: (value) {
            setState(() {
              _addressData = _addressData.copyWith(
                buildingNumber: value.trim(),
              );
            });
          },
        ),
        const SizedBox(height: DesignSystem.spacing16),
        TextFormField(
          controller: _areaController,
          style: DesignSystem.textTheme.bodyMedium,
          decoration: const InputDecoration(
            labelText: 'Area/Locality',
            hintText: 'e.g., Downtown, Central Park',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter area/locality';
            }
            return null;
          },
          onChanged: (value) {
            setState(() {
              _addressData = _addressData.copyWith(area: value.trim());
            });
          },
        ),
        const SizedBox(height: DesignSystem.spacing16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _cityController,
                style: DesignSystem.textTheme.bodyMedium,
                decoration: const InputDecoration(
                  labelText: 'City',
                  hintText: 'e.g., New York',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter city';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _addressData = _addressData.copyWith(city: value.trim());
                  });
                },
              ),
            ),
            const SizedBox(width: DesignSystem.spacing16),
            Expanded(
              child: TextFormField(
                controller: _stateController,
                style: DesignSystem.textTheme.bodyMedium,
                decoration: const InputDecoration(
                  labelText: 'State',
                  hintText: 'e.g., NY',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter state';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _addressData = _addressData.copyWith(state: value.trim());
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: DesignSystem.spacing16),
        TextFormField(
          controller: _countryController,
          style: DesignSystem.textTheme.bodyMedium,
          decoration: const InputDecoration(
            labelText: 'Country',
            hintText: 'e.g., United States',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter country';
            }
            return null;
          },
          onChanged: (value) {
            setState(() {
              _addressData = _addressData.copyWith(country: value.trim());
            });
          },
        ),
      ],
    );
  }

  Widget _buildLocationInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Location', style: DesignSystem.textTheme.titleMedium),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _getCurrentLocation,
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.my_location),
              label: Text(_isLoading ? 'Getting...' : 'Get Current Location'),
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignSystem.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: DesignSystem.spacing12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(DesignSystem.spacing16),
          decoration: BoxDecoration(
            color: DesignSystem.backgroundLight,
            borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
            border: Border.all(
              color: DesignSystem.textTertiary.withOpacity(0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Full Address',
                style: DesignSystem.textTheme.bodySmall?.copyWith(
                  color: DesignSystem.textSecondary,
                ),
              ),
              const SizedBox(height: DesignSystem.spacing4),
              Text(
                _addressData.fullAddress.isNotEmpty
                    ? _addressData.fullAddress
                    : 'Address will appear here',
                style: DesignSystem.textTheme.bodyMedium,
              ),
              if (_addressData.lat != 0.0 && _addressData.lng != 0.0) ...[
                const SizedBox(height: DesignSystem.spacing8),
                Text(
                  'Coordinates: ${_addressData.lat.toStringAsFixed(6)}, ${_addressData.lng.toStringAsFixed(6)}',
                  style: DesignSystem.textTheme.bodySmall?.copyWith(
                    color: DesignSystem.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (_locationError != null) ...[
          const SizedBox(height: DesignSystem.spacing12),
          Container(
            padding: const EdgeInsets.all(DesignSystem.spacing12),
            decoration: BoxDecoration(
              color: DesignSystem.errorColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(DesignSystem.radiusSmall),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: DesignSystem.errorColor,
                  size: 20,
                ),
                const SizedBox(width: DesignSystem.spacing8),
                Expanded(
                  child: Text(
                    _locationError!,
                    style: DesignSystem.textTheme.bodySmall?.copyWith(
                      color: DesignSystem.errorColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSubmitButton() {
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
          onPressed: _isLoading ? null : _submitJob,
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
                  'Post Job',
                  style: DesignSystem.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> _submitJob() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final allTags = [...widget.service.tags, ...widget.jobData.customTags];

      final jobRequest = JobPostRequest(
        title: widget.jobData.title,
        category: widget.category,
        service: widget.service.name,
        serviceId: widget.service.id,
        details: widget.jobData.details,
        tags: allTags,
        address: _addressData.fullAddress,
        lat: _addressData.lat,
        lng: _addressData.lng,
        pricingType: widget.jobData.pricingType,
        price: widget.jobData.price,
        contactName: widget.jobData.contactName,
        contactPhone: widget.jobData.contactPhone,
        startDate: widget.jobData.startDate.toIso8601String(),
        endDate: widget.jobData.endDate.toIso8601String(),
        daysOfWeek: [], // You can implement day selection if needed
        specificDates: [widget.jobData.startDate.toIso8601String()],
        scheduleType: 'date_range',
      );

      final apiClient = JobsApiClient();
      final response = await apiClient.postJob(jobRequest);

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Job posted successfully!'),
            backgroundColor: DesignSystem.success,
          ),
        );

        // Navigate back to jobs list or home
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        throw Exception('Failed to post job: ${response.statusMessage}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error posting job: ${e.toString()}'),
          backgroundColor: DesignSystem.errorColor,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
