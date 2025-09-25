import 'package:flutter_riverpod/flutter_riverpod.dart';

class LocationState {
  final String locationName;
  final double? lat;
  final double? lng;
  final double radiusKm;
  final bool applyFilter;

  LocationState({
    this.locationName = 'Select location',
    this.lat,
    this.lng,
    this.radiusKm = 10.0,
    this.applyFilter = false,
  });

  LocationState copyWith({
    String? locationName,
    double? lat,
    double? lng,
    double? radiusKm,
    bool? applyFilter,
  }) {
    return LocationState(
      locationName: locationName ?? this.locationName,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      radiusKm: radiusKm ?? this.radiusKm,
      applyFilter: applyFilter ?? this.applyFilter,
    );
  }
}

class LocationNotifier extends StateNotifier<LocationState> {
  LocationNotifier() : super(LocationState());

  void updateLocation({
    String? locationName,
    double? lat,
    double? lng,
    double? radiusKm,
    bool? applyFilter,
  }) {
    state = state.copyWith(
      locationName: locationName,
      lat: lat,
      lng: lng,
      radiusKm: radiusKm,
      applyFilter: applyFilter,
    );
  }

  void clearLocation() {
    state = LocationState();
  }
}

final locationProvider = StateNotifierProvider<LocationNotifier, LocationState>(
  (ref) => LocationNotifier(),
);
