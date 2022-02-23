import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:lazy_data_table_plus/lazy_data_table_plus.dart';
import 'package:localization/localization.dart';
import 'package:localization_ui/src/home/presenter/states/file_state.dart';
import 'package:localization_ui/src/home/presenter/stores/file_store.dart';
import 'package:path/path.dart' hide context;
import 'package:system_theme/system_theme.dart';

class SaveIntent extends Intent {}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _isPicked = false;
  var _hasEdited = false;
  final searchTextController = TextEditingController(text: '');
  String get _searchText => searchTextController.text;

  @override
  void initState() {
    super.initState();
    final store = context.read<FileStore>();
    store.addListener(() {
      final state = store.value;
      if (state is ErrorFileState) {
        showSnackbar(
          context,
          Snackbar(
            content: Text(state.error.message),
          ),
        );
      }
    });
  }

  final saveFileKeySet = LogicalKeySet(
    Platform.isMacOS ? LogicalKeyboardKey.meta : LogicalKeyboardKey.control,
    LogicalKeyboardKey.keyS,
  );

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FileStore>();
    final state = store.value;

    Widget child = Container();

    if (state is InitFileState) {
      child = Center(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'select-a-folder-initial-text'.i18n(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 18),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Button(
                  onPressed: _isPicked
                      ? null
                      : () async {
                          setState(() {
                            _isPicked = true;
                          });
                          final selectedDirectory = await FilePicker.platform.getDirectoryPath(lockParentWindow: false);
                          _isPicked = false;
                          if (selectedDirectory != null) {
                            store.setDirectoryAndLoad(selectedDirectory);
                          } else {
                            setState(() {});
                          }
                        },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(FluentIcons.edit),
                      const SizedBox(width: 9),
                      Text(
                        'select-a-directory'.i18n(),
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else if (state is LoadedFileState && state.languages.isEmpty) {
      child = Center(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Nenhum arquivo de tradução encontrado'.i18n(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 18),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Button(
                  onPressed: _isPicked
                      ? null
                      : () async {
                          setState(() {
                            _isPicked = true;
                          });
                          final selectedDirectory = await FilePicker.platform.getDirectoryPath(lockParentWindow: false);
                          _isPicked = false;
                          if (selectedDirectory != null) {
                            store.setDirectoryAndLoad(selectedDirectory);
                          } else {
                            setState(() {});
                          }
                        },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(FluentIcons.edit),
                      const SizedBox(width: 9),
                      Text(
                        'select-a-directory'.i18n(),
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else if (state is LoadedFileState && state.languages.isNotEmpty) {
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

      child = FocusableActionDetector(
        autofocus: true,
        shortcuts: {
          saveFileKeySet: SaveIntent(),
        },
        actions: {
          SaveIntent: CallbackAction(onInvoke: (e) {
            _hasEdited = false;
            store.saveLanguages();
          }),
        },
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.only(left: 30, right: 30, top: 10, bottom: 10),
              color: Colors.black.withOpacity(0.38),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Button(
                      onPressed: () {
                        _hasEdited = false;
                        store.saveLanguages();
                      },
                      child: Row(
                        children: [
                          const Icon(FluentIcons.save),
                          const SizedBox(width: 9),
                          Text('save'.i18n()),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Button(
                      onPressed: _isPicked
                          ? null
                          : () async {
                              setState(() {
                                _isPicked = true;
                              });
                              final selectedDirectory = await FilePicker.platform.getDirectoryPath(lockParentWindow: false);
                              _isPicked = false;
                              if (selectedDirectory != null) {
                                store.setDirectoryAndLoad(selectedDirectory);
                              } else {
                                setState(() {});
                              }
                            },
                      child: Row(
                        children: [
                          const Icon(FluentIcons.edit),
                          const SizedBox(width: 9),
                          Text(state.directory != null ? '${basename(state.directory!)}${_hasEdited ? '*' : ''}' : 'select-a-directory'.i18n()),
                        ],
                      ),
                    ),
                  ),
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
                  )
                ],
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: LazyDataTable(
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
                    return MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onLongPress: () {
                          Clipboard.setData(ClipboardData(text: key));
                          showSnackbar(context, Snackbar(content: Text('clipboard-text'.i18n())));
                        },
                        onTap: () {
                          _dialogUpdateKeyName(key);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Text(
                              key,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  dataCellBuilder: (int rowIndex, int columnIndex) {
                    final key = keys.elementAt(rowIndex);
                    final lang = state.languages[columnIndex];
                    var difference = _getDifferences(columnIndex, keys);

                    return Container(
                      alignment: Alignment.center,
                      //  margin: const EdgeInsets.only(bottom: 13),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      //   color: difference.any((e) => e == key) ? Theme.of(context).colorScheme.error : null,
                      child: Transform.translate(
                        offset: const Offset(0, 8),
                        child: TextFormBox(
                          maxLines: 3,
                          key: ValueKey('$key$columnIndex'),
                          // decoration: InputDecoration.collapsed(hintText: ''),
                          onChanged: (value) {
                            lang.set(key, value);
                            setState(() {
                              _hasEdited = true;
                            });
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
      );
    } else {
      child = const Center(
        child: ProgressRing(),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(seconds: 1),
      child: child,
    );
  }

  List<String> _getDifferences(int columnIndex, Set<String> keys) {
    final store = context.watch<FileStore>();
    final state = store.value;
    if (state.languages.length < 1) return [];

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
              _hasEdited = true;
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
                _hasEdited = true;
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
                _hasEdited = true;
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
                  _hasEdited = true;
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
    controller = AnimationController(vsync: this, duration: Duration(milliseconds: 800));
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

class CropTextForm extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final gap = size.height - 20;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, gap)
      ..lineTo(0, gap)
      ..lineTo(0, 0);

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
