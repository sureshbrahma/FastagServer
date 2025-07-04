import 'package:BKFASTAG/welcome_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:upgrader/upgrader.dart';

class FastagForm extends StatefulWidget {
  const FastagForm({super.key});

  @override
  _FastagFormState createState() => _FastagFormState();
}

class _FastagFormState extends State<FastagForm> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedInstitution = 'Please select an institution';
  String? _department;
  String? _userName;
  String? _whatsappNumber;
  String? _vehicleNumber;
  String? _vehicleType = 'Please select vehicle type';
  String? _travelFromTo;
  String? _departmentInChargePermission;
  String? _rechargeAmount;
  DateTime? _requestDate;

  final _institutionFocusNode = FocusNode();
  final _departmentFocusNode = FocusNode();
  final _userNameFocusNode = FocusNode();
  final _whatsappNumberFocusNode = FocusNode();
  final _vehicleNumberFocusNode = FocusNode();
  final _vehicleTypeFocusNode = FocusNode();
  final _travelFromToFocusNode = FocusNode();
  final _departmentInChargePermissionFocusNode = FocusNode();
  final _rechargeAmountFocusNode = FocusNode();
  final _requestDateFocusNode = FocusNode();
  final TextEditingController _vehicleNumberController = TextEditingController();

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _requestDate) {
      setState(() {
        _requestDate = picked;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _vehicleNumberController.addListener(() {
      _validateVehicleNumber(_vehicleNumberController.text);
    });
  }

  void _validateVehicleNumber(String input) {
    if (input.contains(RegExp(r'[^A-Za-z0-9]'))) {
      _showSnackbar(
          'Vehicle number should not contain spaces or special characters');
    }
  }

  void _validateForm() async {
    if (_selectedInstitution == null ||
        _selectedInstitution!.trim().isEmpty ||
        _selectedInstitution == 'Please select an institution') {
      _showSnackbar('Please select an institution');
      FocusScope.of(context).requestFocus(_institutionFocusNode);
      return;
    }
    if (_department == null || _department!.trim().isEmpty) {
      _showSnackbar('Please enter the department name');
      FocusScope.of(context).requestFocus(_departmentFocusNode);
      return;
    }
    if (_userName == null || _userName!.trim().isEmpty) {
      _showSnackbar('Please enter the user name');
      FocusScope.of(context).requestFocus(_userNameFocusNode);
      return;
    }
    if (_whatsappNumber == null || _whatsappNumber!.trim().isEmpty) {
      _showSnackbar('Please enter the WhatsApp mobile number');
      FocusScope.of(context).requestFocus(_whatsappNumberFocusNode);
      return;
    }
    if (_vehicleNumber == null || _vehicleNumber!.trim().isEmpty) {
      _showSnackbar('Please enter your vehicle number');
      FocusScope.of(context).requestFocus(_vehicleNumberFocusNode);
      return;
    } else if (!RegExp(r'^[A-Za-z0-9]+$').hasMatch(_vehicleNumber!)) {
      _showSnackbar(
          'Vehicle number should not contain spaces or special characters');
      FocusScope.of(context).requestFocus(_vehicleNumberFocusNode);
      return;
    }
    if (_vehicleType == null ||
        _vehicleType!.trim().isEmpty ||
        _vehicleType == 'Please select vehicle type') {
      _showSnackbar('Please select the type of vehicle');
      FocusScope.of(context).requestFocus(_vehicleTypeFocusNode);
      return;
    }
    if (_travelFromTo == null || _travelFromTo!.trim().isEmpty) {
      _showSnackbar('Please enter the travel details');
      FocusScope.of(context).requestFocus(_travelFromToFocusNode);
      return;
    }
    if (_departmentInChargePermission == null ||
        _departmentInChargePermission!.trim().isEmpty) {
      _showSnackbar('Please enter the permission details');
      FocusScope.of(context)
          .requestFocus(_departmentInChargePermissionFocusNode);
      return;
    }
    if (_rechargeAmount == null || _rechargeAmount!.trim().isEmpty) {
      _showSnackbar('Please enter the recharge amount');
      FocusScope.of(context).requestFocus(_rechargeAmountFocusNode);
      return;
    }
    final int? amount = int.tryParse(_rechargeAmount!);
    if (amount == null || amount < 100) {
      _showSnackbar('Minimum recharge amount is Rs. 100');
      FocusScope.of(context).requestFocus(_rechargeAmountFocusNode);
      return;
    }
    if (_requestDate == null) {
      _showSnackbar('Please select the date of request');
      FocusScope.of(context).requestFocus(_requestDateFocusNode);
      return;
    }

    if (_vehicleNumber != null && _vehicleNumber!.isNotEmpty) {
      Map<String, dynamic> vehicleData = await _checkVehicleNumberAndExpiration(
          _vehicleNumber!);
      if (vehicleData['VehicleFullNumber'] != '') { // Vehicle exists
        if (vehicleData['Expiration'] == 'NO') {
          _showSnackbar(
              'Error: Request already exists for this vehicle number  Please try after 3 days Again');
          return;
        }
      }
    }

    _showPreviewDialog();
  }

  void _showPreviewDialog() {
    String message = 'INSTITUTION: ${_selectedInstitution?.toUpperCase()}\n'
        'DEPARTMENT: ${_department?.toUpperCase()}\n'
        'USER NAME: ${_userName?.toUpperCase()}\n'
        'WHATSAPP NUMBER: ${_whatsappNumber?.toUpperCase()}\n'
        'VEHICLE NUMBER: ${_vehicleNumber?.toUpperCase()}\n'
        'VEHICLE TYPE: ${_vehicleType?.toUpperCase()}\n'
        'TRAVEL FROM-TO: ${_travelFromTo?.toUpperCase()}\n'
        'PERMISSION: ${_departmentInChargePermission?.toUpperCase()}\n'
        'RECHARGE AMOUNT: ${_rechargeAmount?.toUpperCase()}\n'
        'REQUEST DATE: ${_requestDate != null ? DateFormat('dd-MM-yyyy').format(
        _requestDate!).toUpperCase() : ''}';
    final referenceNumber = _generateReferenceNumber();
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
                _sendDataToServer(referenceNumber);
              },
            ),
          ],
        );
      },
    );
  }

  String _generateReferenceNumber() {
    final now = DateTime.now();
    return 'REF-${now.year}${now.month}${now.day}${now.hour}${now.minute}${now
        .second}';
  }

  void _sendDataToServer(final referenceNumber) async {
    var connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult == ConnectivityResult.none) {
      // No internet connection
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'No internet connection. Please check your connection and try again.'),
        ),
      );
      return;
    }

    final formData = {
      'InstitutionName': _selectedInstitution,
      'DepartmentName': _department,
      'UserName': _userName,
      'WhatsappMobileNumber': _whatsappNumber,
      'VehicleFullNumber': _vehicleNumber,
      'VehicleType': _vehicleType,
      'TravellingFromTo': _travelFromTo,
      'DepartmentInChargePermission': _departmentInChargePermission,
      'RechargeAmount': _rechargeAmount,
      'DateOfRequest': _requestDate != null
          ? DateFormat('yyyy-MM-dd').format(_requestDate!)
          : '',
      'ReferenceNumber': referenceNumber,
    };

    const url = 'https://bkaccanmol.bkapp.org/api/values'; // Replace with your actual API URL

    try {
      // Send the POST request
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(formData),
      );

      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, show a success message
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Row(
                children: [
                  Text(
                    '✌️', // Victory hand emoji
                    style: TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Success',
                    style: TextStyle(color: Colors.blue),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '😄', // Wide grin emoji
                    style: TextStyle(fontSize: 24),
                  ),
                ],
              ),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your request for Fastag Recharge submitted successfully.\n'
                        'Your Request Reference Number is: $referenceNumber',
                    style: const TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'RECHARGE WILL BE DONE WITHIN 24 HOURS',
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please Check Status of your Request Within Three Days. After 3 days, status will be Expired.',
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const WelcomePage()),
                    );
                  },
                ),
              ],
            );
          },
        );
      } else {
        // If the server did not return a 200 OK response, throw an error.
        throw Exception('Failed to submit data');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting form: $error'),
        ),
      );
    }
  }

  Future<Map<String, dynamic>> _checkVehicleNumberAndExpiration(
      String vehicleNumber) async {
    final response = await http.get(
        Uri.parse('https://bkaccanmol.bkapp.org/api/values'));

    if (response.statusCode == 200) {
      // Decode the JSON response
      List<dynamic> allRecords = json.decode(response.body);

      // Find the record matching the vehicle number
      var record = allRecords.lastWhere(
              (element) =>
          element['VehicleFullNumber']
              ?.toString()
              .toUpperCase() == vehicleNumber.toUpperCase(),
          orElse: () => null
      );

      if (record != null) {
        return {
          'VehicleFullNumber': record['VehicleFullNumber'] ?? '',
          'Expiration': record['Expiration'] ?? 'UNKNOWN'
        };
      } else {
        return {'VehicleFullNumber': '', 'Expiration': 'NOT_FOUND'};
      }
    } else {
      throw Exception('Failed to load vehicle data');
    }
  }

  @override
  void dispose() {
    _vehicleNumberController.dispose();
    _institutionFocusNode.dispose();
    _departmentFocusNode.dispose();
    _userNameFocusNode.dispose();
    _whatsappNumberFocusNode.dispose();
    _vehicleNumberFocusNode.dispose();
    _vehicleTypeFocusNode.dispose();
    _travelFromToFocusNode.dispose();
    _departmentInChargePermissionFocusNode.dispose();
    _rechargeAmountFocusNode.dispose();
    _requestDateFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      dialogStyle: UpgradeDialogStyle.cupertino,
      showIgnore: false,
      showLater: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('FASTAG Recharges Requisition Form'),
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
                    'FASTAG Recharges Requisition Form',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  const Text(
                      'Name of Institution (Only for BK & WRST Vehicles, Not for RERF)',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  DropdownButtonFormField<String>(
                    value: _selectedInstitution,
                    focusNode: _institutionFocusNode,
                    items: const [
                      DropdownMenuItem(
                        value: 'Please select an institution',
                        child: Text('Please select an institution'),
                      ),
                      DropdownMenuItem(
                        value: 'BRAHMAKUMARIS',
                        child: Text('BRAHMAKUMARIS'),
                      ),
                      DropdownMenuItem(
                        value: 'W.R.S.T.',
                        child: Text('W.R.S.T.'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedInstitution = value;
                      });
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  const Text('Name of Department',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextFormField(
                    focusNode: _departmentFocusNode,
                    onChanged: (value) {
                      setState(() {
                        _department = value.toUpperCase();
                      });
                    },
                    inputFormatters: [
                      TextInputFormatter.withFunction(
                            (oldValue, newValue) =>
                            TextEditingValue(text: newValue.text.toUpperCase(),
                                selection: newValue.selection),
                      ),
                    ],
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter department name',
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  const Text('User Name',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextFormField(
                    focusNode: _userNameFocusNode,
                    onChanged: (value) {
                      setState(() {
                        _userName = value.toUpperCase();
                      });
                    },
                    inputFormatters: [
                      TextInputFormatter.withFunction(
                            (oldValue, newValue) =>
                            TextEditingValue(text: newValue.text.toUpperCase(),
                                selection: newValue.selection),
                      ),
                    ],
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter user name',
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  const Text('WhatsApp Number',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextFormField(
                    focusNode: _whatsappNumberFocusNode,
                    onChanged: (value) {
                      setState(() {
                        _whatsappNumber = value;
                      });
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter WhatsApp number',
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  const Text('Vehicle Number',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextFormField(
                    controller: _vehicleNumberController,
                    focusNode: _vehicleNumberFocusNode,
                    onChanged: (value) {
                      setState(() {
                        _vehicleNumber = value.toUpperCase();
                      });
                    },
                    inputFormatters: [
                      TextInputFormatter.withFunction(
                            (oldValue, newValue) =>
                            TextEditingValue(text: newValue.text.toUpperCase(),
                                selection: newValue.selection),
                      ),
                    ],
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter your vehicle number',
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  const Text('Vehicle Type',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  DropdownButtonFormField<String>(
                    value: _vehicleType,
                    focusNode: _vehicleTypeFocusNode,
                    items: const [
                      DropdownMenuItem(
                        value: 'Please select vehicle type',
                        child: Text('Please select vehicle type'),
                      ),
                      DropdownMenuItem(
                        value: 'CAR',
                        child: Text('CAR'),
                      ),
                      DropdownMenuItem(
                        value: 'BUS',
                        child: Text('BUS'),
                      ),
                      DropdownMenuItem(
                        value: 'TRUCK',
                        child: Text('TRUCK'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _vehicleType = value;
                      });
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  const Text('Travel From - To',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextFormField(
                    focusNode: _travelFromToFocusNode,
                    onChanged: (value) {
                      setState(() {
                        _travelFromTo = value.toUpperCase();
                      });
                    },
                    inputFormatters: [
                      TextInputFormatter.withFunction(
                            (oldValue, newValue) =>
                            TextEditingValue(text: newValue.text.toUpperCase(),
                                selection: newValue.selection),
                      ),
                    ],
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter travel details',
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  const Text('Department In-Charge Permission',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextFormField(
                    focusNode: _departmentInChargePermissionFocusNode,
                    onChanged: (value) {
                      setState(() {
                        _departmentInChargePermission = value.toUpperCase();
                      });
                    },
                    inputFormatters: [
                      TextInputFormatter.withFunction(
                            (oldValue, newValue) =>
                            TextEditingValue(text: newValue.text.toUpperCase(),
                                selection: newValue.selection),
                      ),
                    ],
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter permission details',
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  const Text('Recharge Amount (in INR)',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextFormField(
                    focusNode: _rechargeAmountFocusNode,
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _rechargeAmount = value;
                      });
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter recharge amount',
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  const Text('Request Date',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  InkWell(
                    onTap: () {
                      _selectDate(context);
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _requestDate == null
                                ? 'Select request date'
                                : DateFormat('dd-MM-yyyy').format(
                                _requestDate!),
                          ),
                          const Icon(Icons.calendar_today),
                        ],
                      ),
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
      ),
    );
  }
}