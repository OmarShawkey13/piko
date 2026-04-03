abstract class ChatStates {}

class ChatInitialState extends ChatStates {}

class ChatSendSuccessState extends ChatStates {}

class ChatSendErrorState extends ChatStates {
  final String error;
  ChatSendErrorState(this.error);
}

class ChatReplyingMessageChangedState extends ChatStates {}

class ChatBackgroundChangedState extends ChatStates {}

class ChatDeleteMessageSuccessState extends ChatStates {}

class ChatDeleteMessageErrorState extends ChatStates {
  final String error;
  ChatDeleteMessageErrorState(this.error);
}

class ChatUrlDetectedState extends ChatStates {
  final String? url;
  ChatUrlDetectedState(this.url);
}

class ChatSelectionModeChangedState extends ChatStates {}

class ChatSearchToggleState extends ChatStates {
  final bool isSearchActive;
  ChatSearchToggleState(this.isSearchActive);
}

class ChatSearchResultsUpdatedState extends ChatStates {
  final List<String> resultIds;
  final int currentIndex;
  final String query;
  ChatSearchResultsUpdatedState({
    required this.resultIds,
    required this.currentIndex,
    required this.query,
  });
}
