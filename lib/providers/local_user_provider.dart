import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';

class UserProvider with ChangeNotifier {
  UserModel? _userData;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserModel? get userData => _userData;

  UserProvider() {
    _listenToUser();
  }

  void _listenToUser() {
    _auth.authStateChanges().listen((User? user) async {
      if (user != null) {
        // Слушаем изменения профиля
        _db.collection('user_persons').doc(user.uid).snapshots().listen((snap) async {
          if (snap.exists) {
            _userData = UserModel.fromMap(snap.data()!);
            notifyListeners();
          } else {
            // Если документа нет, создаем его (миграция или первый вход)
            final newUser = UserModel(
              nickname: user.email?.split('@').first ?? 'User',
              email: user.email ?? '',
              coins: 10,
            );
            await _db.collection('user_persons').doc(user.uid).set(newUser.toMap());
          }
        });
      } else {
        _userData = null;
        notifyListeners();
      }
    });
  }

  Future<void> updateMarketMessage(String newMessage) async {
    String uid = _auth.currentUser!.uid;
    await _db.collection('user_persons').doc(uid).update({'message': newMessage});
  }

  Future<void> updateBuyIntent(int toBuy) async {
    String uid = _auth.currentUser!.uid;
    await _db.collection('user_persons').doc(uid).update({'buying': toBuy});
  }

  Future<void> updateSaleIntent(int toSell) async {
    String uid = _auth.currentUser!.uid;
    await _db.collection('user_persons').doc(uid).update({'sales': toSell});
  }

  Future<void> giveRickCoins(String ownerId, int amount) async {
    final buyerId = _auth.currentUser!.uid;
    final buyerRef = _db.collection('user_persons').doc(buyerId);
    final ownerRef = _db.collection('user_persons').doc(ownerId);
    try {
      await _db.runTransaction((transaction) async {
        DocumentSnapshot buyerSnap = await transaction.get(buyerRef);
        DocumentSnapshot ownerSnap = await transaction.get(ownerRef);
        int buyerCoins = buyerSnap['coins'] ?? 0;
        int ownerCoins = ownerSnap['coins'] ?? 0;
        if (buyerCoins >= amount) {
          transaction.update(buyerRef, {'coins': buyerCoins - amount});
          transaction.update(ownerRef, {'coins': ownerCoins + amount});
        } else {
          throw Exception("Not enough coins!");
        }
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateIndividualOffer(int buyAmount, int sellAmount, String partnerUid) async {
    String myUid = _auth.currentUser!.uid;
    await _db.collection('user_persons').doc(myUid).update({
      'individualBuy': buyAmount,
      'individualSell': sellAmount,
      'targetPartnerId': partnerUid,
    });
  }

  Future<void> acceptIndividualSell(String partnerUid, int amount) async {
    final currentUid = _auth.currentUser?.uid;
    if (currentUid == null) return;
    final currentRef = _db.collection('user_persons').doc(currentUid);
    final partnerRef = _db.collection('user_persons').doc(partnerUid);
    await _db.runTransaction((transaction) async {
      DocumentSnapshot currentSnap = await transaction.get(currentRef);
      DocumentSnapshot partnerSnap = await transaction.get(partnerRef);
      int myCoins = currentSnap['coins'] ?? 0;
      int partnerCoins = partnerSnap['coins'] ?? 0;
      transaction.update(currentRef, {'coins': myCoins + amount});
      transaction.update(partnerRef, {'coins': partnerCoins - amount, 'individualSell': 0});
    });
  }
}
