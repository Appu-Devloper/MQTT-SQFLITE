part of 'connection_bloc.dart';

@immutable
sealed class ConnectionEvent {}
final class Uievent extends ConnectionEvent{}
final class ConnectEvent extends ConnectionEvent{
  final String host;
  final String port;
  final String user;
  final String password;
  final File? certificate;
  ConnectEvent({required this.host,required this.password,required this.port,required this.user, this.certificate});
}
