import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../components/item_chat_bubble.dart';
import '../components/message_create_card_widget.dart';
import '../components/rick_coins_sale_buys_card_widget.dart';
import '../components/top_bar_widget.dart';

class MarketPage extends StatefulWidget {
  const MarketPage({super.key});
  @override
  State<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> {
  bool isSaleBuyCardShown = false;
  bool isMessageCardShown = false;
  String _searchQuery = '';
  String _sortBy = 'coins_desc';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
              Color(0xFF0F3460),
              Color(0xFF533483),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── HEADER ──
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFF6B35)],
                      ).createShader(bounds),
                      child: const Text(
                        '💰 Rick Coins Market',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TopBarWidget(showLogoutButton: false),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── SEARCH BAR ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFFE040FB)],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6C63FF).withOpacity(0.5),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: (v) =>
                        setState(() => _searchQuery = v.toLowerCase()),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: '🔍  Search user...',
                      hintStyle: const TextStyle(color: Colors.white60),
                      prefixIcon:
                      const Icon(Icons.search, color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                      const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // ── SORT + TOGGLES ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _sortBy,
                            dropdownColor: const Color(0xFF0F3460),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 13),
                            icon: const Icon(Icons.sort,
                                color: Colors.white60, size: 18),
                            items: const [
                              DropdownMenuItem(
                                  value: 'coins_desc',
                                  child: Text('💰 Coins ↓')),
                              DropdownMenuItem(
                                  value: 'coins_asc',
                                  child: Text('💰 Coins ↑')),
                              DropdownMenuItem(
                                  value: 'name',
                                  child: Text('🔤 By name')),
                            ],
                            onChanged: (v) =>
                                setState(() => _sortBy = v!),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _GradientToggleBtn(
                      label: 'Trade',
                      icon: Icons.swap_horiz,
                      active: isSaleBuyCardShown,
                      gradient: const LinearGradient(colors: [
                        Color(0xFFFF6B35),
                        Color(0xFFFF8E53)
                      ]),
                      onTap: () => setState(() {
                        isSaleBuyCardShown = !isSaleBuyCardShown;
                        if (isSaleBuyCardShown) isMessageCardShown = false;
                      }),
                    ),
                    const SizedBox(width: 8),
                    _GradientToggleBtn(
                      label: 'Msg',
                      icon: Icons.chat_bubble_outline,
                      active: isMessageCardShown,
                      gradient: const LinearGradient(colors: [
                        Color(0xFF00C9FF),
                        Color(0xFF92FE9D)
                      ]),
                      onTap: () => setState(() {
                        isMessageCardShown = !isMessageCardShown;
                        if (isMessageCardShown) isSaleBuyCardShown = false;
                      }),
                    ),
                  ],
                ),
              ),

              if (isSaleBuyCardShown)
                _GlassCard(child: RickCoinsSaleBuyCardWidget()),
              if (isMessageCardShown)
                _GlassCard(child: MessageCreateCardWidget()),

              const SizedBox(height: 8),

              // ── USERS LIST ──
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('user_persons')
                      .snapshots(),
                  builder: (context, snapshot) {
                    // ── ОТЛАДКА ──
                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline,
                                color: Colors.red, size: 48),
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                'Ошибка Firestore:\n${snapshot.error}',
                                style: const TextStyle(
                                    color: Colors.red, fontSize: 14),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () => setState(() {}),
                              child: const Text('Повторить'),
                            ),
                          ],
                        ),
                      );
                    }

                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                                color: Color(0xFFFFD700)),
                            SizedBox(height: 12),
                            Text('Загрузка пользователей...',
                                style: TextStyle(color: Colors.white54)),
                          ],
                        ),
                      );
                    }

                    if (!snapshot.hasData ||
                        snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.people_outline,
                                color: Colors.white38, size: 64),
                            const SizedBox(height: 12),
                            const Text(
                              'Коллекция user_persons пуста.\nЗарегистрируйте ещё одного пользователя.',
                              style: TextStyle(
                                  color: Colors.white54, fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            // КНОПКА ДИАГНОСТИКИ
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                  const Color(0xFF6C63FF)),
                              onPressed: () async {
                                try {
                                  final snap = await FirebaseFirestore
                                      .instance
                                      .collection('user_persons')
                                      .get();
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Text(
                                          'Docs in Firestore: ${snap.docs.length}'),
                                    ));
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Text('Error: $e'),
                                    ));
                                  }
                                }
                              },
                              icon: const Icon(Icons.bug_report),
                              label: const Text('Проверить Firestore'),
                            ),
                          ],
                        ),
                      );
                    }

                    final String currentUid =
                        FirebaseAuth.instance.currentUser?.uid ?? '';

                    List<QueryDocumentSnapshot> users = snapshot
                        .data!.docs
                        .where((d) => d.id != currentUid)
                        .toList();

                    // FILTER
                    if (_searchQuery.isNotEmpty) {
                      users = users.where((d) {
                        final data = d.data() as Map<String, dynamic>;
                        final name = (data['nickname'] ?? '')
                            .toString()
                            .toLowerCase();
                        final msg = (data['message'] ?? '')
                            .toString()
                            .toLowerCase();
                        return name.contains(_searchQuery) ||
                            msg.contains(_searchQuery);
                      }).toList();
                    }

                    // SORT
                    users.sort((a, b) {
                      final da = a.data() as Map<String, dynamic>;
                      final db = b.data() as Map<String, dynamic>;
                      if (_sortBy == 'coins_desc') {
                        return ((db['coins'] ?? 0) as num)
                            .compareTo((da['coins'] ?? 0) as num);
                      } else if (_sortBy == 'coins_asc') {
                        return ((da['coins'] ?? 0) as num)
                            .compareTo((db['coins'] ?? 0) as num);
                      } else {
                        return (da['nickname'] ?? '')
                            .toString()
                            .compareTo(
                            (db['nickname'] ?? '').toString());
                      }
                    });

                    if (users.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.search_off,
                                color: Colors.white38, size: 64),
                            const SizedBox(height: 12),
                            Text(
                              _searchQuery.isNotEmpty
                                  ? 'Никого не найдено по "$_searchQuery"'
                                  : 'Других пользователей нет',
                              style: const TextStyle(
                                  color: Colors.white54, fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    return Column(
                      children: [
                        // BADGE
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFFD700),
                                      Color(0xFFFF8C00)
                                    ],
                                  ),
                                  borderRadius:
                                  BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${users.length} traders',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              // UID текущего пользователя для отладки
                              Text(
                                'uid: ${FirebaseAuth.instance.currentUser?.uid?.substring(0, 6) ?? 'null'}...',
                                style: const TextStyle(
                                    color: Colors.white30,
                                    fontSize: 10),
                              ),
                            ],
                          ),
                        ),

                        Expanded(
                          child: ListView.builder(
                            padding:
                            const EdgeInsets.only(bottom: 20),
                            itemCount: users.length,
                            itemBuilder: (ctx, i) {
                              final data = users[i].data()
                              as Map<String, dynamic>;
                              return _RankedChatBubble(
                                rank: i + 1,
                                userData: data,
                                uid: users[i].id,
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── GRADIENT TOGGLE BUTTON ──
class _GradientToggleBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _GradientToggleBtn({
    required this.label,
    required this.icon,
    required this.active,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: active ? gradient : null,
          color: active ? null : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? Colors.transparent : Colors.white24,
          ),
          boxShadow: active
              ? [
            BoxShadow(
                color:
                gradient.colors.first.withOpacity(0.4),
                blurRadius: 8)
          ]
              : [],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(
              active ? Icons.keyboard_arrow_up : icon,
              color: Colors.white,
              size: 18),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }
}

// ── GLASS CARD ──
class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.2), blurRadius: 12),
        ],
      ),
      child: child,
    );
  }
}

