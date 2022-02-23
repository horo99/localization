import 'package:flutter_modular/flutter_modular.dart';

import 'home/domain/services/file_service.dart';
import 'home/domain/usecases/read_json.dart';
import 'home/domain/usecases/save_json.dart';
import 'home/infra/services/file_service.dart';
import 'home/presenter/home_page.dart';
import 'home/presenter/stores/file_store.dart';

class AppModule extends Module {
  @override
  final List<Bind> binds = [
    Bind.factory<FileService>((i) => FileServiceImpl()),
    Bind.factory<ReadJson>((i) => ReadJsonImpl(i())),
    Bind.factory<SaveJson>((i) => SaveJsonImpl(i())),
    Bind.lazySingleton((i) => FileStore(i(), i())),
  ];

  @override
  final List<ModularRoute> routes = [
    ChildRoute('/', child: (_, __) => const HomePage()),
  ];
}
