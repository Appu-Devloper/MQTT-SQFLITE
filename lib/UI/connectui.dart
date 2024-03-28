import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:path/path.dart' as path;
import '../Connection/bloc/connection_bloc.dart';

class ConnectUI extends StatefulWidget {
  final Bloc connectionbloc;

  const ConnectUI({super.key, required this.connectionbloc});

  @override
  State<ConnectUI> createState() => _ConnectUIState();
}

class _ConnectUIState extends State<ConnectUI> {
  bool _validateInputs() {
    // Validate all input fields
    if (_hostController.text.isEmpty || _portController.text.isEmpty) {
      // Show error message for any empty field
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All fields are mandatory'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    return true;
  }

  final TextEditingController _hostController = TextEditingController();
  final TextEditingController _portController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool secureConnection = false;
  File? selectedFile;
  Future<void> _openFileExplorer() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
      });
    }
  }

  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed
    _hostController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _hostController,
                decoration: const InputDecoration(
                  labelText: 'Host *',
                  hintText: 'Enter host address',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter host address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _portController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Port *',
                  hintText: 'Enter port number',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter port number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  hintText: 'Enter username',
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter password',
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Checkbox(
                    value: secureConnection,
                    onChanged: (value) {
                      setState(() {
                        secureConnection = value ?? false;
                      });
                    },
                  ),
                  Text('Secure Connection'),
                ],
              ),
              if (secureConnection)
                ElevatedButton(
                  onPressed: () {
                    _openFileExplorer();
                  },
                  child: Text(selectedFile == null
                      ? 'Select Certificate File'
                      : 'File Selected: ${path.basename(selectedFile!.path)}'),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_validateInputs()) {
                    // All inputs are valid, proceed with connection logic
                    String host = _hostController.text;
                    String port = _portController.text;
                    String username = _usernameController.text;
                    String password = _passwordController.text;

                    // Perform connection logic with host, port, username, and password
                    // Also, use subscribeTopic and publishTopic
                    widget.connectionbloc.add(ConnectEvent(
                        host: host,
                        password: password,
                        port: port,
                        user: username,
                        certificate: selectedFile));
                  }
                },
                child: const Text("Connect"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
