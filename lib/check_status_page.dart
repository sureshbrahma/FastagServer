import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CheckStatusPage extends StatefulWidget {
  const CheckStatusPage({super.key});

  @override
  _CheckStatusPageState createState() => _CheckStatusPageState();
}

class _CheckStatusPageState extends State<CheckStatusPage> {
  final TextEditingController _vehicleNumberController = TextEditingController();
  List<Map<String, String>> _apiData = [];
  List<String> _referenceNumbers = [];
  String? _selectedReferenceNumber;
  String? _selectedStatus;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchApiData();
  }

  Future<void> _fetchApiData() async {
    try {
      final response = await http.get(Uri.parse('https://bkaccanmol.bkapp.org/api/values'));

      if (response.statusCode == 200) {
        List<Map<String, String>> apiData = [];
        List<dynamic> jsonData = json.decode(response.body);

        for (var item in jsonData) {
          apiData.add({
            'institution': item['InstitutionName'],
            'department': item['DepartmentName'],
            'userName': item['UserName'],
            'whatsappNumber': item['WhatsappMobileNumber'],
            'vehicleNumber': item['VehicleFullNumber'],
            'vehicleType': item['VehicleType'],
            'travelFromTo': item['TravellingFromTO'],
            'departmentInChargePermission': item['DepartmentInChargePermission'],
            'rechargeAmount': item['RechargeAmount'].toString(),
            'requestDate': item['DateOfRequest'],
            'referenceNumber': item['ReferenceNo'],
            'status': item['Status'],
            'expiration': item['Expiration'].toString().toLowerCase(),
          });
        }

        setState(() {
          _apiData = apiData;
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

  Future<void> _fetchReferenceNumbers() async {
    final vehicleNumber = _normalizeString(_vehicleNumberController.text);
    final bool isConnected = await _checkInternetConnectivity();
    if (!isConnected) {
      setState(() {
        _errorMessage = 'No internet connection. Please check your network settings.';
      });
      return;
    }
    final referenceNumbers = _apiData
        .where((row) => _normalizeString(row['vehicleNumber']!) == vehicleNumber && row['expiration'] == 'no')
        .map((row) => row['referenceNumber']!)
        .toList();

    setState(() {
      _referenceNumbers = referenceNumbers;
      _selectedReferenceNumber = null;
      _selectedStatus = null;

      if (_apiData.any((row) => _normalizeString(row['vehicleNumber']!) == vehicleNumber)) {
        if (_referenceNumbers.isEmpty) {
          _errorMessage = 'Reference numbers associated with this vehicle are expired';
        } else {
          _errorMessage = null;
        }
      } else {
        _errorMessage = 'Vehicle Number Not Found';
      }
    });
  }

  void _fetchStatus() {
    final row = _apiData.firstWhere(
          (row) => _normalizeString(row['referenceNumber']!) == _normalizeString(_selectedReferenceNumber!),
      orElse: () => {},
    );

    setState(() {
      _selectedStatus = row.isNotEmpty ? row['status'] : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check Status'),
        backgroundColor: Colors.blue, // Customize app bar color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _vehicleNumberController,
              decoration: const InputDecoration(
                labelText: 'Vehicle Number',
                border: OutlineInputBorder(),
                hintText: 'Please Enter your Full Vehicle Number',
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _fetchReferenceNumbers,
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(Colors.blue), // Customize button color
              ),
              child: const Text('Fetch Reference Numbers'),
            ),
            const SizedBox(height: 16.0),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(fontSize: 16, color: Colors.red),
              )
            else if (_referenceNumbers.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue, width: 2.0),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    hint: const Text('Select Reference Number'),
                    value: _selectedReferenceNumber,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedReferenceNumber = newValue;
                      });
                    },
                    items: _referenceNumbers.map((referenceNumber) {
                      return DropdownMenuItem(
                        value: referenceNumber,
                        child: Text(referenceNumber),
                      );
                    }).toList(),
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                    dropdownColor: Colors.white,
                  ),
                ),
              ),
            const SizedBox(height: 16.0),
            if (_selectedReferenceNumber != null)
              ElevatedButton(
                onPressed: _fetchStatus,
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color>(Colors.blue), // Customize button color
                ),
                child: const Text('Submit'),
              ),
            const SizedBox(height: 16.0),
            if (_selectedReferenceNumber != null && _selectedStatus != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reference Number: $_selectedReferenceNumber',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Status: $_selectedStatus',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

void main() => runApp(const MaterialApp(home: CheckStatusPage()));
