import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'RideSelection.dart'; 
import 'activity.dart'; 
import 'profile.dart'; 
import 'home.dart'; 
import 'search_location_page.dart';
import 'history.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book a Ride',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide.none,
          ),
          prefixIconColor: Colors.grey,
          hintStyle: TextStyle(color: Colors.grey),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blueGrey,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[900],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide.none,
          ),
          prefixIconColor: Colors.white,
          hintStyle: TextStyle(color: Colors.white70),
        ),
      ),
      themeMode: ThemeMode.system,
      home: BookRidePage(),
    );
  }
}

class BookRidePage extends StatefulWidget {
  @override
  _BookRidePageState createState() => _BookRidePageState();
}

class _BookRidePageState extends State<BookRidePage> {
  int _selectedIndex = 1; 
  GoogleMapController? _mapController;
  static const LatLng _center = LatLng(6.9271, 79.8612); // Colombo coordinates
  LatLng? _selectedLocation;
  Marker? _selectedMarker;
  TextEditingController homeController = TextEditingController();
  TextEditingController destinationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
    } 

    Position position = await Geolocator.getCurrentPosition();
    LatLng currentLatLng = LatLng(position.latitude, position.longitude);

    setState(() {
      _selectedLocation = currentLatLng;
      _selectedMarker = Marker(
        markerId: MarkerId('currentLocation'),
        position: currentLatLng,
      );
      homeController.text = 'Current Location'; // Update this to a meaningful location name if you have reverse geocoding
    });

    _moveToLocation(currentLatLng);
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onMapTapped(LatLng location) {
    setState(() {
      _selectedLocation = location;
      _selectedMarker = Marker(
        markerId: MarkerId('selectedLocation'),
        position: location,
      );
    });
  }

  void _moveToLocation(LatLng location) {
    _mapController?.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: location, zoom: 14.0),
    ));
  }

  void _selectLocation(String type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchLocationPage(
          onLocationSelected: (String location, LatLng coords) {
            setState(() {
              if (type == 'home') {
                homeController.text = location;
              } else {
                destinationController.text = location;
              }
              _selectedLocation = coords;
              _selectedMarker = Marker(
                markerId: MarkerId(type),
                position: coords,
              );
              _moveToLocation(coords);
            });
            _saveLocation(type, location, coords);
          },
        ),
      ),
    );
  }

  Future<void> _saveLocation(String type, String location, LatLng coords) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('${type}_location_name', location);
    prefs.setDouble('${type}_location_lat', coords.latitude);
    prefs.setDouble('${type}_location_lng', coords.longitude);
  }

  Future<void> _loadSavedLocations() async {
    final prefs = await SharedPreferences.getInstance();
    final homeLocationName = prefs.getString('home_location_name');
    final homeLocationLat = prefs.getDouble('home_location_lat');
    final homeLocationLng = prefs.getDouble('home_location_lng');

    if (homeLocationName != null && homeLocationLat != null && homeLocationLng != null) {
      setState(() {
        homeController.text = homeLocationName;
        _selectedLocation = LatLng(homeLocationLat, homeLocationLng);
        _selectedMarker = Marker(
          markerId: MarkerId('home'),
          position: LatLng(homeLocationLat, homeLocationLng),
        );
        _moveToLocation(LatLng(homeLocationLat, homeLocationLng));
      });
    }

    final destinationLocationName = prefs.getString('destination_location_name');
    final destinationLocationLat = prefs.getDouble('destination_location_lat');
    final destinationLocationLng = prefs.getDouble('destination_location_lng');

    if (destinationLocationName != null && destinationLocationLat != null && destinationLocationLng != null) {
      setState(() {
        destinationController.text = destinationLocationName;
        _selectedLocation = LatLng(destinationLocationLat, destinationLocationLng);
        _selectedMarker = Marker(
          markerId: MarkerId('destination'),
          position: LatLng(destinationLocationLat, destinationLocationLng),
        );
        _moveToLocation(LatLng(destinationLocationLat, destinationLocationLng));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
        titleTextStyle: const TextStyle(color: Colors.white),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('Book a Ride'),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HistoryPage()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 11.0,
            ),
            onTap: _onMapTapped,
            markers: _selectedMarker != null ? {_selectedMarker!} : {},
          ),
          Positioned(
            top: 16.0,
            left: 16.0,
            right: 16.0,
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => _selectLocation('home'),
                  child: AbsorbPointer(
                    child: TextField(
                      controller: homeController,
                      decoration: InputDecoration(
                        hintText: 'Home',
                        prefixIcon: Icon(Icons.home),
                        filled: true,
                        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8.0),
                GestureDetector(
                  onTap: () => _selectLocation('destination'),
                  child: AbsorbPointer(
                    child: TextField(
                      controller: destinationController,
                      decoration: InputDecoration(
                        hintText: 'Where to?',
                        prefixIcon: Icon(Icons.location_pin),
                        filled: true,
                        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 16.0,
            left: 16.0,
            right: 16.0,
            child: ElevatedButton(
              onPressed: () {
                if (_selectedLocation != null) {
                  _moveToLocation(_selectedLocation!);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RideSelectionPage()),
                  );
                }
              },
              child: Text('Confirm Ride'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50), // width and height
                primary: const Color.fromARGB(255, 0, 13, 79),
                onPrimary: Colors.white,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, 
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            label: 'Book',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timeline),
            label: 'Activity',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
          switch (index) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ActivityPage()),
              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
              break;
          }
        },
      ),
    );
  }
}

