import 'package:fluent_ui/fluent_ui.dart';
import 'package:localization/localization.dart';

import '../dialogs/dialogs.dart';
import 'large_button.dart';

class CreateNewKeyWidget extends StatelessWidget {
  const CreateNewKeyWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'add-a-key'.i18n(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 18),
            LargeButton(
              textSize: 18,
              onTap: () {
                dialogAddKeyName(context);
              },
              text: 'new-key'.i18n(),
            ),
          ],
        ),
      ),
    );
  }
}
