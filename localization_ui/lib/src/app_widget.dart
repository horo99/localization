import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:localization/localization.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FluentApp.router(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        accentColor: Colors.blue,
        brightness: Brightness.dark,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      localeResolutionCallback: (locale, supported) {
        return const Locale('en', 'US');
      },
      localizationsDelegates: [
        DefaultFluentLocalizations.delegate,
        LocalJsonLocalization.delegate,
      ],
      supportedLocales: const [
        // Locale('en'),
        Locale('en', 'US'),
      ],
      routerDelegate: Modular.routerDelegate,
      routeInformationParser: Modular.routeInformationParser,
      color: Colors.blue,
    );
  }
}
