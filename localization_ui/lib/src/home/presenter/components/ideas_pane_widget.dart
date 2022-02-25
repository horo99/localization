import 'package:fluent_ui/fluent_ui.dart';
import 'package:localization/localization.dart';

class IdeasPaneWidget extends StatelessWidget {
  const IdeasPaneWidget({
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
