import 'package:flutter_triple/flutter_triple.dart';
import 'package:localization_ui/src/home/domain/usecases/read_json.dart';
import 'package:localization_ui/src/home/domain/usecases/save_json.dart';
import 'package:localization_ui/src/home/presenter/extensions/file_language_extension.dart';
import 'package:localization_ui/src/home/presenter/states/file_state.dart';

import '../../domain/entities/language_file.dart';
import '../../domain/errors/errors.dart';

// ignore: must_be_immutable
class FileStore extends StreamStore<FileServiceError, FileState> with MementoMixin {
  final ReadJson readJson;
  final SaveJson saveJson;

  int _undoAndRedoCount = 0;
  int get undoAndRedoCount => _undoAndRedoCount;
  FileState? _savedState;

  bool get isSaved => _savedState == state;

  FileStore(this.readJson, this.saveJson) : super(InitFileState());

  Future<void> setDirectoryAndLoad(String directory) async {
    setLoading(true);
    update(state.changeDirectory(directory));
    final result = await readJson.call(directory);
    await Future.delayed(const Duration(milliseconds: 500));

    result.map(state.loadedLanguages).fold(setError, update);
    _savedState = state;
    clearHistory();

    setLoading(false);
  }

  @override
  void undo() {
    super.undo();
    _undoAndRedoCount++;
  }

  @override
  void redo() {
    super.redo();
    _undoAndRedoCount++;
  }

  void updateLanguages(List<LanguageFile> langs) {
    update(state.loadedLanguages(langs));
  }

  Future<void> saveLanguages() async {
    setLoading(true);
    final result = await saveJson.call(state.languages);
    result.map((a) => state.loadedLanguages()).fold(setError, update);
    _savedState = state;

    setLoading(false);
  }

  void addNewKey(String key) {
    final langs = state.languages.map((e) => e.copy()).toList();
    for (var lang in langs) {
      lang.set(key, '');
    }
    update(state.loadedLanguages(langs));
  }

  void removeKey(String key) {
    final langs = state.languages.map((e) => e.copy()).toList();
    for (var lang in langs) {
      lang.deleteByKey(key);
    }
    update(state.loadedLanguages(langs));
  }

  void editKey(String oldKey, String key) {
    final langs = state.languages.map((e) => e.copy()).toList();

    for (var lang in langs) {
      final newMap = <String, String>{};
      final map = lang.getMap();
      for (var entryKey in map.keys) {
        if (entryKey == oldKey) {
          newMap[key] = map[entryKey]!;
        } else {
          newMap[entryKey] = map[entryKey]!;
        }
      }

      lang.setDicionary(newMap);
    }

    update(state.loadedLanguages(langs));
  }
}
