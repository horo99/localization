import 'package:fluent_ui/fluent_ui.dart';

class FileProgressWidget extends StatelessWidget {
  const FileProgressWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: ProgressRing(),
    );
  }
}
