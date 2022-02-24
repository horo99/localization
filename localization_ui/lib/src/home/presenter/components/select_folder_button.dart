import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:localization/localization.dart';
import 'package:localization_ui/src/home/presenter/stores/file_store.dart';

class SelectFolderButton extends StatefulWidget {
  final double? textSize;
  const SelectFolderButton({Key? key, this.textSize}) : super(key: key);

  @override
  _SelectFolderButtonState createState() => _SelectFolderButtonState();
}

class _SelectFolderButtonState extends State<SelectFolderButton> {
  bool _isPicked = false;

  @override
  Widget build(BuildContext context) {
    final store = context.read<FileStore>();
    return MouseRegion(
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
              style: TextStyle(
                fontSize: widget.textSize,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
