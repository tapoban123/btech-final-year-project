import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class LoadChatData extends ChatEvent {
  const LoadChatData();
}

class SendChatMessage extends ChatEvent {
  final String text;

  const SendChatMessage(this.text);

  @override
  List<Object?> get props => [text];
}

class SubmitMessageFeedback extends ChatEvent {
  final String messageId;
  final bool isAccurate;

  const SubmitMessageFeedback({
    required this.messageId,
    required this.isAccurate,
  });

  @override
  List<Object?> get props => [messageId, isAccurate];
}

class SelectQuickPromptChip extends ChatEvent {
  final String prompt;

  const SelectQuickPromptChip(this.prompt);

  @override
  List<Object?> get props => [prompt];
}