// ── RANKED CARD ──
class _RankedChatBubble extends StatelessWidget {
  final int rank;
  final Map<String, dynamic> userData;
  final String uid;

  const _RankedChatBubble({
    required this.rank,
    required this.userData,
    required this.uid,
  });

  LinearGradient _rankGradient() {
    if (rank == 1)
      return const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFF8C00)]);
    if (rank == 2)
      return const LinearGradient(
          colors: [Color(0xFFC0C0C0), Color(0xFF808080)]);
    if (rank == 3)
      return const LinearGradient(
          colors: [Color(0xFFCD7F32), Color(0xFF8B4513)]);
    return const LinearGradient(
        colors: [Color(0xFF6C63FF), Color(0xFFE040FB)]);
  }

  String _rankEmoji() {
    if (rank == 1) return '🥇';
    if (rank == 2) return '🥈';
    if (rank == 3) return '🥉';
    return '#$rank';
  }

  @override
  Widget build(BuildContext context) {
    final avatar = userData['avatar']?.toString() ?? '';
    final nickname = userData['nickname']?.toString() ?? 'User';
    final message = userData['message']?.toString() ?? '';
    final coins = (userData['coins'] as num?)?.toInt() ?? 0;
    final sales = (userData['sales'] as num?)?.toInt() ?? 0;
    final buying =
        userData['buying'] ?? userData['bying'] ?? 'null';

    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        '/two_person_trade_page',
        arguments: {'nickname': nickname, 'uid': uid},
      ),
      child: Container(
        margin:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.12),
              Colors.white.withOpacity(0.06),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border:
          Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            // RANK
            Container(
              width: 44,
              height: 90,
              decoration: BoxDecoration(
                gradient: _rankGradient(),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
              child: Center(
                child: Text(
                  _rankEmoji(),
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            // AVATAR
            Padding(
              padding: const EdgeInsets.all(10),
              child: CircleAvatar(
                radius: 28,
                backgroundImage: avatar.isNotEmpty
                    ? NetworkImage(avatar)
                    : null,
                backgroundColor: Colors.white24,
                child: avatar.isEmpty
                    ? const Icon(Icons.person,
                    color: Colors.white, size: 26)
                    : null,
              ),
            ),

            // INFO
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 10, horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nickname,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                    if (message.isNotEmpty)
                      Text(message,
                          style: const TextStyle(
                              color: Color(0xFF92FE9D),
                              fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        _Badge('💰 $coins Rc\$',
                            const Color(0xFFFFD700), Colors.black),
                        _Badge('↑ sell: $sales',
                            const Color(0xFF00C9FF), Colors.black),
                        _Badge('↓ buy: $buying',
                            const Color(0xFFFF6B35), Colors.white),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.arrow_forward_ios,
                  color: Colors.white38, size: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color bg;
  final Color textColor;
  const _Badge(this.text, this.bg, this.textColor);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(text,
          style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.bold)),
    );
  }
}