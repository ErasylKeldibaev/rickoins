import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/btn_cartoon_model.dart';

class ShowCartoonPage extends StatelessWidget {
  final BtnCartoonModel cartoon;

  const ShowCartoonPage({
    super.key,
    required this.cartoon,
  });

  Future<void> _openUrl() async {
    final uri = Uri.parse(cartoon.url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cartoon Resource'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  cartoon.image,
                  height: 180,
                  width: 180,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _openUrl,
                child: const Text('Open Resource'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}