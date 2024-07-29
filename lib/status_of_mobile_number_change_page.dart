import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StatusOfMobileNumberChangePage extends StatefulWidget {
  const StatusOfMobileNumberChangePage({super.key});

  @override
  _StatusOfMobileNumberChangePageState createState() =>
      _StatusOfMobileNumberChangePageState();
}

class _StatusOfMobileNumberChangePageState
    extends State<StatusOfMobileNumberChangePage> {
  final _formKey = GlobalKey<FormState>();
  final _vehicleNumberController = TextEditingController();
  final _oldMobileNumberController = TextEditingController();
  final _newMobileNumberController = TextEditingController();
  List<Map<String, dynamic>> _statusList = [];
  String? _errorMessage;

  @override
  void dispose() {
    _vehicleNumberController.dispose();
    _oldMobileNumberController.dispose();
    _newMobileNumberController.dispose();
    super.dispose();
  }

  String _normalizeString(String input) {
    return input.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
  }

  Future<bool> _checkInternetConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true; // Internet connection is available
      }
      return false; // Internet connection is not available
    } on SocketException catch (_) {
      return false; // Internet connection is not available
    }
  }

  Future<void> fetchStatus() async {
    final vehicleNumber = _normalizeString(_vehicleNumberController.text);
    final oldMobileNumber = _normalizeString(_oldMobileNumberController.text);
    final newMobileNumber = _normalizeString(_newMobileNumberController.text);

    final bool isConnected = await _checkInternetConnectivity();
    if (!isConnected) {
      setState(() {
        _errorMessage = 'No internet connection. Please check your network settings.';
      });
      return;
    }

    try {
      const url = 'http://192.168.73.220:88/api/change'; // Replace with your API URL
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        List<Map<String, dynamic>> filteredData = jsonData.where((status) {
          return _normalizeString(status['VehicleNumber']) == vehicleNumber &&
              _normalizeString(status['OldMobileNumber']) == oldMobileNumber &&
              _normalizeString(status['NewMobileNumber']) == newMobileNumber;
        }).map((status) => Map<String, dynamic>.from(status)).toList();

        setState(() {
          _statusList = filteredData;
          _errorMessage = filteredData.isEmpty ? 'No request found for the entered vehicle number, old mobile number, and new mobile number' : null;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to fetch data from the server';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching data: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Status of Mobile Number Change'),
        backgroundColor: Colors.blue, // Customize app bar color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _vehicleNumberController,
                decoration: const InputDecoration(
                  labelText: 'Vehicle Number',
                  border: OutlineInputBorder(),
                  hintText: 'Please Enter your Full Vehicle Number',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter vehicle number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _oldMobileNumberController,
                decoration: const InputDecoration(
                  labelText: 'Old Mobile Number',
                  border: OutlineInputBorder(),
                  hintText: 'Please Enter your Old Mobile Number',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter old mobile number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _newMobileNumberController,
                decoration: const InputDecoration(
                  labelText: 'New Mobile Number',
                  border: OutlineInputBorder(),
                  hintText: 'Please Enter your New Mobile Number',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter new mobile number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    fetchStatus();
                  }
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color>(Colors.blue), // Customize button color
                ),
                child: const Text('Fetch Status'),
              ),
              const SizedBox(height: 20),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: const TextStyle(fontSize: 16, color: Colors.red),
                ),
              if (_statusList.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    itemCount: _statusList.length,
                    itemBuilder: (context, index) {
                      final status = _statusList[index];
                      return ListTile(
                        title: Text('Vehicle: ${status['VehicleNumber']}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Old Mobile: ${status['OldMobileNumber']}'),
                            Text('New Mobile: ${status['NewMobileNumber']}'),
                            Text('Status: ${status['Status']}'),

                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() => runApp(const MaterialApp(home: StatusOfMobileNumberChangePage()));
