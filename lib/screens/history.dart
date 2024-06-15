import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, dynamic>> _locations = [];

  @override
  void initState() {
    super.initState();
    _loadSavedLocations();
  }

  Future<void> _loadSavedLocations() async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> locations = [];

    final homeLocationName = prefs.getString('home_location_name');
    final homeLocationLat = prefs.getDouble('home_location_lat');
    final homeLocationLng = prefs.getDouble('home_location_lng');

    if (homeLocationName != null && homeLocationLat != null && homeLocationLng != null) {
      locations.add({
        'type': 'Home',
        'name': homeLocationName,
        'lat': homeLocationLat,
        'lng': homeLocationLng,
      });
    }

    final destinationLocationName = prefs.getString('destination_location_name');
    final destinationLocationLat = prefs.getDouble('destination_location_lat');
    final destinationLocationLng = prefs.getDouble('destination_location_lng');

    if (destinationLocationName != null && destinationLocationLat != null && destinationLocationLng != null) {
      locations.add({
        'type': 'Destination',
        'name': destinationLocationName,
        'lat': destinationLocationLat,
        'lng': destinationLocationLng,
      });
    }

    setState(() {
      _locations = locations;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Locations'),
      ),
      body: _locations.isEmpty
          ? Center(child: Text('No saved locations'))
          : ListView.builder(
              itemCount: _locations.length,
              itemBuilder: (context, index) {
                final location = _locations[index];
                return ListTile(
                  title: Text(location['name']),
                  subtitle: Text('${location['type']} - (${location['lat']}, ${location['lng']})'),
                  leading: Icon(location['type'] == 'Home' ? Icons.home : Icons.location_pin),
                );
              },
            ),
    );
  }
}
