import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class PhysicalValidation extends StatefulWidget {
  @override
  _PhysicalValidationState createState() =>   _PhysicalValidationState();
}

class _PhysicalValidationState extends State<PhysicalValidation> {
  List<dynamic> _receivedQ1 = [];
  String _receivedQ2 = '';
  String _selectedOption = '';
  TextEditingController _otherController = TextEditingController();
  String _selectedDropdownValue = ''; // Initialize with an empty string

  List<String> _physicalActivityOptions = ['Light', 'Moderate', 'Heavy'];

  @override
  void initState() {
    super.initState();
    _fetchDataFromServer();
  }

  Future<void> _fetchDataFromServer() async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/api/get_physical_activity'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'example_key': 'example_value'}), // Example data
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final receivedQ1 =
            jsonData['Q1']; // Assuming 'Q1' is the key for received data
        final receivedQ2 =
            jsonData['Q2']; // Assuming 'Q2' is the key for received data

        if (receivedQ1 != null && receivedQ2 != null) {
          setState(() {
            _receivedQ1 = receivedQ1;
            _receivedQ2 = receivedQ2;

            // Update the dropdown options based on the received data
            if (receivedQ2 == 'light') {
              _physicalActivityOptions = ['Light', 'Moderate', 'Heavy'];
            } else if (receivedQ2 == 'moderate') {
              _physicalActivityOptions = ['Moderate', 'Light', 'Heavy'];
            } else if (receivedQ2 == 'heavy') {
              _physicalActivityOptions = ['Heavy','Moderate', 'Light'];
            }

            // If _receivedQ2 is not present in _physicalActivityOptions, set it to a default value
            if (!_physicalActivityOptions.contains(_receivedQ2)) {
              _receivedQ2 = _physicalActivityOptions.first;
            }
          });
        } else {
          throw Exception('Received data is null');
        }
      } else {
        final errorMessage = json.decode(response.body)['error'];
        throw Exception('Failed to fetch data from server: $errorMessage');
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        _receivedQ1 = [];
        _receivedQ2 = 'Error: $e';
      });
    }
  }

  Future<void> _submitData() async {
    try {
      String physicalActivity = _selectedDropdownValue.isNotEmpty
          ? _selectedDropdownValue
          : _physicalActivityOptions.first;

      final data = {
        'selected_option': _selectedOption,
        'physical_activity': physicalActivity,
      };

      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/api/submit_physical_activity'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        // Handle successful submission
        print('Data submitted successfully');
      } else {
        final errorMessage = json.decode(response.body)['error'];
        throw Exception('Failed to submit data: $errorMessage');
      }
    } catch (e) {
      print('Error submitting data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Validate the Data',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Colors.white, // Use color code from secondary color
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color(0XFF625B71), // Use primary color code
      ),
      body: Container(
        color: Color(0xFFF3F3F3), // Use scaffoldBackgroundColor code
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'What was the time duration of your workout (in minutes)?',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Color(0XFF625B71), // Use primary color code
                  letterSpacing: 1.1,
                ),
              ),
              SizedBox(height: 16),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: _buildOptions(),
              ),
              SizedBox(height: 25),
              Text(
                'Was it a light, heavy or a heavy workout?',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Color(0XFF625B71), // Use primary color code
                  letterSpacing: 1.1,
                ),
              ),
              SizedBox(height: 10,),
              DropdownButtonFormField<String>(
                value: _physicalActivityOptions.contains(_selectedDropdownValue)
                    ? _selectedDropdownValue
                    : _physicalActivityOptions.first,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedDropdownValue = newValue!;
                  });
                },
                items: _physicalActivityOptions
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(
                        color: Color(0XFF625B71), // Use primary color code
                      ),
                    ),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Workout Intensity',
                  labelStyle: TextStyle(
                    color: Color(0XFF625B71), // Use primary color code
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                      color: Color(0xFF0067FF), // Use outline color code
                    ),
                  ),
                ),
              ),
              SizedBox(height: 25),
              Center(
                child: ElevatedButton(
                  onPressed: _submitData,
                  child: Text(
                    'Submit',
                    style: TextStyle(
                      color:
                          Colors.white, // Use color code from secondary color
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Color(0XFF625B71), // Use primary color code
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildOptions() {
    List<Widget> options = [];

    for (var option in _receivedQ1) {
      options.add(
        ListTile(
          title: Text('$option'),
          leading: Radio<String>(
            value: '$option',
            groupValue: _selectedOption,
            onChanged: (value) {
              setState(() {
                _selectedOption = value!;
                _otherController
                    .clear(); // Clear the text field if a new option is selected
              });
            },
          ),
        ),
      );
    }

    // Add the entered value as a new option
    if (_otherController.text.isNotEmpty) {
      options.add(
        ListTile(
          title: Text(_otherController.text),
          leading: Radio<String>(
            value: _otherController.text,
            groupValue: _selectedOption,
            onChanged: (value) {
              setState(() {
                _selectedOption = value!;
              });
            },
          ),
        ),
      );
    }

    options.add(
      ListTile(
        title: _selectedOption == 'Other'
            ? Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _otherController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Enter your workout intensity in minutes.',
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        // No need to update _selectedOption here
                      });
                    },
                    child: Text('Done'),
                  ),
                ],
              )
            : Text('Other'),
        leading: Radio<String>(
          value: 'Other',
          groupValue: _selectedOption,
          onChanged: (value) {
            setState(() {
              _selectedOption = value!;
              if (_selectedOption == 'Other') {
                // Restore previously entered number if any
                _otherController.text = _selectedOption;
              }
            });
          },
        ),
      ),
    );

    return options;
  }
}