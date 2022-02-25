import 'package:fpdart/fpdart.dart';
import 'package:localization_ui/src/home/domain/entities/language_file.dart';
import 'package:localization_ui/src/home/domain/errors/errors.dart';
import 'package:localization_ui/src/home/domain/services/file_service.dart';

typedef DeleteJsonCallback = Future<Either<FileServiceError, Unit>>;

abstract class DeleteJson {
  DeleteJsonCallback call(LanguageFile language);
}

class DeleteJsonImpl implements DeleteJson {
  final FileService _service;

  DeleteJsonImpl(this._service);

  @override
  DeleteJsonCallback call(LanguageFile language) async {
    return await _service.deleteLanguage(language);
  }
}
