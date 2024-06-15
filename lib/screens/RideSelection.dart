import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';

class RideSelectionPage extends StatefulWidget {
  @override
  _RideSelectionPageState createState() => _RideSelectionPageState();
}

class _RideSelectionPageState extends State<RideSelectionPage> {
  List vehicleCategories = [];
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';
  bool isOffline = false;

  @override
  void initState() {
    super.initState();
    checkConnectivityAndFetchData();
  }

  Future<void> checkConnectivityAndFetchData() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        isLoading = false;
        isOffline = true;
      });
    } else {
      fetchVehicleCategories();
    }
  }

  Future<void> fetchVehicleCategories() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:8000/api/vehicle-categories'));

      if (response.statusCode == 200) {
        final parsed = json.decode(response.body);
        setState(() {
          vehicleCategories = parsed['data'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load vehicle categories');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = e.toString();
      });
    }
  }

  Future<void> _fetchVehicleDetails(int categoryId) async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:8000/api/vehicles/$categoryId'));

      if (response.statusCode == 200) {
        final parsed = json.decode(response.body);
        if (parsed.isNotEmpty) {
          final vehicleDetail = parsed[0];
          print('Vehicle detail fetched: $vehicleDetail');
          _showBookingConfirmation(context, vehicleDetail);
        } else {
          throw Exception('No vehicle details found');
        }
      } else {
        throw Exception('Failed to load vehicle details');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        errorMessage = e.toString();
      });
    }
  }

  void _showBookingConfirmation(BuildContext context, Map<String, dynamic> vehicleDetail) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Booking Confirmation'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Vehicle Number: ${vehicleDetail['number']}'),
              Text('Owner Name: ${vehicleDetail['owner_name']}'),
              Text('Owner Mobile: ${vehicleDetail['owner_mobile']}'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = theme.brightness == Brightness.dark ? Colors.white : theme.primaryColor;
    final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;
    final subTextColor = theme.brightness == Brightness.dark ? Colors.white70 : Colors.black54;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        titleTextStyle: const TextStyle(color: Colors.white),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Choose a ride'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : isOffline
              ? const Center(child: Text('You are offline. Please check your internet connection.'))
              : hasError
                  ? Center(child: Text('An error occurred while loading data: $errorMessage'))
                  : Stack(
                      children: [
                        Positioned.fill(
                          child: Image.asset(
                            'images/bus3.webp',
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            color: Colors.black.withOpacity(0.9),
                            child: ListView.builder(
                              shrinkWrap: true,
                              padding: const EdgeInsets.all(16.0),
                              itemCount: vehicleCategories.length,
                              itemBuilder: (context, index) {
                                var category = vehicleCategories[index];
                                var price = _getCategoryPrice(category['name']);
                                return Card(
                                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: ListTile(
                                    leading: Icon(
                                      _getCategoryIcon(category['name']),
                                      color: iconColor,
                                    ),
                                    title: Text(category['name'], style: TextStyle(color: textColor)),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(category['description'], style: TextStyle(color: subTextColor)),
                                        Text('Price: $price', style: TextStyle(color: textColor)),
                                      ],
                                    ),
                                    trailing: ElevatedButton(
                                      onPressed: () {
                                        print('Fetching details for category ID: ${category['id']}');
                                        _fetchVehicleDetails(category['id']);
                                      },
                                      child: Text('Choose ${category['name']}'),
                                      style: ElevatedButton.styleFrom(
                                        primary: const Color.fromARGB(255, 0, 13, 79),
                                        onPrimary: Colors.white,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
    );
  }

  int _getCategoryPrice(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'bus':
        return 500;
      case 'van':
        return 250;
      default:
        return 0;
    }
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'bus':
        return Icons.directions_bus;
      case 'van':
        return Icons.directions_car;
      default:
        return Icons.directions_car;
    }
  }
}

