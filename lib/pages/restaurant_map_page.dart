import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RestaurantMapPage extends StatefulWidget {
  const RestaurantMapPage({super.key});

  @override
  State<RestaurantMapPage> createState() => _RestaurantMapPageState();
}

class _RestaurantMapPageState extends State<RestaurantMapPage> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final CameraPosition _initialCameraPosition = const CameraPosition(
    target: LatLng(51.1694, 71.4491), 
    zoom: 12,
  );
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRestaurantMarkers(); 
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location services are disabled')),
      );
      setState(() => _isLoading = false);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied')),
        );
        setState(() => _isLoading = false);
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permissions are permanently denied')),
      );
      setState(() => _isLoading = false);
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() => _isLoading = false);

      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 14,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get location: $e')),
      );
    }
  }

  void _loadRestaurantMarkers() {
    final restaurants = [
      {
        'id': '1',
        'name': 'Del Papa',
        'position': const LatLng(51.1694, 71.4491),
      },
      {
        'id': '2',
        'name': 'Pasta La Vista',
        'position': const LatLng(51.1800, 71.4491),
      },
      {
        'id': '3',
        'name': 'Peek-a-boo',
        'position': const LatLng(51.1694, 71.4600),
      },
      {
        'id': '4',
        'name': 'Momo',
        'position': const LatLng(51.1600, 71.4491),
      },
    ];

    setState(() {
      for (var restaurant in restaurants) {
        _markers.add(
          Marker(
            markerId: MarkerId(restaurant['id'] as String),
            position: restaurant['position'] as LatLng,
            infoWindow: InfoWindow(
              title: restaurant['name'] as String,
              snippet: 'Tap to select this restaurant',
              onTap: () {
                _selectRestaurant(restaurant['id'] as String, restaurant['name'] as String);
              },
            ),
            onTap: () {
              _mapController?.showMarkerInfoWindow(MarkerId(restaurant['id'] as String));
            },
          ),
        );
      }
      _isLoading = false; 
    });
  }

  void _selectRestaurant(String id, String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Selected restaurant: $name')),
    );
    Navigator.pop(context, {
      'id': id,
      'name': name,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose a Restaurant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _getCurrentLocation,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: _initialCameraPosition,
                  markers: _markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  onMapCreated: (controller) => _mapController = controller,
                ),
                Positioned(
                  right: 16,
                  bottom: 100,
                  child: Column(
                    children: [
                      FloatingActionButton.small(
                        heroTag: "zoom_in",
                        onPressed: () => _mapController?.animateCamera(CameraUpdate.zoomIn()),
                        child: const Icon(Icons.add),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton.small(
                        heroTag: "zoom_out",
                        onPressed: () => _mapController?.animateCamera(CameraUpdate.zoomOut()),
                        child: const Icon(Icons.remove),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}