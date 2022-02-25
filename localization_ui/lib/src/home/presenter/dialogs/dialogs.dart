import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:localization/localization.dart';
import 'package:system_theme/system_theme.dart';

import '../formatters/remove_space.dart';
import '../stores/file_store.dart';

Future dialogAddKeyName(BuildContext context) async {
  return showDialog(
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

Future dialogUpdateKeyName(String oldKey, BuildContext context) async {
  return showDialog(
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
