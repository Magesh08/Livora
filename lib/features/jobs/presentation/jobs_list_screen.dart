import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'dart:math';
import '../../jobs/data/jobs_api.dart';
import '../../jobs/data/jobs_models.dart';
import '../../../design_system.dart';
import '../../jobs/data/location_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:collection/collection.dart'; // <-- ADD THIS IMPORT

class JobsListScreen extends ConsumerStatefulWidget {
  const JobsListScreen({super.key});

  @override
  ConsumerState<JobsListScreen> createState() => _JobsListScreenState();
}

class _JobsListScreenState extends ConsumerState<JobsListScreen> {
  final JobsApiClient _api = JobsApiClient();
  final TextEditingController _searchCtrl = TextEditingController();
  String? _selectedCategory;
  String? _selectedService; // subcategory (service)
  int _page = 1;
  final int _limit = 20;
  bool _loading = false;
  bool _hasMore = true;
  List<JobRecord> _jobs = [];
  List<ServiceItem> _services = [];
  late final ScrollController _scrollController;
  late final Box<String> _watchBox;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _searchCtrl.addListener(_onSearchChanged); // <-- Add this line
    _initHive().then((_) => _loadInitial());
  }

  Future<void> _initHive() async {
    await Hive.initFlutter();
    _watchBox = await Hive.openBox<String>('watchlist');
  }

  Future<void> _loadInitial() async {
    await Future.wait([_fetchServices(), _fetchJobs(reset: true)]);
  }

  Future<void> _fetchServices() async {
    try {
      final res = await _api.fetchServices(page: 1, limit: 100);
      final data = (res.data['records'] as List?) ?? [];
      setState(() {
        _services = data.map((e) => ServiceItem.fromJson(e)).toList();
      });
      final categories =
          _services.map((e) => e.category).toSet().toList()..sort();
      print('Available categories: $categories');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to load services: ${e.toString()}',
                  style: DesignSystem.textTheme.bodyMedium?.copyWith(
                    color: DesignSystem.textPrimary,
                  ))),
        );
      }
    }
  }

  Future<void> _fetchJobs({bool reset = false}) async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      final locationState = ref.read(locationProvider);

      String? searchParam;
      String? locationParam;
      String? serviceParam;

      // If location is set, use location parameter for address/location text search
      if (locationState.locationName != 'Select location') {
        locationParam = locationState.locationName;
      }

      // Use service parameter for service name
      if (_selectedService != null) {
        serviceParam = _selectedService;
      }

      // Use search for title/details/service/tags if location is not set
      if (locationParam == null && _searchCtrl.text.trim().isNotEmpty) {
        searchParam = _searchCtrl.text.trim();
      }

      final res = await _api.fetchJobs(
        category: _selectedCategory,
        search: searchParam,
        service: serviceParam,
        location: locationParam,
        lat: locationState.applyFilter ? locationState.lat : null,
        lng: locationState.applyFilter ? locationState.lng : null,
        radiusKm: locationState.applyFilter ? locationState.radiusKm : null,
        page: _page,
        limit: _limit,
      );

      final items = ((res.data['records']) as List?)
              ?.map((e) => JobRecord.fromJson(e))
              .toList() ??
          [];
      setState(() {
        _jobs = reset ? items : [..._jobs, ...items];
        _hasMore = items.length >= _limit;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to load jobs: ${e.message}',
                style: DesignSystem.textTheme.bodyMedium?.copyWith(
                  color: DesignSystem.textPrimary,
                ))),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onScroll() {
    if (!_hasMore || _loading) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _page += 1;
      _fetchJobs();
    }
  }

  void _clearLocation() async {
    ref.read(locationProvider.notifier).clearLocation();
    await _fetchJobs(reset: true);
  }

  void _clearAllFilters() async {
    setState(() {
      _selectedCategory = null;
      _selectedService = null;
      _searchCtrl.clear();
    });
    ref.read(locationProvider.notifier).clearLocation();
    _page = 1;
    await _fetchJobs(reset: true);
  }

  Widget _buildFilterChip({
    required String label,
    required VoidCallback onRemove,
  }) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: DesignSystem.spacing8, vertical: DesignSystem.spacing4),
      decoration: BoxDecoration(
        color: DesignSystem.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(DesignSystem.radiusSmall),
        border:
            Border.all(color: DesignSystem.primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: DesignSystem.textTheme.bodySmall?.copyWith(
              color: DesignSystem.primaryColor,
            ),
          ),
          const SizedBox(width: DesignSystem.spacing4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close,
              size: 14,
              color: DesignSystem.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  double _calculateDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    double dLat = _degreesToRadians(lat2 - lat1);
    double dLng = _degreesToRadians(lng2 - lng1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLng / 2) *
            sin(dLng / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  void _onSearchChanged() {
    if (_searchCtrl.text.length > 3) {
      _page = 1;
      _fetchJobs(reset: true);
    }
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearchChanged); // <-- Add this
    _searchCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(locationProvider, (previous, next) {
      if (previous != next) {
        _page = 1;
        _fetchJobs(reset: true);
      }
    });

    final user = FirebaseAuth.instance.currentUser;

    final categories =
        _services.map((e) => e.category).toSet().toList()..sort();
    final filteredServices = _selectedCategory == null
        ? _services
        : _services.where((s) => s.category == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: DesignSystem.backgroundDark,
      body: SafeArea(
        child: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.all(DesignSystem.spacing20),
          children: [

              // --- NEW HEADER ---
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text(
                //   "Livora",
                //   style: DesignSystem.textTheme.headlineMedium?.copyWith(
                //     fontSize: 20,
                //     fontWeight: FontWeight.w700,
                //     color: DesignSystem.textPrimary,
                //   ),
                // ),
                if (user != null && user.displayName != null)
                  Text(
                    "Welcome back, ${user.displayName!}",
                    style: DesignSystem.textTheme.bodySmall?.copyWith(
                      color: DesignSystem.textPrimary,
                      fontWeight: FontWeight.w400,
                      fontSize: 13,
                    ),
                  ),
                const SizedBox(height: 8),
              ],
            ),
            // --- END HEADER ---


            // --- ADD THIS AFTER THE SEARCH BAR ---
            // Search Bar
            TextField(
              controller: _searchCtrl,
              style: TextStyle(color: DesignSystem.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search for a service...',
                prefixIcon: Icon(Icons.search, color: DesignSystem.textSecondary),
                filled: true,
                fillColor: DesignSystem.backgroundLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
                  borderSide: BorderSide.none,
                ),
                hintStyle: TextStyle(color: DesignSystem.textSecondary),
              ),
              onSubmitted: (_) async {
                setState(() {
                  _selectedService = null;
                });
                _page = 1;
                await _fetchJobs(reset: true);
              },
            ),
            const SizedBox(height: DesignSystem.spacing16),

          
            // Categories
            Text(
              'Categories',
              style: DesignSystem.textTheme.titleMedium?.copyWith(
                color: DesignSystem.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: DesignSystem.spacing12),
            SizedBox(
  height: 115, // Increase height to accommodate image and text
  child: ListView.separated(
    scrollDirection: Axis.horizontal,
    itemCount: categories.length,
    separatorBuilder: (_, __) =>
        const SizedBox(width: DesignSystem.spacing12),
    itemBuilder: (context, index) {
      final cat = categories[index];
      final selected = cat == _selectedCategory;

      // Find a service item that belongs to this category to get the category_img
      final serviceWithCategoryImg =
          _services.firstWhereOrNull((s) => s.category == cat && s.category_img != null);
      final String? currentCategoryImg = serviceWithCategoryImg?.category_img;

      return GestureDetector(
        onTap: () {
          setState(() {
            _selectedCategory = selected ? null : cat;
            _selectedService = null;
          });
          _page = 1;
          _fetchJobs(reset: true);
        },
        child: Container(
          width: 100,
          padding: const EdgeInsets.symmetric(
              vertical: DesignSystem.spacing10,
              horizontal: DesignSystem.spacing8),
          decoration: BoxDecoration(
            color: selected
                ? const Color.fromRGBO(62, 142, 126, 1)
                : Color(  0xFFdbdbdb),
            borderRadius:
                BorderRadius.circular(DesignSystem.radiusLarge),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: selected
                  ? DesignSystem.primaryColor
                  : DesignSystem.backgroundLighter,
              width: 1.2,
            ),
          ),
          child: Column( // Change to Column to stack image and text
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (currentCategoryImg != null && currentCategoryImg.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: DesignSystem.spacing4),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(DesignSystem.radiusSmall),
                    child: Image.network(
                      currentCategoryImg,
                      height: 50, // Adjust size as needed
                      width: 60,  // Adjust size as needed
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                          Icons.category, // Fallback icon
                          color: DesignSystem.textSecondary, size: 36),
                    ),
                  ),
                ),
              Text(
                cat,
                style: DesignSystem.textTheme.bodySmall?.copyWith(
                  color: selected
                      ? Colors.white
                      : DesignSystem.backgroundDark,
                  fontWeight:
                      selected ? FontWeight.bold : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    },
  ),
),
            const SizedBox(height: DesignSystem.spacing20),
            // Services
            Text(
              'Services',
              style: DesignSystem.textTheme.titleMedium?.copyWith(
                color: DesignSystem.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: DesignSystem.spacing12),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: filteredServices.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: DesignSystem.spacing12),
                itemBuilder: (context, index) {
                  final svc = filteredServices[index];
                  final selected = svc.name == _selectedService;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedService = selected ? null : svc.name;
                        _searchCtrl.clear();
                      });
                      _page = 1;
                      _fetchJobs(reset: true);
                    },
                    child: Container(
                      width: 130,
                      padding: const EdgeInsets.symmetric(
                          vertical: DesignSystem.spacing10,
                          horizontal: DesignSystem.spacing8),
                      decoration: BoxDecoration(
                        color: selected
                            ? DesignSystem.primaryColor
                            :  Color(  0xFFdbdbdb),
                        borderRadius:
                            BorderRadius.circular(DesignSystem.radiusLarge),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(
                          color: selected
                              ? DesignSystem.primaryColor
                              : DesignSystem.backgroundLighter,
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (svc.image != null && svc.image.isNotEmpty)
                            Padding(
                              padding:
                                  const EdgeInsets.only(right: DesignSystem.spacing8),
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(DesignSystem.radiusSmall),
                                child: Image.network(
                                  svc.image,
                                  height: 28,
                                  width: 28,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                      Icons.miscellaneous_services,
                                      color: DesignSystem.textSecondary),
                                ),
                              ),
                            ),
                          Flexible(
                            child: Text(
                              svc.name,
                              style: DesignSystem.textTheme.bodySmall?.copyWith(
                                color: selected
                                    ? Colors.white
                                    : DesignSystem.backgroundDark,
                                fontWeight: selected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: DesignSystem.spacing20),
            // Filter chips row
            if (_selectedCategory != null || _selectedService != null)
              Padding(
                padding: const EdgeInsets.only(
                    bottom: DesignSystem.spacing10, top: DesignSystem.spacing4),
                child: Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: DesignSystem.spacing8,
                        runSpacing: DesignSystem.spacing4,
                        children: [
                          if (_selectedCategory != null)
                            _buildFilterChip(
                              label: _selectedCategory!,
                              onRemove: () {
                                setState(() {
                                  _selectedCategory = null;
                                  _selectedService = null;
                                });
                                _page = 1;
                                _fetchJobs(reset: true);
                              },
                            ),
                          if (_selectedService != null)
                            _buildFilterChip(
                              label: _selectedService!,
                              onRemove: () {
                                setState(() {
                                  _selectedService = null;
                                });
                                _page = 1;
                                _fetchJobs(reset: true);
                              },
                            ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _clearAllFilters,
                      icon: const Icon(Icons.clear_all,
                          size: 16, color: DesignSystem.textSecondary),
                      label: Text('Clear',
                          style: DesignSystem.textTheme.bodySmall?.copyWith(
                              color: DesignSystem.textSecondary)),
                      style: TextButton.styleFrom(
                        foregroundColor: DesignSystem.textSecondary,
                        textStyle: DesignSystem.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            // Popular Services (Jobs)
            Text(
              'Popular Services',
              style: DesignSystem.textTheme.titleMedium?.copyWith(
                color: DesignSystem.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: DesignSystem.spacing12),
            _loading && _jobs.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _jobs.isEmpty
                    ? Center(
                        child: Text('No jobs found',
                            style: TextStyle(color: DesignSystem.textSecondary)))
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _jobs.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: DesignSystem.spacing16,
                          crossAxisSpacing: DesignSystem.spacing16,
                          childAspectRatio: 0.95,
                        ),
                        itemBuilder: (context, index) {
                          final job = _jobs[index];
                          final bool watched =
                              _watchBox.containsKey(job.id); // Check if job is watched

                          return _JobCard(
                            job: job,
                            watched: watched,
                            onToggleWatch: () {
                              setState(() {
                                if (watched) {
                                  _watchBox.delete(job.id);
                                } else {
                                  _watchBox.put(job.id, job.id);
                                }
                              });
                            },
                            distance: (ref.read(locationProvider).lat != null &&
                                    ref.read(locationProvider).lng != null &&
                                    job.lat != null &&
                                    job.lng != null)
                                ? _calculateDistance(
                                    ref.read(locationProvider).lat!,
                                    ref.read(locationProvider).lng!,
                                    job.lat!,
                                    job.lng!,
                                  )
                                : null,
                          );
                        },
                      ),
            if (_loading && _jobs.isNotEmpty)
              const Padding(
                padding: EdgeInsets.all(DesignSystem.spacing16),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showFilters,
        backgroundColor: DesignSystem.primaryColor,
        child: const Icon(Icons.filter_list),
      ),
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      backgroundColor: DesignSystem.backgroundLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(DesignSystem.radiusLarge)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                DesignSystem.spacing16, DesignSystem.spacing12, DesignSystem.spacing16, DesignSystem.spacing16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Filters',
                      style: DesignSystem.textTheme.headlineSmall?.copyWith(
                        color: DesignSystem.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedCategory = null;
                          _selectedService = null;
                          _searchCtrl.clear();
                        });
                        ref.read(locationProvider.notifier).clearLocation();
                        Navigator.pop(context); // Close and refresh
                        _page = 1;
                        _fetchJobs(reset: true);
                      },
                      child: Text('Clear',
                          style: DesignSystem.textTheme.labelLarge
                              ?.copyWith(color: DesignSystem.primaryColor)),
                    ),
                  ],
                ),
                const SizedBox(height: DesignSystem.spacing8),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    labelStyle: DesignSystem.textTheme.bodyMedium
                        ?.copyWith(color: DesignSystem.textSecondary),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(DesignSystem.radiusSmall),
                      borderSide:
                          BorderSide(color: DesignSystem.backgroundLighter),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(DesignSystem.radiusSmall),
                      borderSide:
                          BorderSide(color: DesignSystem.primaryColor, width: 2),
                    ),
                  ),
                  dropdownColor: DesignSystem.backgroundLight,
                  style: DesignSystem.textTheme.bodyMedium,
                  items: _buildCategoryItems(),
                  onChanged: (v) => setState(() {
                    _selectedCategory = v;
                    _selectedService = null;
                  }),
                ),
                const SizedBox(height: DesignSystem.spacing12),
                DropdownButtonFormField<String>(
                  value: _selectedService,
                  decoration: InputDecoration(
                    labelText: 'Service',
                    labelStyle: DesignSystem.textTheme.bodyMedium
                        ?.copyWith(color: DesignSystem.textSecondary),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(DesignSystem.radiusSmall),
                      borderSide:
                          BorderSide(color: DesignSystem.backgroundLighter),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(DesignSystem.radiusSmall),
                      borderSide:
                          BorderSide(color: DesignSystem.primaryColor, width: 2),
                    ),
                  ),
                  dropdownColor: DesignSystem.backgroundLight,
                  style: DesignSystem.textTheme.bodyMedium,
                  items: _buildServiceItems(_selectedCategory),
                  onChanged: (v) async {
                    setState(() {
                      _selectedService = v;
                      _searchCtrl
                          .clear(); // Clear text field when service is selected
                    });
                    // _page = 1; // Refresh immediately after selection if needed
                    // await _fetchJobs(reset: true);
                  },
                ),
                const SizedBox(height: DesignSystem.spacing12),
                Consumer(
                  builder: (context, ref, child) {
                    final locationState = ref.watch(locationProvider);
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: locationState.lat == null
                                    ? null
                                    : _clearLocation,
                                icon: Icon(
                                  locationState.lat == null
                                      ? Icons.my_location_rounded
                                      : Icons.clear_rounded,
                                  color: DesignSystem.primaryColor,
                                ),
                                label: Text(
                                  locationState.lat == null
                                      ? 'Location set in header'
                                      : 'Clear location',
                                  style: DesignSystem.textTheme.bodyMedium
                                      ?.copyWith(
                                          color: DesignSystem.primaryColor),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                      color: DesignSystem.primaryColor),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: DesignSystem.spacing12),
                        if (locationState.lat != null &&
                            locationState.lng != null) ...[
                          Row(
                            children: [
                              Text(
                                'Radius: ${locationState.radiusKm.toStringAsFixed(1)} km',
                                style: DesignSystem.textTheme.bodyMedium
                                    ?.copyWith(color: DesignSystem.textPrimary),
                              ),
                              Expanded(
                                child: Slider(
                                  min: 1,
                                  max: 50,
                                  divisions: 49,
                                  value: locationState.radiusKm,
                                  label:
                                      locationState.radiusKm.toStringAsFixed(
                                    0,
                                  ),
                                  onChanged: (v) => ref
                                      .read(locationProvider.notifier)
                                      .updateLocation(radiusKm: v),
                                  activeColor: DesignSystem.primaryColor,
                                  inactiveColor:
                                      DesignSystem.primaryColor.withOpacity(0.3),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    );
                  },
                ),
                const SizedBox(height: DesignSystem.spacing8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      _page = 1;
                      await _fetchJobs(reset: true);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: DesignSystem.primaryColor,
                      padding: const EdgeInsets.symmetric(
                          vertical: DesignSystem.spacing15),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(DesignSystem.radiusSmall),
                      ),
                    ),
                    child: Text('Apply',
                        style: DesignSystem.textTheme.titleMedium
                            ?.copyWith(color: DesignSystem.textPrimary)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<DropdownMenuItem<String>> _buildCategoryItems() {
    final cats = _services.map((e) => e.category).toSet().toList()..sort();
    return [
      DropdownMenuItem(
          value: null,
          child: Text('All categories',
              style: DesignSystem.textTheme.bodyMedium
                  ?.copyWith(color: DesignSystem.textSecondary))),
      ...cats
          .map((c) => DropdownMenuItem(
              value: c,
              child: Text(c,
                  style: DesignSystem.textTheme.bodyMedium
                      ?.copyWith(color: DesignSystem.textPrimary))))
          .toList(),
    ];
  }

  List<DropdownMenuItem<String>> _buildServiceItems(String? category) {
    List<ServiceItem> svcs;
    if (category == null) {
      // Show all services initially
      svcs = List.from(_services)..sort((a, b) => a.name.compareTo(b.name));
    } else {
      // Filter by category
      svcs = _services.where((s) => s.category == category).toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    }

    return [
      DropdownMenuItem(
          value: null,
          child: Text('All services',
              style: DesignSystem.textTheme.bodyMedium
                  ?.copyWith(color: DesignSystem.textSecondary))),
      ...svcs
          .map((s) => DropdownMenuItem(
              value: s.name,
              child: Text(s.name,
                  style: DesignSystem.textTheme.bodyMedium
                      ?.copyWith(color: DesignSystem.textPrimary))))
          .toList(),
    ];
  }
}

class _JobCard extends StatelessWidget {
  const _JobCard({
    required this.job,
    required this.watched,
    required this.onToggleWatch,
    this.distance,
  });

  final JobRecord job;
  final bool watched;
  final VoidCallback onToggleWatch;
  final double? distance;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed('/job_details', arguments: job.id);
      },
      borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
      child: Container(
        height: 190, // Set a fixed height for the card
        decoration: BoxDecoration(
          color: DesignSystem.backgroundLight,
          borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
          boxShadow: DesignSystem.cardShadow,
          border: Border.all(
            color: DesignSystem.backgroundLighter,
            width: 1.2,
          ),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: created at tag and icon
                Padding(
                  padding: const EdgeInsets.only(
                      top: 8, left: 8, right: 8, bottom: 0),
                  child: Row(
                    children: [
                      Icon(Icons.work_outline,
                          color: DesignSystem.textSecondary, size: 28),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: DesignSystem.backgroundLighter,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _formatDate(job.createdAt),
                          style: DesignSystem.textTheme.labelSmall?.copyWith(
                            color: DesignSystem.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Main content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.title,
                          style: DesignSystem.textTheme.bodyMedium?.copyWith(
                            color: DesignSystem.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.miscellaneous_services,
                                size: 14, color: DesignSystem.accentColor),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                job.service,
                                style: DesignSystem.textTheme.labelMedium?.copyWith(
                                  color: DesignSystem.accentColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.place_rounded,
                                size: 14, color: DesignSystem.primaryColor),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                job.address,
                                style: DesignSystem.textTheme.labelSmall?.copyWith(
                                  color: DesignSystem.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          job.price != 0
                              ? 'Starts from ₹${job.price}'
                              : 'Free',
                          style: DesignSystem.textTheme.bodySmall?.copyWith(
                            color: DesignSystem.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: DesignSystem.spacing64),
        Icon(Icons.search_off_rounded,
            size: DesignSystem.spacing64, color: DesignSystem.textSecondary.withOpacity(0.5)),
        const SizedBox(height: DesignSystem.spacing12),
        Center(
          child: Text('No jobs found',
              style: DesignSystem.textTheme.headlineSmall
                  ?.copyWith(color: DesignSystem.textPrimary)),
        ),
        const SizedBox(height: DesignSystem.spacing8),
        Center(
          child: Text(
            'Try adjusting filters or search',
            style: DesignSystem.textTheme.bodyMedium
                ?.copyWith(color: DesignSystem.textSecondary),
          ),
        ),
        const SizedBox(height: DesignSystem.spacing16),
        Center(
          child: OutlinedButton(
            onPressed: onRetry,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: DesignSystem.primaryColor),
            ),
            child: Text('Refresh',
                style: DesignSystem.textTheme.bodyMedium
                    ?.copyWith(color: DesignSystem.primaryColor)),
          ),
        ),
      ],
    );
  }
}