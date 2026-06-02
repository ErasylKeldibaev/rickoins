import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'states/main_screen_state.dart';
import 'ui/cabinet_page.dart';
import 'ui/sign_in_sign_up/login_page.dart';
import 'ui/sign_in_sign_up/registration_page.dart';
import 'ui/info_page.dart';
import 'ui/market_page.dart';
import 'ui/offerta_page.dart';
import 'ui/payment_page.dart';
import 'components/pdf_viewer.dart';
import 'components/word_viewer.dart';
import 'ui/splash_page.dart';
import 'ui/two_person_trade_page.dart';

class AppNavigation {
  static const String splash = '/';
  static const String home = '/home';
  static const String market = '/market';
  static const String cabinet = '/cabinet';
  static const String infoPage = '/info_page';
  static const String offerta = '/offerta';
  static const String payment = '/payment';
  static const String login = '/login';
  static const String registration = '/registration';
  static const String pdfView = '/pdf_view';
  static const String wordView = '/word_view';
  static const String twoPersonTradePage = '/two_person_trade_page';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final bool isLoggedIn = FirebaseAuth.instance.currentUser != null;
    final List<String> protectedRoutes = [market, cabinet, payment, pdfView];

    if (protectedRoutes.contains(settings.name) && !isLoggedIn) {
      return MaterialPageRoute(builder: (_) => const LoginPage());
    }

    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case registration:
        return MaterialPageRoute(builder: (_) => const RegistrationPage());
      case home:
        return MaterialPageRoute(builder: (_) => const MainScreen());
      case market:
        return MaterialPageRoute(builder: (_) => const MarketPage());
      case cabinet:
        return MaterialPageRoute(builder: (_) => const CabinetPage());
      case infoPage:
        return MaterialPageRoute(builder: (_) => const InfoPage());
      case offerta:
        return MaterialPageRoute(builder: (_) => const OffertaPage());
      case payment:
        final args = (settings.arguments as Map<String, dynamic>?) ?? {};
        return MaterialPageRoute(
          builder: (_) => PaymentPage(
            partnerUid: args['partnerId'] ?? '',
            passedAmount: args['passed_amount'] ?? 0,
            partnerNickname: args['partnerNickname'] ?? 'Partner',
            pageLable: args['pageLable'] ?? '',
          ),
        );
      case twoPersonTradePage:
        final args = (settings.arguments as Map<String, dynamic>?) ?? {};
        return MaterialPageRoute(
          builder: (_) => TwoPersonTradePage(
            nickname: args['nickname'].toString(),
            uid: args['uid'].toString(),
          ),
        );
      case pdfView:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => PDFViewScreen(
            url: args['url'],
            title: args['title'],
            authorId: args['authorId'],
          ),
        );
      case wordView:
        final argsW = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => WordReadingPage(
            url: argsW['url'],
            title: argsW['title'],
            authorId: argsW['authorId'],
          ),
        );
      default:
        return MaterialPageRoute(builder: (_) => const MainScreen());
    }
  }
}