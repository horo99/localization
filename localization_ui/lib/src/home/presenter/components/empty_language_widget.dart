import 'package:fluent_ui/fluent_ui.dart';
import 'package:localization/localization.dart';

import '../dialogs/dialogs.dart';
import 'large_button.dart';

class EmptyLanguageWidget extends StatelessWidget {
  const EmptyLanguageWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'start-by-creating-a-language-file'.i18n(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 18),
            LargeButton(
              text: 'new-language'.i18n(),
              textSize: 18,
              onTap: () {
                dialogAddNewLanguage(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
