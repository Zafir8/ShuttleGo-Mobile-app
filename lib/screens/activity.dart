import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as rootBundle;
import 'dart:convert';
import 'RideSelection.dart';
import 'home.dart';
import 'profile.dart';
import 'ride.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User Activity',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ActivityPage(),
    );
  }
}

class ActivityPage extends StatefulWidget {
  @override
  _ActivityPageState createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  List activities = [];
  int _selectedIndex = 2; // This is the index of the current page in the BottomNavigationBar.

  @override
  void initState() {
    super.initState();
    loadJsonData();
  }

  Future<void> loadJsonData() async {
    try {
      final String response = await rootBundle.rootBundle.loadString('vehicles.json'); // Adjusted path
      final data = await json.decode(response);
      setState(() {
        activities = data;
      });
      print("Data loaded successfully"); // Debug print
    } catch (e) {
      print("Error loading JSON data: $e"); // Error handling
      setState(() {
        activities = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLargeScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        titleTextStyle: const TextStyle(color: Colors.white),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Activity'),
      ),
      body: activities.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : isLargeScreen
              ? Row(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: activities.length,
                        itemBuilder: (context, index) {
                          var activity = activities[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              leading: Icon(getIcon(activity['location'])),
                              title: Text(activity['location']),
                              subtitle: Text('${activity['date']} - ${activity['status']}'),
                              trailing: Text(activity['price']),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailPage(activity: activity),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: activities.length,
                  itemBuilder: (context, index) {
                    var activity = activities[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        leading: Icon(getIcon(activity['location'])),
                        title: Text(activity['location']),
                        subtitle: Text('${activity['date']} - ${activity['status']}'),
                        trailing: Text(activity['price']),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailPage(activity: activity),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (int index) {
          if (index != _selectedIndex) {
            setState(() {
              _selectedIndex = index;
            });
            switch (index) {
              case 0:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
                break;
              case 1:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => BookRidePage()),
                );
                break;
              case 3:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
                break;
            }
          }
        },
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
      ),
    );
  }

  IconData getIcon(String location) {
    if (location.toLowerCase().contains('college') || location.toLowerCase().contains('school')) {
      return Icons.directions_bus;
    } else {
      return Icons.directions_car;
    }
  }
}

class DetailPage extends StatelessWidget {
  final Map<String, dynamic> activity;

  DetailPage({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(activity['location']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Location: ${activity['location']}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Date: ${activity['date']}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Price: ${activity['price']}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Status: ${activity['status']}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RideSelectionPage()),
                );
              },
              child: Text('Rebook'),
            ),
          ],
        ),
      ),
    );
  }
}
