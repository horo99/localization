import 'dart:convert';
import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:localization/localization.dart';
import 'package:localization_ui/src/home/domain/entities/language_file.dart';
import 'package:localization_ui/src/home/domain/errors/errors.dart';
import 'package:localization_ui/src/home/domain/services/file_service.dart';
import 'package:localization_ui/src/home/domain/usecases/delete_json.dart';
import 'package:localization_ui/src/home/domain/usecases/save_json.dart';
import '../../domain/usecases/read_json.dart';

class FileServiceImpl implements FileService {
  @override
  ReadJsonCallback getLanguages(String path) async {
    try {
      final directory = Directory(path);
      final languages = <LanguageFile>[];
      final streamFile = directory.list().where((file) {
        return file.path.endsWith('.json');
      });
      await for (var file in streamFile) {
        if (file is File) {
          var json = jsonDecode(await file.readAsString());
          json = json.cast<String, String>();
          final language = LanguageFile(file, json);
          languages.add(language);
        }
      }
      return Right(languages);
    } on FileSystemException catch (e, s) {
      if (e.osError?.errorCode == 2) {
        return Left(NotFoundFiles('read-file-error'.i18n(), s));
      }
      rethrow;
    }
  }

  @override
  SaveJsonCallback saveLanguages(List<LanguageFile> languages) async {
    for (var language in languages) {
      await _saveFile(language);
    }

    return const Right(unit);
  }

  Future<void> _saveFile(LanguageFile language) async {
    await language.file.writeAsString(jsonEncode(language.getMap()));
  }

  @override
  DeleteJsonCallback deleteLanguage(LanguageFile language) async {
    await language.file.delete();
    return const Right(unit);
  }
}
