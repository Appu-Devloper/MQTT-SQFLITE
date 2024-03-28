part of 'connection_bloc.dart';

@immutable
abstract class ConnectionState {}
final class ConnectionInitial extends ConnectionState{}
abstract class ConnectionAction extends ConnectionState{}
final class InitialState extends ConnectionState {
  final String host;
  final String port;
  final String user;
  final String password;
  final String subscribe;
  final String publish;
  InitialState({required this.host,required this.password,required this.port,required this.publish,required this.subscribe,required this.user});
}
final class ConnectingState extends ConnectionState{}
final class ConnectedState extends ConnectionAction{
  final MqttServerClient client;
  ConnectedState({required this.client});
}
final class Connectionerror extends ConnectionState{
  final String error;
  Connectionerror({required this.error});
}