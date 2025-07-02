import 'package:flutter/material.dart';
import 'package:whatsapp_field/src/whatsapp_text_field.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: ChatExample(),
      ),
    );
  }
}

class ChatExample extends StatefulWidget {
  const ChatExample({super.key}); // ✅ Added key parameter

  @override
  State<ChatExample> createState() => _ChatExampleState();
}

class _ChatExampleState extends State<ChatExample> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _messages = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: _messages.map((msg) => ListTile(title: Text(msg))).toList(),
          ),
        ),
        WhatsAppTextField(
          controller: _controller,
        ),
      ],
    );
  }
}
