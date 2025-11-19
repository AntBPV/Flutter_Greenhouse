class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class ChatRepository {
  final List<ChatMessage> messages = [];

  void addUserMessage(String text) {
    messages.add(ChatMessage(text: text, isUser: true));
  }

  void addBotMessage(String text) {
    messages.add(ChatMessage(text: text, isUser: false));
  }

  void clear() {
    messages.clear();
  }
}
