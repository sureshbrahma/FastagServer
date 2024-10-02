import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChangeMobileNumberPage extends StatefulWidget {
  const ChangeMobileNumberPage({super.key});

  @override
  _ChangeMobileNumberPageState createState() => _ChangeMobileNumberPageState();
}

class _ChangeMobileNumberPageState extends State<ChangeMobileNumberPage> {
  final _formKey = GlobalKey<FormState>();
  final _vehicleNumberController = TextEditingController();
  final _oldMobileNumberController = TextEditingController();
  final _newMobileNumberController = TextEditingController();

  final _vehicleNumberFocusNode = FocusNode();
  final _oldMobileNumberFocusNode = FocusNode();
  final _newMobileNumberFocusNode = FocusNode();

  @override
  void dispose() {
    _vehicleNumberController.dispose();
    _oldMobileNumberController.dispose();
    _newMobileNumberController.dispose();
    _vehicleNumberFocusNode.dispose();
    _oldMobileNumberFocusNode.dispose();
    _newMobileNumberFocusNode.dispose();
    super.dispose();
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _validateForm() {
    if (_vehicleNumberController.text.trim().isEmpty) {
      _showSnackbar('Please enter vehicle number');
      FocusScope.of(context).requestFocus(_vehicleNumberFocusNode);
      return;
    } else if (!RegExp(r'^[A-Za-z0-9]+$').hasMatch(_vehicleNumberController.text)) {
      _showSnackbar('Vehicle number should not contain spaces or special characters');
      FocusScope.of(context).requestFocus(_vehicleNumberFocusNode);
      return;
    }
    if (_oldMobileNumberController.text.trim().isEmpty) {
      _showSnackbar('Please enter old mobile number');
      FocusScope.of(context).requestFocus(_oldMobileNumberFocusNode);
      return;
    }
    if (_newMobileNumberController.text.trim().isEmpty) {
      _showSnackbar('Please enter new mobile number');
      FocusScope.of(context).requestFocus(_newMobileNumberFocusNode);
      return;
    }

    _showPreviewDialog();
  }

  void _showPreviewDialog() {
    String message = 'Vehicle Number: ${_vehicleNumberController.text}\n'
        'Old Mobile Number: ${_oldMobileNumberController.text}\n'
        'New Mobile Number: ${_newMobileNumberController.text}';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Preview Details'),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('Edit'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Confirm'),
              onPressed: () {
                Navigator.of(context).pop();
                _sendDataToServer();
              },
            ),
          ],
        );
      },
    );
  }


  void _sendDataToServer() async {
    var connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult == ConnectivityResult.none) {
      // No internet connection
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No internet connection. Please check your connection and try again.'),
        ),
      );
      return;
    }
    final formData = {
      'VehicleNumber': _vehicleNumberController.text,
      'OldMobileNumber': _oldMobileNumberController.text,
      'NewMobileNumber': _newMobileNumberController.text,

    };

    const url = 'https://bkaccanmol.bkapp.org/api/change'; // Replace with your actual API URL

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(formData),
      );

      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Success'),
              content: const Text('Your mobile number change request has been submitted successfully.'),
              actions: [
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else {
        throw Exception('Failed to submit data');
      }
    } catch (error) {
      _showSnackbar('Error submitting form: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fastag Mobile Number Change Request'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.cyan,
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0, 2),
                  blurRadius: 4.0,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Fastag Mobile Number Change Request ',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16.0),
                const Text('Vehicle Number', style: TextStyle(fontWeight: FontWeight.bold)),
                TextFormField(
                  controller: _vehicleNumberController,
                  focusNode: _vehicleNumberFocusNode,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter vehicle number',
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16.0),
                const Text('Old Mobile Number', style: TextStyle(fontWeight: FontWeight.bold)),
                TextFormField(
                  controller: _oldMobileNumberController,
                  focusNode: _oldMobileNumberFocusNode,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter old mobile number',
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16.0),
                const Text('New Mobile Number', style: TextStyle(fontWeight: FontWeight.bold)),
                TextFormField(
                  controller: _newMobileNumberController,
                  focusNode: _newMobileNumberFocusNode,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter new mobile number',
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 24.0),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _validateForm();
                      }
                    },
                    child: const Text('Submit'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
