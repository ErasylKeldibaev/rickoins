import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:provider/provider.dart';
import '../providers/local_user_provider.dart';

class PDFViewScreen extends StatefulWidget {
  final String url;
  final String title;
  final String authorId;

  const PDFViewScreen({
    super.key,
    required this.url,
    required this.title,
    required this.authorId,
  });

  @override
  State<PDFViewScreen> createState() => _PDFViewScreenState();
}

class _PDFViewScreenState extends State<PDFViewScreen> {
  PdfControllerPinch? _controller;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initPdf();
  }

  Future<void> _initPdf() async {
    try {
      final bytes = await _downloadPdf(widget.url);
      _controller = PdfControllerPinch(
        document: PdfDocument.openData(bytes),
      );
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<Uint8List> _downloadPdf(String url) async {
    final uri = Uri.parse(url);
    final request = await HttpClient().getUrl(uri);
    final response = await request.close();
    if (response.statusCode != 200) {
      throw Exception('Failed to download PDF: ${response.statusCode}');
    }
    final bytes = await consolidateHttpClientResponseBytes(response);
    return bytes;
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: _buildBody(),
      floatingActionButton: _isLoading || _errorMessage != null
          ? null
          : FloatingActionButton.extended(
              onPressed: () {
                context.read<UserProvider>().giveRickCoins(widget.authorId, 10);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('10 Rick Coins given to author!')),
                );
              },
              label: const Text('Give Rick Coins'),
              icon: const Icon(Icons.favorite),
            ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(child: Text('Error: $_errorMessage'));
    }
    if (_controller == null) {
      return const Center(child: Text('Could not initialize PDF controller'));
    }
    return PdfViewPinch(controller: _controller!);
  }
}
