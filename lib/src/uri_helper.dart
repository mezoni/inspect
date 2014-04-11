library inspect.src.uri_helper;

import "package:inspect/inspect.dart";

class UriHelper {
  static final Uri blankUri = new Uri();

  static String dirname(String uri) {
    var length = uri.length;
    if (length == null) {
      return uri;
    }

    var found = false;
    var position = length - 1;
    int separator = DartPlatform.isWindows ? 92 : null;
    while (true) {
      if (position < 0) {
        break;
      }

      var c = uri.codeUnitAt(position--);
      if (c == 47 || c == separator) {
        found = true;
        break;
      }
    }

    if (!found) {
      return uri;
    }

    return uri.substring(0, position + 1);
  }

  static String join(String start, String end) {
    if (end.isEmpty) {
      return start;
    }

    var separator = DartPlatform.pathSeparator;
    return "$start$separator$end";
  }
}
