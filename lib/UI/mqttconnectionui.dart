import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../Connection/bloc/connection_bloc.dart';
import '../Database/connectionmodel.dart';
import '../Database/connectionsdb.dart';
import '../UI/chatui.dart';
import 'connectui.dart';

class ConnectionPage extends StatefulWidget {
  const ConnectionPage({Key? key}) : super(key: key);

  @override
  State<ConnectionPage> createState() => _ConnectionPageState();
}

class _ConnectionPageState extends State<ConnectionPage> {
  final Bloc connectionbloc = ConnectionBloc();
  List<Connection> connections = [];
  @override
  void initState() {
    super.initState();
    connectionbloc.add(Uievent());
    _loadConnections();
  }

  Future<void> _loadConnections() async {
    final dbhelper = DatabaseHelper();
    List<Connection> loadedConnections = await dbhelper.getConnections();
    setState(() {
      connections = loadedConnections;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Connect to MQTT",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Container(
                child: BlocConsumer(
                  bloc: connectionbloc,
                  listenWhen: (previous, current) =>
                      current is ConnectionAction,
                  buildWhen: (previous, current) =>
                      current is! ConnectionAction,
                  listener: (context, state) async {
                    if (state is ConnectedState) {
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Chatpage(
                                    client: state.client,
                                  )));
                      connectionbloc.add(Uievent());
                      _loadConnections();
                    }
                    // TODO: implement listener
                  },
                  builder: (context, state) {
                    switch (state.runtimeType) {
                      case ConnectingState:
                        return Container(
                          child: Center(
                            child: Column(
                              children: [
                                CircularProgressIndicator(),
                                Text("Connecting to MQTT")
                              ],
                            ),
                          ),
                        );
                      case Connectionerror:
                        final currentState = state as Connectionerror;
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  currentState.error,
                                  style: TextStyle(color: Colors.red),
                                ),
                                SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: () {
                                    connectionbloc
                                        .add(Uievent()); // Retry connection
                                  },
                                  child: Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        );
                      case ConnectionInitial:
                        return ConnectUI(
                          connectionbloc: connectionbloc,
                        );
                      default:
                        return Container();
                    }
                  },
                ),
              ),
              Divider(),
              Text(
                "Connections",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
              ),
              ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: connections.length,
                  itemBuilder: (context, index) {
                    Connection connection = connections[index];
                    return ListTile(
                      onTap: () {
                        connectionbloc.add(ConnectEvent(
                            host: connection.host,
                            password: connection.password,
                            port: connection.port,
                            user: connection.user,
                            certificate: connection.certificatePath.isNotEmpty
                                ? File(connection.certificatePath)
                                : _selectedfile));
                      },
                      trailing: Icon(Icons.connecting_airports),
                      title: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                            'Host: ${connection.host}\nPort: ${connection.port}'),
                      ),
                      // Add more details as needed
                    );
                  })
            ],
          ),
        ),
      ),
    );
  }

  File? _selectedfile;
}
