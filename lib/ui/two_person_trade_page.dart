import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';

import '../states/local_user_provider.dart';

class TwoPersonTradePage extends StatefulWidget {
  final String targetUid;
  final String targetNickname;

  const TwoPersonTradePage({
    super.key,
    required this.targetUid,
    required this.targetNickname,
  });

  @override
  State<TwoPersonTradePage> createState() => _TwoPersonTradePageState();
}

class _TwoPersonTradePageState extends State<TwoPersonTradePage> {
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  Map<String, dynamic>? _partnerData;
  List<Map<String, dynamic>> _messages = [];
  bool _loadingPartner = true;

  late final String _myUid;
  late final String _chatId;

  @override
  void initState() {
    super.initState();
    _myUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    // Chat ID — всегда одинаковый для двух пользователей
    final ids = [_myUid, widget.targetUid]..sort();
    _chatId = ids.join('_');
    _loadPartner();
    _listenMessages();
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadPartner() async {
    try {
      final snap =
      await FirebaseDatabase.instance.ref('users/${widget.targetUid}').get();
      if (snap.exists) {
        setState(() {
          _partnerData = Map<String, dynamic>.from(snap.value as Map);
          _loadingPartner = false;
        });
      }
    } catch (_) {
      setState(() => _loadingPartner = false);
    }
  }

  void _listenMessages() {
    FirebaseDatabase.instance
        .ref('chats/$_chatId/messages')
        .orderByChild('timestamp')
        .onValue
        .listen((event) {
      if (!event.snapshot.exists) return;
      final raw = Map<String, dynamic>.from(event.snapshot.value as Map);
      final list = raw.entries.map((e) {
        final m = Map<String, dynamic>.from(e.value as Map);
        m['key'] = e.key;
        return m;
      }).toList();
      list.sort((a, b) =>
          (a['timestamp'] as int).compareTo(b['timestamp'] as int));
      setState(() => _messages = list);
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    _msgCtrl.clear();

    final up = context.read<UserProvider>();
    await FirebaseDatabase.instance
        .ref('chats/$_chatId/messages')
        .push()
        .set({
      'text': text,
      'senderUid': _myUid,
      'senderName': up.nickname,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  @override
  Widget build(BuildContext context) {
    final up = context.watch<UserProvider>();
    final partnerCoins =
        (_partnerData?['coins'] as num?)?.toInt() ?? 0;
    final partnerSales =
        (_partnerData?['sales'] as num?)?.toInt() ?? 0;
    final partnerBying =
        (_partnerData?['bying'] as num?)?.toInt() ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFEAF4FF),
      appBar: AppBar(
        title: Text('Trade with:   ${widget.targetNickname}'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Column(
        children: [
          // ── MY PROPOSAL ──
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text('MY PRIVATE PROPOSAL:',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                          color: Colors.black54)),
                ),
                const SizedBox(height: 12),
                _ProposalRow(label: 'Offer sale:', value: up.sales),
                const SizedBox(height: 8),
                _ProposalRow(label: 'Offer by:', value: up.bying),
              ],
            ),
          ),

          // ── PARTNER PROPOSAL ──
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.deepPurple.shade200),
            ),
            child: _loadingPartner
                ? const Center(child: CircularProgressIndicator())
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text("PARTNER'S PRIVATE PROPOSAL:",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                          color: Colors.black54)),
                ),
                const SizedBox(height: 12),
                Text('Partner proposes to sell:  $partnerSales Rc\$',
                    style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 8),
                Text('Partner wants to buy:  $partnerBying Rc\$',
                    style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),

          // ── CHAT ──
          Expanded(
            child: _messages.isEmpty
                ? const Center(
                child: Text('No messages yet.\nStart the conversation!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black38)))
                : ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (ctx, i) {
                final msg = _messages[i];
                final isMe = msg['senderUid'] == _myUid;
                final ts = msg['timestamp'] as int? ?? 0;
                final time = DateTime.fromMillisecondsSinceEpoch(ts);
                final timeStr =
                    '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                return Align(
                  alignment: isMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    constraints: BoxConstraints(
                      maxWidth:
                      MediaQuery.of(ctx).size.width * 0.72,
                    ),
                    decoration: BoxDecoration(
                      color: isMe
                          ? Colors.green.shade400
                          : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black12, blurRadius: 3)
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (!isMe)
                          Text(
                            msg['senderName']?.toString() ?? 'User',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple.shade400),
                          ),
                        Text(
                          msg['text']?.toString() ?? '',
                          style: TextStyle(
                              color: isMe
                                  ? Colors.white
                                  : Colors.black87),
                        ),
                        const SizedBox(height: 2),
                        Text(timeStr,
                            style: TextStyle(
                                fontSize: 10,
                                color: isMe
                                    ? Colors.white70
                                    : Colors.black38)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // ── INPUT ──
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgCtrl,
                    decoration: InputDecoration(
                      hintText: 'Write a message...',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.green,
                  child: IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProposalRow extends StatelessWidget {
  final String label;
  final int value;
  const _ProposalRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          const SizedBox(width: 8),
          Text('$value',
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}