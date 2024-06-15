import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'home.dart';
import 'ride.dart';
import 'activity.dart';
import 'history.dart'; // Import the HistoryPage

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profile Page',
      theme: ThemeData.dark(), // Using dark theme
      home: ProfilePage(),
    );
  }
}

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 3; // This is the index of the current page in the BottomNavigationBar.
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _profileImage = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
        titleTextStyle: const TextStyle(color: Colors.white),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('Account'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // Settings action
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
              title: Text('Zafir Sharaz', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Row(
                children: [
                  Icon(Icons.star, color: Colors.yellow),
                  Text(' 4.90'),
                ],
              ),
              trailing: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  backgroundColor: Colors.grey,
                  backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                  child: _profileImage == null ? Icon(Icons.person) : null,
                ),
              ),
            ),
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              children: [
                _buildGridMenu(context, Icons.help_outline, 'Help'),
                _buildGridMenu(context, Icons.account_balance_wallet_outlined, 'Wallet'),
                _buildGridMenu(context, Icons.history_outlined, 'History'),
                _buildGridMenu(context, Icons.family_restroom_outlined, 'Family'),
                _buildGridMenu(context, Icons.privacy_tip_outlined, 'Privacy'),
                _buildGridMenu(context, Icons.settings_outlined, 'Settings'),
                _buildGridMenu(context, Icons.mail_outline, 'Messages'),
                _buildGridMenu(context, Icons.circle_notifications_outlined, 'Notifications'),
                _buildGridMenu(context, Icons.local_offer_outlined, 'Promos'),
                _buildGridMenu(context, Icons.account_circle_outlined, 'ShuttleGo Plus'),
              ],
            ),
            Card(
              margin: EdgeInsets.all(8),
              child: ListTile(
                title: Text('You have multiple promos'),
                subtitle: Text("We'll automatically apply the one that saves you the most"),
                leading: Icon(Icons.local_offer),
              ),
            ),
            ListTile(
              leading: Icon(Icons.privacy_tip),
              title: Text('Privacy checkup'),
              subtitle: Text('Take an interactive tour of your privacy settings'),
            ),
            ListTile(
              leading: Icon(Icons.family_restroom),
              title: Text('Family'),
              subtitle: Text('Manage a family profile'),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              subtitle: Text('Make changes to your account settings'),
            ),
            ListTile(
              leading: Icon(Icons.message),
              title: Text('Messages'),
              subtitle: Text('Driver messages in one place'),
              trailing: Switch(
                value: true,
                onChanged: (bool value) {
                  // switch change
                },
              ),
            ),
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('ShuttleGo Plus'),
              subtitle: Text('Enjoy benefits and savings'),
            ),
          ],
        ),
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
              case 2:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ActivityPage()),
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
            label: 'Account',
          ),
        ],
      ),
    );
  }

  Widget _buildGridMenu(BuildContext context, IconData icon, String label) {
    return InkWell(
      onTap: () {
        if (label == 'History') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HistoryPage()),
          );
        } else {
          // Handle other navigation actions based on the label or icon
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48),
          SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }
}
