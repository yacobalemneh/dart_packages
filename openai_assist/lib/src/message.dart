class Message {
  final String role;
  final String content;

  Message({required this.role, required this.content});

  static List<Map<String, String>> formatMessages(List<Message> messages) {
    return messages
        .map((message) => {'role': message.role, 'content': message.content})
        .toList();
  }
}
