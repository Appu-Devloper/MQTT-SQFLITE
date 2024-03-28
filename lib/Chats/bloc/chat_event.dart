part of 'chat_bloc.dart';

@immutable
sealed class ChatEvent {}
class ChatInitialEvent extends ChatEvent{}
class ChatDisconnectEvent extends ChatEvent{}