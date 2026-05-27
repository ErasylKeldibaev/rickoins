import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../components/character_info_card.dart';
import '../models/btn_cartoon_model.dart';
import '../models/character_model.dart';
import '../services/character_service.dart';
import '../states/local_user_provider.dart';
import 'show_cartoon_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CharacterService _characterService = CharacterService();
  final TextEditingController _searchCtrl = TextEditingController();
  List<CharacterModel> _all = [];
  List<CharacterModel> _filtered = [];
  bool isLoading = true;
  String? errorText;

  @override
  void initState() {
    super.initState();
    _loadCharacters();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().loadUserData();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCharacters() async {
    try {
      final data = await _characterService.fetchCharacters();
      if (!mounted) return;
      setState(() {
        _all = data.take(20).toList();
        _filtered = _all;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorText = 'Failed to load characters';
        isLoading = false;
      });
    }
  }

  void _onSearch(String q) {
    setState(() {
      _filtered = _all
          .where((c) => c.name.toLowerCase().contains(q.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartoons = BtnCartoonModel.getListCartoonModels();
    final up = context.watch<UserProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFD6F5FF),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadCharacters,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              // ── TOP BAR ──
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundImage: up.avatar.isNotEmpty
                          ? NetworkImage(up.avatar)
                          : null,
                      child: up.avatar.isEmpty
                          ? const Icon(Icons.person, size: 28)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('User name:',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.black54)),
                          Text(up.nickname,
                              style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold)),
                          Text('Balance: ${up.coins} Rc\$',
                              style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        up.clearUserData();
                      },
                      icon: const Icon(Icons.logout, color: Colors.red),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── SEARCH ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: _onSearch,
                  decoration: InputDecoration(
                    hintText: 'Search character...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── CHARACTERS ──
              if (isLoading)
                const Center(
                    child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator()))
              else if (errorText != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(errorText!,
                      style: const TextStyle(color: Colors.red)),
                )
              else
                SizedBox(
                  height: 285,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: _filtered.length,
                    itemBuilder: (ctx, i) =>
                        CharacterInfoCard(character: _filtered[i]),
                  ),
                ),

              const SizedBox(height: 20),

              // ── CARTOONS ──
              SizedBox(
                height: 115,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: cartoons.length,
                  itemBuilder: (ctx, i) {
                    return GestureDetector(
                      onTap: () => Navigator.push(
                          ctx,
                          MaterialPageRoute(
                              builder: (_) =>
                                  ShowCartoonPage(cartoon: cartoons[i]))),
                      child: Container(
                        width: 105,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: Offset(0, 3))
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.asset(cartoons[i].image,
                              fit: BoxFit.cover),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // ── BANNER ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 6)
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.monetization_on,
                            color: Colors.yellow, size: 40),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Text(
                          'If you have not account for earning rickkoins, you can do it now!\nRead Uses Condition',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}