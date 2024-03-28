part of 'chat_bloc.dart';

@immutable
sealed class ChatState {}
abstract class ChatAction extends ChatState{}
final class ChatInitial extends ChatState {}
final class ChatLoaded extends ChatState{}
final class Chatsent extends ChatAction{}
final class Chatrecived extends ChatAction{}