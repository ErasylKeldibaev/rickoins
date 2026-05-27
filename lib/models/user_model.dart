class UserModel {
  final String uid;
  final String nickname;
  final String email;
  final String avatar;
  final int coins;
  final int sales;
  final int bying;
  final String message;

  const UserModel({
    required this.uid,
    required this.nickname,
    required this.email,
    required this.avatar,
    required this.coins,
    required this.sales,
    required this.bying,
    required this.message,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      nickname: map['nickname']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      avatar: map['avatar']?.toString() ?? '',
      coins: (map['coins'] as num?)?.toInt() ?? 0,
      sales: (map['sales'] as num?)?.toInt() ?? 0,
      bying: (map['bying'] as num?)?.toInt() ?? 0,
      message: map['message']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'nickname': nickname,
    'email': email,
    'avatar': avatar,
    'coins': coins,
    'sales': sales,
    'bying': bying,
    'message': message,
  };
}
