class UserModel {
  String nickname;
  String email;
  String avatar;
  int coins;
  int buying;
  int sales;
  String message;
  int individualBuy;
  int individualSell;

  UserModel({
    required this.nickname,
    required this.email,
    this.avatar = '',
    this.coins = 0,
    this.buying = 0,
    this.sales = 0,
    this.message = 'Good day',
    this.individualBuy = 0,
    this.individualSell = 0,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      nickname: data['nickname'] ?? '',
      email: data['email'] ?? '',
      avatar: data['avatar'] ?? '',
      coins: data['coins'] ?? 0,
      buying: data['buying'] ?? 0,
      sales: data['sales'] ?? 0,
      message: data['message'] ?? '',
      individualBuy: data['individualBuy'] ?? 0,
      individualSell: data['individualSell'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
    'nickname': nickname,
    'email': email,
    'avatar': avatar,
    'coins': coins,
    'buying': buying,
    'sales': sales,
    'message': message,
    'individualBuy': individualBuy,
    'individualSell': individualSell,
  };
}