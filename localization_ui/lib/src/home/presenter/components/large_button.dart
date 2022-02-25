import 'package:fluent_ui/fluent_ui.dart';

class LargeButton extends StatelessWidget {
  final double? textSize;
  final Widget? icon;
  final String text;
  final void Function()? onTap;
  const LargeButton({Key? key, this.textSize, this.onTap, this.icon, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Button(
        onPressed: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) icon!,
            if (icon != null) const SizedBox(width: 9),
            Text(
              text,
              style: TextStyle(
                fontSize: textSize,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
