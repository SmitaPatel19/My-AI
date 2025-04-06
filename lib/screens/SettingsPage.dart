import 'package:allen/widgets/pallete.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'TermsOfServices.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue.shade50.withOpacity(0.9),
      appBar: AppBar(
        backgroundColor: Pallete.secondSuggestionBoxColor,
        title: Text(
          'Settings',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cera Pro',
            color: Pallete.mainFontColor,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'General Settings',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cera Pro',
                color: Pallete.mainFontColor,
              ),
            ),
            SizedBox(height: 20.0),
            SwitchListTile(
              title: Text('Receive Notifications',style: TextStyle(
                fontFamily: 'Cera Pro',
                color: Pallete.mainFontColor,
              ),),
              value: true,
              onChanged: (value) {
                // Handle notification toggle
              },
            ),
            SwitchListTile(
              title: Text('Dark Mode',style: TextStyle(
                fontFamily: 'Cera Pro',
                color: Pallete.mainFontColor,
              ),),
              value: false,
              onChanged: (value) {
                // Handle dark mode toggle
              },
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                _showTermsOfServiceDialog(context);
              },
              child: Text(
                'View Terms of Service',
                style: TextStyle(
                  fontSize: 16.0,
                  fontFamily: 'Cera Pro',
                  color: Pallete.mainFontColor,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Pallete.secondSuggestionBoxColor,
                minimumSize: Size(double.infinity, 50.0),
              ),
            ),
            SizedBox(height: 10.0),
            ElevatedButton(
              onPressed: () {
                _changeUsername(context);
              },
              child: Text(
                'Change Username',
                style: TextStyle(
                  fontSize: 16.0,
                  fontFamily: 'Cera Pro',
                  color: Pallete.mainFontColor,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Pallete.secondSuggestionBoxColor,
                minimumSize: Size(double.infinity, 50.0),
              ),
            ),
            SizedBox(height: 10.0),
            ElevatedButton(
              onPressed: () {
                _changeProfile(context);
              },
              child: Text(
                'Change Profile',
                style: TextStyle(
                  fontSize: 16.0,
                  fontFamily: 'Cera Pro',
                  color: Pallete.mainFontColor,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Pallete.secondSuggestionBoxColor,
                minimumSize: Size(double.infinity, 50.0),
              ),
            ),
            SizedBox(height: 10.0),
            ElevatedButton(
              onPressed: () {
                _changeTheme(context);
              },
              child: Text(
                'Change Theme',
                style: TextStyle(
                  fontSize: 16.0,
                  fontFamily: 'Cera Pro',
                  color: Pallete.mainFontColor,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Pallete.secondSuggestionBoxColor,
                minimumSize: Size(double.infinity, 50.0),
              ),
            ),
            SizedBox(height: 10.0),
            ElevatedButton(
              onPressed: () {
                _changePassword(context);
              },
              child: Text(
                'Change Password',
                style: TextStyle(
                  fontSize: 16.0,
                  fontFamily: 'Cera Pro',
                  color: Pallete.mainFontColor,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Pallete.secondSuggestionBoxColor,
                minimumSize: Size(double.infinity, 50.0),
              ),
            ),
            SizedBox(height: 10.0),
            ElevatedButton(
              onPressed: () {
                _privacySettings(context);
              },
              child: Text(
                'Privacy Settings',
                style: TextStyle(
                  fontSize: 16.0,
                  fontFamily: 'Cera Pro',
                  color: Pallete.mainFontColor,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Pallete.secondSuggestionBoxColor,
                minimumSize: Size(double.infinity, 50.0),
              ),
            ),
            SizedBox(height: 10.0),
            ElevatedButton(
              onPressed: () {
                _logOut(context);
              },
              child: Text(
                'Log Out',
                style: TextStyle(
                  fontSize: 16.0,
                  fontFamily: 'Cera Pro',
                  color: Pallete.mainFontColor,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Pallete.secondSuggestionBoxColor,
                minimumSize: Size(double.infinity, 50.0),
              ),
            ),
            // Add more buttons for additional functions
          ],
        ),
      ),
    );
  }

  void _showTermsOfServiceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TermsOfServiceDialog();
      },
    );
  }

  void _changeUsername(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change Username',style: TextStyle(
            fontFamily: 'Cera Pro',
            color: Pallete.mainFontColor,
          ),),
          content: TextField(
            decoration: InputDecoration(labelText: 'New Username'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel',style: TextStyle(
                fontFamily: 'Cera Pro',
                color: Pallete.mainFontColor,
              ),),
            ),
            TextButton(
              onPressed: () {
                // Implement logic to update the username
                // You may need to call a function or update state accordingly
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Save',style: TextStyle(
                fontFamily: 'Cera Pro',
                color: Pallete.mainFontColor,
              ),),
            ),
          ],
        );
      },
    );
  }

  void _changeProfile(BuildContext context) {
    // Implement logic to navigate to the screen where the user can change their profile
    // You might use Navigator.push to navigate to a new screen
  }

  void _changeTheme(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change Theme',style: TextStyle(
            fontFamily: 'Cera Pro',
            color: Pallete.mainFontColor,
          ),),
          content: Text('Select your preferred theme:',style: TextStyle(
            fontFamily: 'Cera Pro',
            color: Pallete.mainFontColor,
          ),),
          actions: [
            TextButton(
              onPressed: () {
                // Implement logic for changing to a light theme
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Light Theme',style: TextStyle(
                fontFamily: 'Cera Pro',
                color: Pallete.mainFontColor,
              ),),
            ),
            TextButton(
              onPressed: () {
                // Implement logic for changing to a dark theme
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Dark Theme',style: TextStyle(
                fontFamily: 'Cera Pro',
                color: Pallete.mainFontColor,
              ),),
            ),
          ],
        );
      },
    );
  }

  void _changePassword(BuildContext context) {
    // Implement logic to navigate to the screen where the user can change their password
    // You might use Navigator.push to navigate to a new screen
  }

  void _privacySettings(BuildContext context) {
    // Implement logic to navigate to the screen where the user can configure privacy settings
    // You might use Navigator.push to navigate to a new screen
  }

  void _logOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Log Out',style: TextStyle(
            fontFamily: 'Cera Pro',
            color: Pallete.mainFontColor,
          ),),
          content: Text('Are you sure you want to log out?',style: TextStyle(
            fontFamily: 'Cera Pro',
            color: Pallete.mainFontColor,
          ),),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel',style: TextStyle(
                fontFamily: 'Cera Pro',
                color: Pallete.mainFontColor,
              ),),
            ),
            TextButton(
              onPressed: () {
                // Implement logic to log the user out
                // This might involve clearing authentication tokens, resetting state, etc.
                Navigator.popUntil(context, (route) =>
                route
                    .isFirst); // Close all screens and go back to the first screen
              },
              child: Text('Log Out',style: TextStyle(
                fontFamily: 'Cera Pro',
                color: Pallete.mainFontColor,
              ),),
            ),
          ],
        );
      },
    );
  }
}