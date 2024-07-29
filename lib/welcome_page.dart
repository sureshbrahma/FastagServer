import 'package:flutter/material.dart';
import 'dart:io';
import 'fastag_form.dart';
import 'check_status_page.dart'; // Import CheckStatusPage
import 'change_mobile_number_page.dart'; // Import ChangeMobileNumberPage
import 'status_of_mobile_number_change_page.dart'; // Import StatusOfMobileNumberChangePage

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF87CEFA),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 16.0),
              child: Image.asset(
                'assets/shiva2.png', // Update with your image asset
                height: 150.0,
              ),
            ),
            const SizedBox(height: 16.0),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: Colors.red, width: 2.0),
              ),
              child: Column(
                children: [
                  const Text(
                    'Welcome to FASTAG Recharge Requisition Form',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.0,
                      color: Colors.red,
                      /*backgroundColor: Colors.white*/
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  Image.asset(
                    'assets/welcome_image.jpg', // Update with your image asset
                    height: 100.0,
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const FastagForm()),
                      );
                    },
                    child: const Text('New Request For Fastag Recharge'),
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CheckStatusPage()),
                      );
                    },
                    child: const Text('Check Status of Fastag Recharge'),
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ChangeMobileNumberPage()),
                      );
                    },
                    child: const Text('Request to Change Mobile Number'),
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const StatusOfMobileNumberChangePage()),
                      );
                    },
                    child: const Text('Status of Mobile Number Change'),
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      exit(0);
                    },
                    child: const Text('Exit'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
