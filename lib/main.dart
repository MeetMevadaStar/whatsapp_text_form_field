import 'package:flutter/material.dart';
import 'package:whatsapp_field/model/attachment_model.dart';
import 'package:whatsapp_field/src/whatsapp_text_field.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: ChatExample(),
      ),
    );
  }
}

class ChatExample extends StatefulWidget {
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
