// lib/screens/chat_screen.dart
import 'package:flutter/material.dart';
import 'package:greenhouse/services/gemini_service.dart';
import 'package:greenhouse/repositories/chat_repository.dart';
import 'package:greenhouse/widgets/chat_bubble.dart';
import 'package:greenhouse/widgets/chat_input.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatRepository chatRepo = ChatRepository();
  late final GeminiService gemini;
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    gemini = GeminiService();
  }

  void scrollToEnd() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> sendMessage(String text) async {
    chatRepo.addUserMessage(text);
    setState(() {});
    scrollToEnd();

    final response = await gemini.sendMessage(text);

    chatRepo.addBotMessage(response);
    setState(() {});
    scrollToEnd();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Asistente de Invernaderos"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              chatRepo.clear();
              gemini.clearChat();
              setState(() {});
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: chatRepo.messages.length,
              itemBuilder: (context, index) {
                final msg = chatRepo.messages[index];
                return ChatBubble(text: msg.text, isUser: msg.isUser);
              },
            ),
          ),
          ChatInput(onSend: sendMessage),
        ],
      ),
    );
  }
}
