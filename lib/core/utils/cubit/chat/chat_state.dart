import 'package:piko/core/models/message_model.dart';

abstract class ChatStates {}

class ChatInitialState extends ChatStates {}

class ChatMessagesLoadingState extends ChatStates {}

class ChatMessagesSuccessState extends ChatStates {
  final List<MessageModel> messages;
  ChatMessagesSuccessState(this.messages);
}

class ChatBackgroundChangedState extends ChatStates {}

class ChatSendSuccessState extends ChatStates {}

class ChatSendErrorState extends ChatStates {
  final String error;
  ChatSendErrorState(this.error);
}

class ChatUploadImageLoadingState extends ChatStates {}

class ChatUploadImageSuccessState extends ChatStates {
  final String imageUrl;
  ChatUploadImageSuccessState(this.imageUrl);
}

class ChatUploadImageErrorState extends ChatStates {
  final String error;
  ChatUploadImageErrorState(this.error);
}

class TypingStatusChangedState extends ChatStates {}

class ChatReplyingMessageChangedState extends ChatStates {}

class ChatDeleteMessageSuccessState extends ChatStates {}

class ChatDeleteMessageErrorState extends ChatStates {
  final String error;
  ChatDeleteMessageErrorState(this.error);
}
