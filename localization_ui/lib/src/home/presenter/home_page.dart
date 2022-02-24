import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:lazy_data_table_plus/lazy_data_table_plus.dart';
import 'package:localization/localization.dart';
import 'package:localization_ui/src/home/presenter/extensions/file_language_extension.dart';
import 'package:localization_ui/src/home/presenter/states/file_state.dart';
import 'package:localization_ui/src/home/presenter/stores/file_store.dart';
import 'package:system_theme/system_theme.dart';

import 'components/file_progress_widget.dart';
import 'components/initial_widget.dart';
import 'components/key_cell_widget.dart';
import 'components/select_folder_button.dart';

class SaveIntent extends Intent {}

class UndoIntent extends Intent {}

class RedoIntent extends Intent {}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _isIdeasBox = false;
  var _enableAnimationPane = false;

  final searchTextController = TextEditingController(text: '');
  String get _searchText => searchTextController.text;

  @override
  void initState() {
    super.initState();
    final store = context.read<FileStore>();
    store.observer(onError: (error) {
      showSnackbar(
        context,
        Snackbar(
          content: Text(error.message),
        ),
      );
    });
  }

  final saveFileKeySet = LogicalKeySet(
    Platform.isMacOS ? LogicalKeyboardKey.meta : LogicalKeyboardKey.control,
    LogicalKeyboardKey.keyS,
  );
  final undoFileKeySet = LogicalKeySet(
    Platform.isMacOS ? LogicalKeyboardKey.meta : LogicalKeyboardKey.control,
    LogicalKeyboardKey.keyZ,
  );

  final redoFileKeySet = LogicalKeySet(
    Platform.isMacOS ? LogicalKeyboardKey.meta : LogicalKeyboardKey.control,
    LogicalKeyboardKey.shift,
    LogicalKeyboardKey.keyZ,
  );

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FileStore>((s) => s.selectState);
    final state = store.state;

    Widget child = Container();

    if (store.isLoading) {
      child = const FileProgressWidget();
    } else if (state is InitFileState) {
      child = const InitialWidget();
    } else if (state is LoadedFileState) {
      final keys = state.keys.where((key) {
        if (_searchText.isEmpty || key.contains(_searchText)) {
          return true;
        }

        for (var lang in state.languages) {
          final text = lang.read(key).toLowerCase();
          if (text.contains(_searchText.toLowerCase())) {
            return true;
          }
        }
        return false;
      }).toSet();

      final openedPaneSize = MediaQuery.of(context).size.width - 300;

      child = ListView(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: _enableAnimationPane ? 300 : 0),
            curve: Curves.easeOut,
            onEnd: () {
              setState(() {
                _enableAnimationPane = false;
              });
            },
            width: !_isIdeasBox ? MediaQuery.of(context).size.width : openedPaneSize,
            child: FocusableActionDetector(
              autofocus: true,
              shortcuts: {
                saveFileKeySet: SaveIntent(),
                undoFileKeySet: UndoIntent(),
                redoFileKeySet: RedoIntent(),
              },
              actions: {
                SaveIntent: CallbackAction(onInvoke: (e) {
                  store.saveLanguages();
                  return true;
                }),
                UndoIntent: CallbackAction(onInvoke: (e) {
                  store.undo();
                  return true;
                }),
                RedoIntent: CallbackAction(onInvoke: (e) {
                  store.redo();
                  return true;
                }),
              },
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(left: 30, right: 30, top: 20, bottom: 20),
                    color: Colors.black.withOpacity(0.38),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Button(
                            onPressed: () {
                              store.saveLanguages();
                            },
                            child: Row(
                              children: [
                                const Icon(FluentIcons.save),
                                const SizedBox(width: 9),
                                Text('save'.i18n() + (!store.isSaved ? '*' : '')),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        const SelectFolderButton(),
                        const SizedBox(width: 20),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Button(
                            onPressed: _dialogAddKeyName,
                            child: Row(
                              children: [
                                const Icon(FluentIcons.translate),
                                const SizedBox(width: 9),
                                Text('new-key'.i18n()),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Button(
                            onPressed: !store.canUndo() ? null : store.undo,
                            child: const Icon(FluentIcons.undo),
                          ),
                        ),
                        const SizedBox(width: 5),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Button(
                            onPressed: !store.canRedo() ? null : store.redo,
                            child: const Icon(FluentIcons.redo),
                          ),
                        ),
                        const SizedBox(width: 20),
                        const Spacer(),
                        ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: 400,
                          ),
                          child: TextBox(
                            controller: searchTextController,
                            placeholder: 'search'.i18n() + '...',
                            suffix: _searchText.isEmpty
                                ? null
                                : MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: IconButton(
                                      icon: const Icon(FluentIcons.clear),
                                      onPressed: () {
                                        setState(() {
                                          searchTextController.text = '';
                                        });
                                      },
                                    ),
                                  ),
                            onChanged: (value) {
                              setState(() {});
                            },
                            cursorColor: Colors.white,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 10),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Button(
                            style: _isIdeasBox
                                ? ButtonStyle(
                                    backgroundColor: ButtonState.all<Color>(
                                      Colors.black.withOpacity(0.2),
                                    ),
                                  )
                                : const ButtonStyle(),
                            child: const Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Icon(FluentIcons.lightbulb),
                            ),
                            onPressed: () {
                              setState(() {
                                _enableAnimationPane = true;
                                _isIdeasBox = !_isIdeasBox;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: LazyDataTable(
                        key: ValueKey(store.undoAndRedoCount),
                        tableDimensions: const LazyDataTableDimensions(
                          cellHeight: 89,
                          cellWidth: 300,
                          columnHeaderHeight: 50,
                          rowHeaderWidth: 220,
                        ),
                        tableTheme: LazyDataTableTheme(
                          columnHeaderBorder: Border.all(color: Colors.black.withOpacity(0.38)),
                          rowHeaderBorder: Border.all(color: Colors.black.withOpacity(0.38)),
                          cellBorder: Border.all(color: Colors.black.withOpacity(0.12)),
                          cornerBorder: Border.all(color: Colors.black.withOpacity(0.38)),
                          columnHeaderColor: Colors.black.withOpacity(0.3),
                          rowHeaderColor: Colors.black.withOpacity(0.3),
                          //  cellColor: Colors.white,
                          cornerColor: Colors.black.withOpacity(0.3),
                        ),
                        columns: state.languages.length,
                        rows: keys.length,
                        columnHeaderBuilder: (int columnIndex) {
                          var difference = _getDifferences(columnIndex, keys);

                          if (difference.isNotEmpty) {
                            return Container(
                              alignment: Alignment.center,
                              child: Text(
                                '${state.languages[columnIndex].nameWithoutExtension} (${(difference.length > 1) ? 'missing-keys'.i18n([
                                        difference.length.toString(),
                                      ]) : 'missing-key'.i18n()})',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }
                          return Container(
                            alignment: Alignment.center,
                            child: Text(
                              state.languages[columnIndex].nameWithoutExtension,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                        rowHeaderBuilder: (int rowIndex) {
                          final key = keys.elementAt(rowIndex);
                          return KeyCellWidget(
                            keyName: key,
                            onLongPress: () {
                              Clipboard.setData(ClipboardData(text: key));
                              showSnackbar(context, Snackbar(content: Text('clipboard-text'.i18n())));
                            },
                            onEditKey: () {
                              _dialogUpdateKeyName(key);
                            },
                            onDeleteKey: () => store.removeKey(key),
                          );
                        },
                        dataCellBuilder: (int rowIndex, int columnIndex) {
                          final key = keys.elementAt(rowIndex);
                          final lang = state.languages[columnIndex];

                          return Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Transform.translate(
                              offset: const Offset(0, 8),
                              child: TextFormBox(
                                maxLines: 3,
                                key: ValueKey('$key$columnIndex'),
                                onChanged: (value) {
                                  final langsCopy = state.languages.map((e) => e.copy()).toList();
                                  final langLocal = langsCopy[columnIndex];
                                  langLocal.set(key, value);
                                  store.updateLanguages(langsCopy);
                                },
                                initialValue: lang.read(key),
                              ),
                            ),
                          );
                        },
                        cornerWidget: state.languages.isEmpty
                            ? null
                            : Center(
                                child: Text(
                                  'keys'.i18n(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const IdeaPaneWidget(),
        ],
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(seconds: 1),
      child: child,
    );
  }

  List<String> _getDifferences(int columnIndex, Set<String> keys) {
    final store = context.watch<FileStore>();
    final state = store.state;
    if (state.languages.isEmpty) return [];

    final lang = state.languages[columnIndex];

    var difference = keys.difference(lang.keys.toSet()).toList();

    return difference;
  }

  Future<void> _dialogAddKeyName() async {
    showDialog(
      context: context,
      builder: (context) {
        var key = '';
        return ContentDialog(
          title: Text('key-name'.i18n()),
          content: TextBox(
            textInputAction: TextInputAction.send,
            onSubmitted: (_) {
              if (key.isEmpty) {
                return;
              }
              context.read<FileStore>().addNewKey(key);
              Navigator.of(context).pop();
            },
            inputFormatters: [RemoveSpace()],
            onChanged: (value) => key = value,
            placeholder: 'key'.i18n(),
          ),
          actions: [
            Button(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('cancel'.i18n()),
            ),
            Button(
              onPressed: () {
                if (key.isEmpty) {
                  return;
                }
                context.read<FileStore>().addNewKey(key);
                Navigator.of(context).pop();
              },
              style: ButtonStyle(
                backgroundColor: ButtonState.all(SystemTheme.accentInstance.accent),
              ),
              child: Text('save'.i18n()),
            )
          ],
        );
      },
    );
  }

  Future<void> _dialogUpdateKeyName(String oldKey) async {
    showDialog(
      context: context,
      builder: (context) {
        var key = '';
        return ContentDialog(
          title: Text('edit-key'.i18n()),
          content: TextFormBox(
            textInputAction: TextInputAction.send,
            onFieldSubmitted: (text) {
              if (oldKey != key) {
                context.read<FileStore>().editKey(oldKey, key);
              }
              Navigator.of(context).pop();
            },
            inputFormatters: [RemoveSpace()],
            initialValue: oldKey,
            onChanged: (value) => key = value,
            placeholder: 'key'.i18n(),
          ),
          actions: [
            Button(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('cancel'.i18n()),
            ),
            Button(
              onPressed: () {
                if (oldKey != key) {
                  context.read<FileStore>().editKey(oldKey, key);
                }
                Navigator.of(context).pop();
              },
              style: ButtonStyle(
                backgroundColor: ButtonState.all(SystemTheme.accentInstance.accent),
              ),
              child: Text('save'.i18n()),
            )
          ],
        );
      },
    );
  }
}

class IdeaPaneWidget extends StatelessWidget {
  const IdeaPaneWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: double.infinity,
      color: Colors.black.withOpacity(0.58),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            const SizedBox(height: 30),
            Text(
              'tips'.i18n(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(5),
              ),
              padding: const EdgeInsets.all(15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 3.7, right: 10),
                    height: 10,
                    width: 10,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(child: Text('tip-long-click'.i18n())),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class CustomFloatButton extends StatefulWidget {
  final bool animate;
  final Widget? child;
  final void Function()? onPressed;
  const CustomFloatButton({Key? key, this.animate = false, this.onPressed, this.child}) : super(key: key);

  @override
  _CustomFloatButtonState createState() => _CustomFloatButtonState();
}

class _CustomFloatButtonState extends State<CustomFloatButton> with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void didUpdateWidget(covariant CustomFloatButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate) {
      controller.repeat(reverse: true);
    } else {
      controller.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container();
    // return FloatingActionButton(
    //   backgroundColor: Color.lerp(Colors.blue, Colors.red, controller.value),
    //   child: widget.child,
    //   onPressed: widget.onPressed,
    // );
  }
}

class RemoveSpace extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll(' ', '');
    return newValue.copyWith(
      text: text,
      selection: TextSelection.fromPosition(
        TextPosition(offset: text.length),
      ),
    );
  }
}
