import 'package:window_size/window_size.dart' as window_size;

class WindowService {
  final _appName = 'Localization UI';

  WindowService() {
    setWindowTitle(_appName);
  }

  void setWindowTitle(String title) {
    window_size.setWindowTitle(title);
  }

  void concatTextWithAppName(String value) {
    window_size.setWindowTitle(_appName + ' - ' + value);
  }
}
