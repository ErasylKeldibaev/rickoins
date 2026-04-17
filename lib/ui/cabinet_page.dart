import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CabinetPage extends StatelessWidget {
  const CabinetPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cabinet'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 42,
              child: Icon(Icons.person, size: 36),
            ),
            const SizedBox(height: 18),
            Text(
              user?.email ?? 'Guest',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Card(
              child: ListTile(
                leading: Icon(Icons.monetization_on),
                title: Text('Coins'),
                subtitle: Text('0 RC'),
              ),
            ),
            const Card(
              child: ListTile(
                leading: Icon(Icons.shopping_bag_outlined),
                title: Text('Buying'),
                subtitle: Text('0'),
              ),
            ),
            const Card(
              child: ListTile(
                leading: Icon(Icons.sell_outlined),
                title: Text('Sales'),
                subtitle: Text('0'),
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Log Out'),
            ),
          ],
        ),
      ),
    );
  }
}