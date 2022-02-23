import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:flutter_modular/flutter_modular.dart';

import 'src/app_module.dart';
import 'src/app_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Window.initialize();

  runApp(ModularApp(
    child: const MyApp(),
    module: AppModule(),
  ));

  await Window.setEffect(
    effect: WindowEffect.mica,
    color: const Color(0xCC222222),
  );
}
