import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../app_navigation.dart';

class ItemChatBubble extends StatelessWidget {
  final Map<String, dynamic> userData;
  final String uid;

  const ItemChatBubble({super.key, required this.userData, required this.uid});

  @override
  Widget build(BuildContext context) {
    final String currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        AppNavigation.twoPersonTradePage,
        arguments: {'nickname': userData['nickname'], 'uid': uid},
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: (userData['avatar'] ?? '').isNotEmpty
                ? NetworkImage(userData['avatar'])
                : null,
            child: (userData['avatar'] ?? '').isEmpty
                ? const Icon(Icons.person, size: 40)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(userData['nickname'] ?? 'User',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('${userData['message'] ?? ''}',
                  style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Row(children: [
                const Text('Balance: ',
                    style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold)),
                Text('${userData['coins'] ?? 0} Rc\$',
                    style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold)),
              ]),
              Text('For sale: ${userData['sales'] ?? 0}',
                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              Text("I'll buy: ${userData['buying'] ?? 'null'}",
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ]),
          ),
        ]),
      ),
    );
  }
}