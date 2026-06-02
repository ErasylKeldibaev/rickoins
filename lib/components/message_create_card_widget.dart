import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/local_user_provider.dart';

class MessageCreateCardWidget extends StatefulWidget {
  const MessageCreateCardWidget({super.key});
  @override
  State<MessageCreateCardWidget> createState() => _MessageCreateCardWidgetState();
}

class _MessageCreateCardWidgetState extends State<MessageCreateCardWidget> {
  final TextEditingController _ctrl = TextEditingController();
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.read<UserProvider>();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: TextField(
        controller: _ctrl,
        onChanged: (text) => userProvider.updateMarketMessage(text),
        decoration: const InputDecoration(hintText: 'Your message...', border: InputBorder.none),
      ),
    );
  }
}