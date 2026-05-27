import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class UserProvider extends ChangeNotifier {
  Map<String, dynamic>? _userData;
  bool _isLoading = false;

  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading;

  int get coins => (_userData?['coins'] as num?)?.toInt() ?? 0;
  String get nickname => _userData?['nickname']?.toString() ?? 'User';
  String get avatar => _userData?['avatar']?.toString() ?? '';
  int get sales => (_userData?['sales'] as num?)?.toInt() ?? 0;
  int get bying => (_userData?['bying'] as num?)?.toInt() ?? 0;
  String get message => _userData?['message']?.toString() ?? '';
  String get uid => _userData?['uid']?.toString() ?? '';

  Future<void> loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      final ref = FirebaseDatabase.instance.ref('users/$uid');
      final snap = await ref.get();
      if (snap.exists) {
        _userData = Map<String, dynamic>.from(snap.value as Map);
        _userData!['uid'] = uid;
      } else {
        final email = FirebaseAuth.instance.currentUser?.email ?? '';
        final defaultData = <String, dynamic>{
          'nickname': email.split('@').first,
          'coins': 10,
          'sales': 0,
          'bying': 0,
          'message': 'Hello everyone!',
          'avatar': '',
          'uid': uid,
        };
        await ref.set(defaultData);
        _userData = defaultData;
      }
    } catch (e) {
      debugPrint('Error loading user: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Награждает другого пользователя монетами за его сценарий.
  /// Условия:
  /// - За PDF сценарий: +10 Rc$
  /// - За Word сценарий: +5 Rc$
  /// - Нельзя наградить самого себя
  /// - Со своего баланса списывается столько же
  Future<void> giveRickkoins(String ownerUid, int amount) async {
    final myUid = FirebaseAuth.instance.currentUser?.uid;
    if (myUid == null) return;
    if (myUid == ownerUid) {
      throw Exception("You can't give Rickkoins to yourself!");
    }

    final ownerRef = FirebaseDatabase.instance.ref('users/$ownerUid');
    final myRef = FirebaseDatabase.instance.ref('users/$myUid');

    // Транзакция: снимаем у себя, добавляем владельцу
    final ownerSnap = await ownerRef.get();
    final mySnap = await myRef.get();

    if (!ownerSnap.exists) throw Exception('User not found!');
    if (!mySnap.exists) throw Exception('Your profile not found!');

    final ownerCoins = (Map<String, dynamic>.from(
        ownerSnap.value as Map)['coins'] as num?)
        ?.toInt() ??
        0;
    final myCoins =
        (Map<String, dynamic>.from(mySnap.value as Map)['coins'] as num?)
            ?.toInt() ??
            0;

    if (myCoins < amount) throw Exception('Not enough Rickkoins!');

    await ownerRef.update({'coins': ownerCoins + amount});
    await myRef.update({'coins': myCoins - amount});

    // Обновляем локально
    _userData?['coins'] = myCoins - amount;
    notifyListeners();
  }

  Future<void> updateField(String field, dynamic value) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await FirebaseDatabase.instance.ref('users/$uid/$field').set(value);
    _userData?[field] = value;
    notifyListeners();
  }

  void setUserData(Map<String, dynamic>? data) {
    _userData = data;
    notifyListeners();
  }

  void clearUserData() {
    _userData = null;
    notifyListeners();
  }
}