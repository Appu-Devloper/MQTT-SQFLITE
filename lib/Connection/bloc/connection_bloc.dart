import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import '../../Database/connectionmodel.dart';
import '../../Database/connectionsdb.dart';
part 'connection_event.dart';
part 'connection_state.dart';

String generateClientId() {
  var rng = Random.secure();
  var bytes = List<int>.generate(16, (i) => rng.nextInt(256));
  return base64UrlEncode(bytes);
}

class ConnectionBloc extends Bloc<ConnectionEvent, ConnectionState> {
  ConnectionBloc() : super(ConnectionInitial()) {
    on<ConnectEvent>(_connectevent);
    on<Uievent>(_uievent);
  }

  FutureOr<void> _connectevent(
      ConnectEvent event, Emitter<ConnectionState> emit) async {
    emit(ConnectingState());

    String clientId = generateClientId();

    MqttServerClient client = await MqttServerClient(event.host, clientId);
    client.port = int.parse(event.port);
    client.autoReconnect = true;
    if (event.certificate != null) {
      // Read certificate text from file
      client.onBadCertificate = (dynamic data) {
        return true;
      };
      String certificateText =
          await File(event.certificate!.path).readAsString();
      final securityContext = SecurityContext.defaultContext;
      securityContext.useCertificateChainBytes(
          Uint8List.fromList(certificateText.codeUnits));
      client.securityContext = securityContext;
      client.secure = true;
    }

    // Listener to handle client disconnect
    // client.onDisconnected = () {
    //   emit(ConnectionInitial());
    // };

    try {
      if (event.user.isNotEmpty && event.password.isNotEmpty) {
        await client.connect(event.user, event.password);
      } else {
        await client.connect();
      }
      print(client.connectionMessage);
      final dbhelper=DatabaseHelper();
      await dbhelper.initDatabase();
      await dbhelper.insertConnection(Connection(
        clientId: clientId,
        host: event.host,
        port: event.port,
        user: event.user,
        password: event.password,
        certificatePath: event.certificate?.path ?? '',
      ));
      emit(ConnectedState(client: client));
    } catch (e) {
      print('Exception: $e');
      client.disconnect();
      emit(Connectionerror(error: 'Exception: $e'));
    }
  }

  FutureOr<void> _uievent(Uievent event, Emitter<ConnectionState> emit) {
    emit(ConnectionInitial());
  }
}
