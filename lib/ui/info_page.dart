import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD6F5FF),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 10),
            const Center(
              child: Text('Info',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFCC0000))),
            ),
            const SizedBox(height: 24),

            _InfoCard(
              icon: Icons.monetization_on,
              color: Colors.green,
              title: 'What are Rickoins?',
              body: 'Rickoins (Rc\$) is the internal currency of this app. '
                  'You can earn them by sharing content, trade them with other users, '
                  'and use them to unlock features.',
            ),

            _InfoCard(
              icon: Icons.store,
              color: Colors.orange,
              title: 'Market',
              body: 'In the Market tab you can see all users, their balances, '
                  'how many coins they want to sell or buy. '
                  'Use Toggle Trade to update your own offer. '
                  'Use Toggle Msg to set your public message.',
            ),

            _InfoCard(
              icon: Icons.folder,
              color: Colors.blue,
              title: 'Scenario Cabinet',
              body: 'Upload PDF or Word scenario files to your cabinet. '
                  'Tap a file to open it. Other users can send you Rickoins '
                  'to access your scenarios.',
            ),

            _InfoCard(
              icon: Icons.people,
              color: Colors.purple,
              title: 'Rick & Morty API',
              body: 'Character data is loaded from the open Rick and Morty API (rickandmortyapi.com). '
                  'You can search any character by name on the Home screen.',
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            const Text('Links', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            _LinkTile(
              label: 'Rick and Morty API',
              url: 'https://rickandmortyapi.com',
              onTap: _open,
            ),
            _LinkTile(
              label: 'Nickelodeon',
              url: 'https://www.youtube.com/@NickelodeonCyrillic',
              onTap: _open,
            ),
            _LinkTile(
              label: 'Boomerang TV',
              url: 'https://www.boomerangtv.co.uk/videos',
              onTap: _open,
            ),
            _LinkTile(
              label: 'Cartoon Network',
              url: 'https://www.cartoonnetwork.co.uk/videos',
              onTap: _open,
            ),

            const SizedBox(height: 24),
            const Center(
              child: Text('Rickoins App v1.0.0',
                  style: TextStyle(color: Colors.black38, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  const _InfoCard({required this.icon, required this.color, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        CircleAvatar(radius: 22, backgroundColor: color.withOpacity(0.15),
            child: Icon(icon, color: color, size: 24)),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 4),
            Text(body, style: const TextStyle(fontSize: 13, color: Colors.black54)),
          ]),
        ),
      ]),
    );
  }
}

class _LinkTile extends StatelessWidget {
  final String label;
  final String url;
  final Future<void> Function(String) onTap;
  const _LinkTile({required this.label, required this.url, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(url),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Row(children: [
          const Icon(Icons.link, color: Colors.blue),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
          const Spacer(),
          const Icon(Icons.chevron_right, color: Colors.black38),
        ]),
      ),
    );
  }
}
