import 'package:flutter/material.dart';
import '../features/banned_countries/page/banned_countries_page.dart';
import '../features/card_form/page/card_form_page.dart';
import '../features/cards/page/cards_page.dart';
import '../features/settings/page/settings_page.dart';

class AppRouter {
  AppRouter._();

  static const String home = '/';
  static const String cardForm = '/card-form';
  static const String bannedCountries = '/banned-countries';
  static const String settings = '/settings';
  
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (_) => const CardsPage(),
        );
      case cardForm:
        return MaterialPageRoute(
          builder: (_) => const CardFormPage(),
        );
      case bannedCountries:
        return MaterialPageRoute(
          builder: (_) => const BannedCountriesPage(),
        );
      case AppRouter.settings:
        return MaterialPageRoute(
          builder: (_) => const SettingsPage(),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Route not found'),
            ),
          ),
        );
    }
  }
}