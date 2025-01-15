import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/auth_service.dart';

import 'sample_feature/sample_item_details_view.dart';
import 'sample_feature/sample_item_list_view.dart';
import 'sample_feature/login_view.dart';
import 'sample_feature/signup_view.dart';
import 'sample_feature/home_view.dart';
import 'sample_feature/product_details_view.dart';
import 'settings/settings_controller.dart';
import 'settings/settings_view.dart';
import 'cart/cart_view.dart';
import 'checkout/checkout_view.dart';
import 'checkout/order_success_view.dart';
import 'orders/orders_view.dart';
import 'profile/profile_view.dart';

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.settingsController,
    required this.initialRoute,
  });

  final SettingsController settingsController;
  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''),
          ],
          onGenerateTitle: (BuildContext context) =>
              AppLocalizations.of(context)!.appTitle,
          theme: ThemeData(),
          darkTheme: ThemeData.dark(),
          themeMode: settingsController.themeMode,
          initialRoute: HomeView.routeName,
          routes: {
            HomeView.routeName: (context) => const HomeView(),
            LoginView.routeName: (context) => const LoginView(),
            SignupView.routeName: (context) => const SignupView(),
            CartView.routeName: (context) => const CartView(),
            OrdersView.routeName: (context) => const OrdersView(),
            ProfileView.routeName: (context) => const ProfileView(),
            CheckoutView.routeName: (context) => const CheckoutView(),
            OrderSuccessView.routeName: (context) => const OrderSuccessView(),
            ProductDetailsView.routeName: (context) => const ProductDetailsView(),
            SettingsView.routeName: (context) => SettingsView(controller: settingsController),
            SampleItemDetailsView.routeName: (context) => const SampleItemDetailsView(),
          },
        );
      },
    );
  }
}