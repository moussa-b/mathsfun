import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../l10n/app_localizations.dart';
import '../data/services/analytics_service.dart';
import '../data/services/flash_card_service.dart';
import '../data/services/profile_service.dart';
import '../data/services/reward_service.dart';
import '../data/services/session_service.dart';
import '../data/services/settings_service.dart';
import 'routes/app_router.dart';
import 'theme/app_theme.dart';

/// Root widget configuring theming, routing, and dependency injection.
class MathsFunApp extends StatelessWidget {
  const MathsFunApp({super.key});

  static final AppRouter _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: <SingleChildWidget>[
        ChangeNotifierProvider<SettingsService>(
          create: (_) => SettingsService(),
        ),
        ChangeNotifierProvider<ProfileService>(create: (_) => ProfileService()),
        ChangeNotifierProvider<SessionService>(create: (_) => SessionService()),
        ChangeNotifierProvider<RewardService>(create: (_) => RewardService()),
        ChangeNotifierProvider<FlashCardService>(
          create: (_) => FlashCardService(),
        ),
        ProxyProvider2<SessionService, FlashCardService, AnalyticsService>(
          update: (_, sessionService, flashCardService, __) => AnalyticsService(
            sessionService: sessionService,
            flashCardService: flashCardService,
          ),
        ),
      ],
      child: Consumer<SettingsService>(
        builder:
            (BuildContext context, SettingsService settingsService, Widget? _) {
              return MaterialApp.router(
                title: 'MathsFun',
                onGenerateTitle: (BuildContext context) =>
                    AppLocalizations.of(context).appTitle,
                theme: AppTheme.light,
                routerConfig: _appRouter.router,
                locale: settingsService.locale,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
              );
            },
      ),
    );
  }
}
