import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/two_trade_buy.dart';
import '../components/two_trade_sale.dart';
import '../providers/local_user_provider.dart';
import '../services/two_chat_page_service.dart';

class TwoPersonTradePage extends StatefulWidget {
  final String nickname;
  final String uid;

  const TwoPersonTradePage({super.key, required this.nickname, required this.uid});

  @override
  State<TwoPersonTradePage> createState() => _TwoPersonTradePageState();
}

class _TwoPersonTradePageState extends State<TwoPersonTradePage> {
  final TextEditingController _messageController = TextEditingController();
  final TwoChatService _chatService = TwoChatService();
  int _mySellOffer = 0;
  int _myBuyOffer = 0;

  @override
  void dispose() {
    _messageController.dispose();
    // Use the provider to reset the offer when leaving the page
    Provider.of<UserProvider>(context, listen: false)
        .updateIndividualOffer(0, 0, '');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final String currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFCEF2F8),
      appBar: AppBar(
        title: Text('Trade with: ${widget.nickname}',
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('user_persons')
              .doc(widget.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            var partnerData = snapshot.data!.data() as Map<String, dynamic>? ?? {};

            int partnerWantsToBuy = 0;
            int partnerWantsToSell = 0;
            if (partnerData['targetPartnerId'] == currentUid) {
              partnerWantsToBuy = partnerData['individualBuy'] ?? 0;
              partnerWantsToSell = partnerData['individualSell'] ?? 0;
            }

            return Column(children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(children: [
                    const SizedBox(height: 20),
                    const Text('MY PRIVATE PROPOSAL:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    TwoTradeSale(onAmountChanged: (val) {
                      _mySellOffer = val;
                      userProvider.updateIndividualOffer(_myBuyOffer, _mySellOffer, widget.uid);
                    }),
                    const SizedBox(height: 10),
                    TwoTradeBuy(onAmountChanged: (val) {
                      _myBuyOffer = val;
                      userProvider.updateIndividualOffer(_myBuyOffer, _mySellOffer, widget.uid);
                    }),
                    const Divider(height: 40, color: Colors.purple, thickness: 6),
                    const Text("PARTNER'S PRIVATE PROPOSAL:",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    _partnerRow('Partner proposes to sell:', partnerWantsToSell, Colors.pinkAccent,
                            () => Navigator.pushNamed(context, '/payment', arguments: {
                          'partnerId': widget.uid,
                          'passed_amount': partnerWantsToSell,
                          'partnerNickname': widget.nickname,
                          'pageLable': 'from_two_person_trade',
                        })),
                    const SizedBox(height: 10),
                    _partnerRow('Partner proposes to buy:', partnerWantsToBuy, Colors.green,
                            () async {
                          try {
                            await userProvider.acceptIndividualSell(widget.uid, partnerWantsToBuy);
                            if (mounted) {
                              showDialog(context: context, builder: (_) => AlertDialog(
                                title: const Text('Success!'),
                                content: Text('Deal accepted: $partnerWantsToBuy Rc\$'),
                                actions: [TextButton(
                                  onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
                                  child: const Text('OK'),
                                )],
                              ));
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                            }
                          }
                        }),
                  ]),
                ),
              ),
              const Divider(height: 2, color: Colors.purple),
              // CHAT
              Expanded(child: _buildMessageList(currentUid)),
              _buildInput(),
            ]);
          },
        ),
      ),
    );
  }

  Widget _partnerRow(String label, int amount, Color color, VoidCallback onAccept) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('$label  $amount Rc\$'),
        if (amount > 0)
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: color),
            onPressed: onAccept,
            child: const Text('Accept', style: TextStyle(color: Colors.white)),
          ),
      ]),
    );
  }

  Widget _buildMessageList(String currentUid) {
    return StreamBuilder<QuerySnapshot>(
      stream: _chatService.getMessages(widget.uid, currentUid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          itemCount: docs.length,
          itemBuilder: (ctx, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            final isMe = data['senderID'] == currentUid;
            return Align(
              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.symmetric(vertical: 4),
                constraints: BoxConstraints(maxWidth: MediaQuery.of(ctx).size.width * 0.7),
                decoration: BoxDecoration(
                  color: isMe ? Colors.blueAccent : Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(data['message'] ?? '',
                    style: TextStyle(color: isMe ? Colors.white : Colors.black)),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInput() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(children: [
        Expanded(
          child: TextField(
            controller: _messageController,
            decoration: InputDecoration(
              hintText: 'Enter message...',
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.send, color: Colors.blueAccent, size: 30),
          onPressed: () async {
            if (_messageController.text.trim().isNotEmpty) {
              final text = _messageController.text;
              _messageController.clear();
              await _chatService.sendMessage(widget.uid, text);
            }
          },
        ),
      ]),
    );
  }
}
