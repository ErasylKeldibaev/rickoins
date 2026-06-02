import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../providers/local_user_provider.dart';

class WordReadingPage extends StatefulWidget {
  final String url;
  final String title;
  final String authorId;

  const WordReadingPage({
    super.key,
    required this.url,
    required this.title,
    required this.authorId,
  });

  @override
  State<WordReadingPage> createState() => _WordReadingPageState();
}

class _WordReadingPageState extends State<WordReadingPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final googleDocsUrl =
        'https://docs.google.com/gview?embedded=true&url=${widget.url}';
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) => setState(() => _isLoading = true),
        onPageFinished: (_) => setState(() => _isLoading = false),
      ))
      ..loadRequest(Uri.parse(googleDocsUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), backgroundColor: Colors.cyanAccent),
      body: Stack(children: [
        WebViewWidget(controller: _controller),
        if (_isLoading) const Center(child: CircularProgressIndicator()),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.read<UserProvider>().giveRickCoins(widget.authorId, 5);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('5 Rick-Coins given to author!')),
          );
        },
        label: const Text('Reward Author'),
        icon: const Icon(Icons.star),
      ),
    );
  }
}