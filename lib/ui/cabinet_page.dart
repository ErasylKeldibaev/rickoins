import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/local_user_provider.dart';

class CabinetPage extends StatefulWidget {
  const CabinetPage({super.key});

  @override
  State<CabinetPage> createState() => _CabinetPageState();
}

class _CabinetPageState extends State<CabinetPage> {
  List<Map<String, dynamic>> _pdfFiles = [];
  List<Map<String, dynamic>> _wordFiles = [];
  bool _loadingFiles = true;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final snap = await FirebaseFirestore.instance
          .collection('user_files')
          .doc(uid)
          .collection('my_files')
          .get();

      final pdfs = <Map<String, dynamic>>[];
      final words = <Map<String, dynamic>>[];

      for (var doc in snap.docs) {
        final item = doc.data();
        item['key'] = doc.id;
        final name = item['name']?.toString() ?? '';
        if (name.toLowerCase().endsWith('.pdf')) {
          pdfs.add(item);
        } else {
          words.add(item);
        }
      }
      if (mounted) {
        setState(() {
          _pdfFiles = pdfs;
          _wordFiles = words;
          _loadingFiles = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loadingFiles = false);
    }
  }

  Future<void> _uploadFile(String type) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: type == 'pdf' ? ['pdf'] : ['doc', 'docx'],
    );
    if (result == null || result.files.isEmpty) return;
    final picked = result.files.first;
    final path = picked.path;
    if (path == null) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Uploading...')));
      }
      final storageRef = FirebaseStorage.instance.ref('files/$uid/${picked.name}');
      await storageRef.putFile(File(path));
      final url = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('user_files')
          .doc(uid)
          .collection('my_files')
          .add({'name': picked.name, 'url': url, 'type': type, 'createdAt': FieldValue.serverTimestamp()});

      await _loadFiles();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Uploaded!')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _openFile(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final userData = userProvider.userData;

    return Scaffold(
      backgroundColor: const Color(0xFFD4F5C4),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadFiles,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: Center(
                  child: Text('Scenario Cabinet',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFCC0000))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: (userData?.avatar.isNotEmpty ?? false) ? NetworkImage(userData!.avatar) : null,
                    child: (userData?.avatar.isEmpty ?? true) ? const Icon(Icons.person, size: 28) : null,
                  ),
                  const SizedBox(width: 12),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('User name:', style: TextStyle(fontSize: 11, color: Colors.black54)),
                    Text(userData?.nickname ?? 'User', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('Balance: ${userData?.coins ?? 0} Rc\$',
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  ]),
                ]),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(children: [
                  _UploadBtn(
                    label: 'PDF',
                    icon: Icons.picture_as_pdf,
                    color: Colors.red,
                    onTap: () => _uploadFile('pdf'),
                  ),
                  const SizedBox(width: 16),
                  _UploadBtn(
                    label: 'Word',
                    icon: Icons.description,
                    color: Colors.blue,
                    onTap: () => _uploadFile('word'),
                  ),
                ]),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('PDF Scenarios', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),
              if (_loadingFiles)
                const Center(child: CircularProgressIndicator())
              else if (_pdfFiles.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('No PDF files yet', style: TextStyle(color: Colors.black45)),
                )
              else
                SizedBox(
                  height: 140,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: _pdfFiles.length,
                    itemBuilder: (ctx, i) => _FileCard(
                      file: _pdfFiles[i],
                      isPdf: true,
                      onTap: () => _openFile(_pdfFiles[i]['url'] ?? ''),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Word Scenarios', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),
              if (!_loadingFiles && _wordFiles.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('No Word files yet', style: TextStyle(color: Colors.black45)),
                )
              else if (!_loadingFiles)
                SizedBox(
                  height: 140,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: _wordFiles.length,
                    itemBuilder: (ctx, i) => _FileCard(
                      file: _wordFiles[i],
                      isPdf: false,
                      onTap: () => _openFile(_wordFiles[i]['url'] ?? ''),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade400),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                  },
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text('Log Out', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UploadBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _UploadBtn({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: Colors.white, size: 36),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ]),
    );
  }
}

class _FileCard extends StatelessWidget {
  final Map<String, dynamic> file;
  final bool isPdf;
  final VoidCallback onTap;
  const _FileCard({required this.file, required this.isPdf, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final name = file['name']?.toString() ?? 'file';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 110,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(isPdf ? Icons.picture_as_pdf : Icons.description,
              color: isPdf ? Colors.red : Colors.blue, size: 48),
          const SizedBox(height: 6),
          Text(name, style: const TextStyle(fontSize: 11),
              textAlign: TextAlign.center, maxLines: 3, overflow: TextOverflow.ellipsis),
        ]),
      ),
    );
  }
}
