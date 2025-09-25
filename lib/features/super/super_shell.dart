import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../design_system.dart';
import '../../core/router/app_routes.dart';
import '../jobs/presentation/jobs_list_screen.dart';
import '../common/screens/watchlist_screen.dart';
import '../profile/profile_screen.dart';
import '../jobs/data/location_service.dart';
import '../jobs/data/location_provider.dart';

class SuperShell extends ConsumerStatefulWidget {
  const SuperShell({super.key});

  @override
  ConsumerState<SuperShell> createState() => _SuperShellState();
}

class _SuperShellState extends ConsumerState<SuperShell> {
  int _currentIndex = 0;
  bool _isLoadingLocation = false;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const JobsListScreen(),
      const WatchlistScreen(),
      const ProfileScreen(),
    ];
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final cityData = await LocationService.getCurrentCity();
      if (cityData['city'] != 'Unknown' && cityData['error'] == null) {
        ref
            .read(locationProvider.notifier)
            .updateLocation(locationName: cityData['city']!);
      }
    } catch (e) {
      // Handle error silently
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationProvider);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 180,
        leading: InkWell(
          onTap: _showLocationPicker,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _isLoadingLocation
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.location_on_rounded,
                        color: Colors.white,
                      ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    locationState.locationName,
                    style: DesignSystem.textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(
                  Icons.expand_more_rounded,
                  color: Colors.white70,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Livora"),
            // if (user != null && user.displayName != null)
            //   Text(
            //     "Welcome back, ${user.displayName!}",
            //     style: DesignSystem.textTheme.bodySmall?.copyWith(
            //       color: Colors.white70,
            //       fontWeight: FontWeight.w400,
            //     ),
            //   ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () async {
              await _getCurrentLocation();
              ref
                  .read(locationProvider.notifier)
                  .updateLocation(applyFilter: false);
            },
            tooltip: 'Use current location',
          ),
          if (locationState.locationName != 'Select location')
            IconButton(
              icon: const Icon(Icons.clear_rounded),
              onPressed: () {
                ref.read(locationProvider.notifier).clearLocation();
              },
              tooltip: 'Clear location',
            ),
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        backgroundColor: DesignSystem.backgroundLight,
        indicatorColor: DesignSystem.primaryColor.withOpacity(0.2),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home, color: DesignSystem.textSecondary),
            selectedIcon: Icon(Icons.home, color: DesignSystem.primaryColor),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark, color: DesignSystem.textSecondary),
            selectedIcon: Icon(
              Icons.bookmark,
              color: DesignSystem.primaryColor,
            ),
            label: 'Watchlist',
          ),
          NavigationDestination(
            icon: Icon(Icons.person, color: DesignSystem.textSecondary),
            selectedIcon: Icon(Icons.person, color: DesignSystem.primaryColor),
            label: 'Profile',
          ),
        ],
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.pushNamed(context, AppRoutes.jobCategory);
                if (mounted) {
                  final currentState = ref.read(locationProvider);
                  ref
                      .read(locationProvider.notifier)
                      .updateLocation(
                        locationName: currentState.locationName,
                        lat: currentState.lat,
                        lng: currentState.lng,
                        radiusKm: currentState.radiusKm,
                      );
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Post Job'),
              backgroundColor: DesignSystem.primaryColor,
              foregroundColor: Colors.white,
            )
          : null,
    );
  }

  void _showLocationPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: DesignSystem.backgroundLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final locationState = ref.watch(locationProvider);
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 8),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Select Location & Radius',
                        style: DesignSystem.textTheme.titleLarge,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Radius Slider
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Search Radius: ${locationState.radiusKm.toStringAsFixed(1)} km',
                            style: DesignSystem.textTheme.titleMedium,
                          ),
                          Slider(
                            value: locationState.radiusKm,
                            min: 1.0,
                            max: 50.0,
                            divisions: 49,
                            activeColor: DesignSystem.primaryColor,
                            inactiveColor: DesignSystem.textTertiary
                                .withOpacity(0.3),
                            onChanged: (value) {
                              ref
                                  .read(locationProvider.notifier)
                                  .updateLocation(radiusKm: value);
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        style: const TextStyle(color: DesignSystem.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Search location',
                          hintStyle: const TextStyle(
                            color: DesignSystem.textSecondary,
                          ),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: DesignSystem.textSecondary,
                          ),
                          filled: true,
                          fillColor: DesignSystem.backgroundLighter,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              DesignSystem.radiusMedium,
                            ),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Location Options
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: _getLocationOptions().length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, color: Colors.white24),
                        itemBuilder: (context, index) {
                          final location = _getLocationOptions()[index];
                          return ListTile(
                            leading: Icon(
                              location['icon'] as IconData,
                              color: DesignSystem.textSecondary,
                            ),
                            title: Text(
                              location['name']!,
                              style: const TextStyle(
                                color: DesignSystem.textPrimary,
                              ),
                            ),
                            subtitle: location['subtitle'] != null
                                ? Text(
                                    location['subtitle']!,
                                    style: const TextStyle(
                                      color: DesignSystem.textSecondary,
                                    ),
                                  )
                                : null,
                            onTap: () => _selectLocation(location, context),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // Apply location filter only when user taps Apply
                            ref
                                .read(locationProvider.notifier)
                                .updateLocation(applyFilter: true);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: DesignSystem.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Apply Filter'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<Map<String, dynamic>> _getLocationOptions() {
    return [
      {
        'name': 'Use current location',
        'subtitle': 'GPS location',
        'icon': Icons.my_location_rounded,
        'type': 'current',
      },
      {
        'name': 'Bengaluru',
        'subtitle': 'Karnataka, India',
        'icon': Icons.location_city_rounded,
        'type': 'city',
        'lat': '12.9716',
        'lng': '77.5946',
      },
      {
        'name': 'Mumbai',
        'subtitle': 'Maharashtra, India',
        'icon': Icons.location_city_rounded,
        'type': 'city',
        'lat': '19.0760',
        'lng': '72.8777',
      },
      {
        'name': 'Delhi',
        'subtitle': 'Delhi, India',
        'icon': Icons.location_city_rounded,
        'type': 'city',
        'lat': '28.7041',
        'lng': '77.1025',
      },
      {
        'name': 'Hyderabad',
        'subtitle': 'Telangana, India',
        'icon': Icons.location_city_rounded,
        'type': 'city',
        'lat': '17.3850',
        'lng': '78.4867',
      },
      {
        'name': 'Chennai',
        'subtitle': 'Tamil Nadu, India',
        'icon': Icons.location_city_rounded,
        'type': 'city',
        'lat': '13.0827',
        'lng': '80.2707',
      },
      {
        'name': 'Pune',
        'subtitle': 'Maharashtra, India',
        'icon': Icons.location_city_rounded,
        'type': 'city',
        'lat': '18.5204',
        'lng': '73.8567',
      },
    ];
  }

  Future<void> _selectLocation(
    Map<String, dynamic> location,
    BuildContext context,
  ) async {
    if (location['type'] == 'current') {
      await _getCurrentLocation();
      // Do not auto-apply; user must press Apply
    } else {
      ref
          .read(locationProvider.notifier)
          .updateLocation(
            locationName: location['name']!,
            lat: double.tryParse(location['lat'] ?? ''),
            lng: double.tryParse(location['lng'] ?? ''),
            applyFilter: false,
          );
    }
    Navigator.pop(context);
  }

  // String _locationTitle(String locationName) {
  //   if (locationName.isNotEmpty && locationName != 'Select location') {
  //     return locationName;
  //   }
  //   return 'Livora';
  // }
}
