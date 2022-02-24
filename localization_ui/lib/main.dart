import 'dart:io';

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

  if (Platform.isWindows) {
    await Window.setEffect(
      effect: WindowEffect.mica,
      color: const Color(0xCC222222),
    );
  }

  if (Platform.isMacOS) {
    await Window.setEffect(
      effect: WindowEffect.sidebar,
      dark: true,
      color: const Color(0xCC222222),
    );
  }
}
