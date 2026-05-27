import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';

import '../states/local_user_provider.dart';

class MarketPage extends StatefulWidget {
  const MarketPage({super.key});

  @override
  State<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> {
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;
  bool _tradeExpanded = false;
  bool _msgExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final snap = await FirebaseDatabase.instance.ref('users').get();
      if (!snap.exists) { setState(() => _isLoading = false); return; }
      final raw = Map<String, dynamic>.from(snap.value as Map);
      final currentUid = FirebaseAuth.instance.currentUser?.uid;
      final list = raw.entries.where((e) => e.key != currentUid).map((e) {
        final m = Map<String, dynamic>.from(e.value as Map);
        m['uid'] = e.key;
        return m;
      }).toList();
      setState(() { _users = list; _isLoading = false; });
    } catch (_) { setState(() => _isLoading = false); }
  }

  @override
  Widget build(BuildContext context) {
    final up = context.watch<UserProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFD4F5C4),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadUsers,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              // ── TITLE ──
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: Center(
                  child: Text('Rickkoins Market',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFCC0000))),
                ),
              ),

              // ── MY PROFILE ROW ──
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundImage: up.avatar.isNotEmpty ? NetworkImage(up.avatar) : null,
                      child: up.avatar.isEmpty ? const Icon(Icons.person, size: 28) : null,
                    ),
                    const SizedBox(width: 12),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('User name:', style: TextStyle(fontSize: 11, color: Colors.black54)),
                      Text(up.nickname, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('Balance: ${up.coins} Rc\$',
                          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    ]),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // ── TOGGLES ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(children: [
                  const Text('Toggle Trade: '),
                  _ToggleBtn(
                    color: Colors.red.shade400,
                    expanded: _tradeExpanded,
                    onTap: () => setState(() => _tradeExpanded = !_tradeExpanded),
                  ),
                  const SizedBox(width: 20),
                  const Text('Toggle Msg: '),
                  _ToggleBtn(
                    color: Colors.blue.shade700,
                    expanded: _msgExpanded,
                    onTap: () => setState(() => _msgExpanded = !_msgExpanded),
                  ),
                ]),
              ),

              if (_tradeExpanded) _TradePanel(up: up),
              if (_msgExpanded) _MsgPanel(up: up),

              const SizedBox(height: 10),

              // ── USER CARDS ──
              if (_isLoading)
                const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
              else if (_users.isEmpty)
                const Padding(padding: EdgeInsets.all(20), child: Center(child: Text('No users yet')))
              else
                ..._users.map((u) => _MarketCard(userData: u)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  final Color color;
  final bool expanded;
  final VoidCallback onTap;
  const _ToggleBtn({required this.color, required this.expanded, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 16,
        backgroundColor: color,
        child: Icon(expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            color: Colors.white, size: 20),
      ),
    );
  }
}

class _MarketCard extends StatelessWidget {
  final Map<String, dynamic> userData;
  const _MarketCard({required this.userData});

  @override
  Widget build(BuildContext context) {
    final avatar = userData['avatar']?.toString() ?? '';
    final nickname = userData['nickname']?.toString() ?? 'User';
    final message = userData['message']?.toString() ?? '';
    final coins = (userData['coins'] as num?)?.toInt() ?? 0;
    final sales = (userData['sales'] as num?)?.toInt() ?? 0;
    final bying = userData['bying'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Row(children: [
        CircleAvatar(
          radius: 34,
          backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
          child: avatar.isEmpty ? const Icon(Icons.person, size: 30) : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(nickname, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            if (message.isNotEmpty)
              Text(message,
                  style: const TextStyle(color: Color(0xFF3F51B5), fontSize: 13),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Row(children: [
              const Text('Balance: ', style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold)),
              Text('$coins Rc\$', style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold)),
            ]),
            Text('For sale: $sales',
                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            Text("I'll buy: ${bying ?? 'null'}",
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ]),
        ),
      ]),
    );
  }
}

class _TradePanel extends StatefulWidget {
  final UserProvider up;
  const _TradePanel({required this.up});
  @override
  State<_TradePanel> createState() => _TradePanelState();
}
class _TradePanelState extends State<_TradePanel> {
  late final TextEditingController _salesCtrl;
  late final TextEditingController _byingCtrl;
  @override
  void initState() {
    super.initState();
    _salesCtrl = TextEditingController(text: widget.up.sales.toString());
    _byingCtrl = TextEditingController(text: widget.up.bying.toString());
  }
  @override
  void dispose() { _salesCtrl.dispose(); _byingCtrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(children: [
          TextField(controller: _salesCtrl, keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'For sale (coins)')),
          TextField(controller: _byingCtrl, keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "I'll buy (coins)")),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () async {
              await widget.up.updateField('sales', int.tryParse(_salesCtrl.text) ?? 0);
              await widget.up.updateField('bying', int.tryParse(_byingCtrl.text) ?? 0);
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved!')));
            },
            child: const Text('Save'),
          ),
        ]),
      ),
    );
  }
}

class _MsgPanel extends StatefulWidget {
  final UserProvider up;
  const _MsgPanel({required this.up});
  @override
  State<_MsgPanel> createState() => _MsgPanelState();
}
class _MsgPanelState extends State<_MsgPanel> {
  late final TextEditingController _ctrl;
  @override
  void initState() { super.initState(); _ctrl = TextEditingController(text: widget.up.message); }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(children: [
          TextField(controller: _ctrl, maxLines: 3,
              decoration: const InputDecoration(labelText: 'Your market message')),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () async {
              await widget.up.updateField('message', _ctrl.text.trim());
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved!')));
            },
            child: const Text('Save'),
          ),
        ]),
      ),
    );
  }
}
