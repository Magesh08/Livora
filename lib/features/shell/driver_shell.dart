import 'package:flutter/material.dart';
import '../spots/widgets/spot_card.dart';

class DriverShell extends StatefulWidget {
  const DriverShell({super.key});

  @override
  State<DriverShell> createState() => _DriverShellState();
}

class _DriverShellState extends State<DriverShell> {
  int _index = 0;

  static const _tabs = [
    Icons.search,
    Icons.book,
    Icons.favorite,
    Icons.person,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _index == 0
          ? ListView(
              padding: const EdgeInsets.only(top: 16, bottom: 24),
              children: const [
                SpotCard(
                  title: 'Secure Garage - Downtown',
                  pricePerHour: 4,
                  distanceKm: 0.8,
                  rating: 4.7,
                  imageUrl: 'https://images.unsplash.com/photo-1517048676732-d65bc937f952?q=80&w=800&auto=format&fit=crop',
                  available: true,
                ),
                SpotCard(
                  title: 'Covered Spot near Mall',
                  pricePerHour: 3,
                  distanceKm: 1.3,
                  rating: 4.4,
                  imageUrl: 'https://images.unsplash.com/photo-1483721310020-03333e577078?q=80&w=800&auto=format&fit=crop',
                  available: true,
                ),
                SpotCard(
                  title: 'Open Lot - Stadium',
                  pricePerHour: 2,
                  distanceKm: 2.4,
                  rating: 4.1,
                  imageUrl: 'https://images.unsplash.com/photo-1542315192-1f61a1929098?q=80&w=800&auto=format&fit=crop',
                  available: false,
                ),
                SpotCard(
                  title: 'EV Charging - Tech Park',
                  pricePerHour: 6,
                  distanceKm: 3.0,
                  rating: 4.9,
                  imageUrl: 'https://images.unsplash.com/photo-1600369671667-9a84a3bb30fd?q=80&w=800&auto=format&fit=crop',
                  available: true,
                ),
              ],
            )
          : Center(child: Text('Driver tab index: $_index')),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.search), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.book), label: 'Bookings'),
          NavigationDestination(icon: Icon(Icons.favorite), label: 'Favorites'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onDestinationSelected: (i) => setState(() => _index = i),
      ),
    );
  }
}


