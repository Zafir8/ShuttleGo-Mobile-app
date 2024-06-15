import 'package:flutter/material.dart';
import 'package:google_place/google_place.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SearchLocationPage extends StatefulWidget {
  final Function(String, LatLng) onLocationSelected;

  SearchLocationPage({required this.onLocationSelected});

  @override
  _SearchLocationPageState createState() => _SearchLocationPageState();
}

class _SearchLocationPageState extends State<SearchLocationPage> {
  late GooglePlace googlePlace;
  List<AutocompletePrediction> predictions = [];

  @override
  void initState() {
    super.initState();
    googlePlace = GooglePlace(''); 
  }

  void autoCompleteSearch(String value) async {
    var result = await googlePlace.autocomplete.get(value);
    if (result != null && result.predictions != null) {
      setState(() {
        predictions = result.predictions!;
      });
    }
  }

  void getPlaceDetails(String placeId) async {
    var result = await googlePlace.details.get(placeId);
    if (result != null && result.result != null) {
      final lat = result.result!.geometry!.location!.lat!;
      final lng = result.result!.geometry!.location!.lng!;
      widget.onLocationSelected(result.result!.name!, LatLng(lat, lng));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Location'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search location',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  autoCompleteSearch(value);
                } else {
                  setState(() {
                    predictions = [];
                  });
                }
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: predictions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(Icons.location_pin),
                  title: Text(predictions[index].description!),
                  onTap: () {
                    getPlaceDetails(predictions[index].placeId!);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
