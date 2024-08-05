import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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

  void _validateForm() {
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
      _showSnackbar('Vehicle number should not contain spaces or special characters');
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
      FocusScope.of(context).requestFocus(_departmentInChargePermissionFocusNode);
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
    _showPreviewDialog();
  }

  void _showPreviewDialog() {
    String message = 'Institution: $_selectedInstitution\n'
        'Department: $_department\n'
        'User Name: $_userName\n'
        'WhatsApp Number: $_whatsappNumber\n'
        'Vehicle Number: $_vehicleNumber\n'
        'Vehicle Type: $_vehicleType\n'
        'Travel From-To: $_travelFromTo\n'
        'Permission: $_departmentInChargePermission\n'
        'Recharge Amount: $_rechargeAmount\n'
        'Request Date: ${_requestDate != null ? DateFormat('dd-MM-yyyy').format(_requestDate!) : ''}';
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
    return 'REF-${now.year}${now.month}${now.day}${now.hour}${now.minute}${now.second}';
  }

  void _sendDataToServer(final referenceNumber) async {
    // Prepare the form data

    final formData = {
      'InstitutionName': _selectedInstitution,
      'DepartmentName': _department,
      'UserName': _userName,
      'WhatsappMobileNumber': _whatsappNumber,
      'VehicleFullNumber': _vehicleNumber,
      'VehicleType': _vehicleType,
      'TravellingFromTo': _travelFromTo,
      'DepartmentInChargePermission': _departmentInChargePermission ,
      'RechargeAmount': _rechargeAmount,
      'DateOfRequest': _requestDate != null ? DateFormat('yyyy-MM-dd').format(_requestDate!) : '',
      'ReferenceNumber': referenceNumber,
    };

    // URL of your API endpoint
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
              title: const Text('Success'),
              content: Text('Your request for Fastag Recharge submitted successfully.\n Your Request  Reference Number is: $referenceNumber \n Please Check Status of your Request With in Three Days.After 3 days status will be Expired'),
              actions: [
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Navigate to welcome page or any other page after successful submission
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



  @override
  void dispose() {
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
    return Scaffold(
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
                const Text('Name of Institution (Only for BK & WRST Vehicles, Not for RERF)',
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
                      _department = value;
                    });
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter department name',
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16.0),
                const Text('User Name', style: TextStyle(fontWeight: FontWeight.bold)),
                TextFormField(
                  focusNode: _userNameFocusNode,
                  onChanged: (value) {
                    setState(() {
                      _userName = value;
                    });
                  },
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
                  focusNode: _vehicleNumberFocusNode,
                  onChanged: (value) {
                    setState(() {
                      _vehicleNumber = value;
                    });
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter vehicle number',
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16.0),
                const Text('Vehicle Type', style: TextStyle(fontWeight: FontWeight.bold)),
                DropdownButtonFormField<String>(
                  value: _vehicleType,
                  focusNode: _vehicleTypeFocusNode,
                  items: const [
                    DropdownMenuItem(
                      value: 'Please select vehicle type',
                      child: Text('Please select vehicle type'),
                    ),
                    DropdownMenuItem(
                      value: 'Car',
                      child: Text('Car'),
                    ),
                    DropdownMenuItem(
                      value: 'Bus',
                      child: Text('Bus'),
                    ),
                    DropdownMenuItem(
                      value: 'Truck',
                      child: Text('Truck'),
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
                const Text('Travel From - To', style: TextStyle(fontWeight: FontWeight.bold)),
                TextFormField(
                  focusNode: _travelFromToFocusNode,
                  onChanged: (value) {
                    setState(() {
                      _travelFromTo = value;
                    });
                  },
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
                      _departmentInChargePermission = value;
                    });
                  },
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
                const Text('Request Date', style: TextStyle(fontWeight: FontWeight.bold)),
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
                              : DateFormat('dd-MM-yyyy').format(_requestDate!),
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
    );
  }
}