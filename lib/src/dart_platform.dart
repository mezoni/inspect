part of inspect;

class DartPlatform {
  static final LibraryMirror _dartIoMirror = _getDartIoMirror();

  static final String _packagePath = packageRoot.toString();

  static final ClassWrapper _platformWrapper = _getPlatformWrapper();

  /*
   * Returns true if the operating system is "Android".
   */
  static final bool isAndroid = _getIsAndroid();

  /*
   * Returns true if the script is running in the browser.
   */
  static final bool isBrowser = _getIsBrowser();

  /*
   * Returns true if the operating system is "Linux".
   */
  static final bool isLinux = _getIsLinux();

  /*
   * Returns true if the operating system is "Mac OS".
   */
  static final bool isMacos = _getIsMacos();

  /*
   * Returns true if the the operating system implements the
   * POSIX API.
   */
  static final bool isPosix = _getIsPosix();

  /*
   * Returns true if the operating system is "Windows".
   */
  static final bool isWindows = _getIsWindows();

  /*
   * Returns the short name of the operating system.
   *
   * If the script is running in the browser returns "browser".
   */
  static final String operatingSystem = _getOperatingSystem();

  /*
   * Returns the absolute [Uri] of the package root.
   */
  static final Uri packageRoot = _getPackageRoot();

  /*
   * Returns the path separator.
   */
  static final String pathSeparator = _getPathSeparator();

  /*
   * Returns the root of the running script.
   */
  static final Uri scriptRoot = _getScriptRoot();

  /**
   * Resolves the "package:" [Uri] to absolute [Uri].
   */
  static Uri resolvePackageUri(Uri packageUri) {
    if (packageUri == null || packageUri.scheme != "package" || packageUri.path.isEmpty) {
      throw new ArgumentError("package: $packageUri");
    }

    if (_packagePath.isEmpty) {
      return UriHelper.blankUri;
    }

    return Uri.parse(UriHelper.join(_packagePath, packageUri.path));
  }

  static LibraryMirror _getDartIoMirror() {
    return currentMirrorSystem().libraries[Uri.parse("dart:io")];
  }

  static bool _getIsAndroid() {
    if (_platformWrapper == null) {
      return false;
    }

    return _platformWrapper.isAndroid;
  }

  static bool _getIsBrowser() {
    return _dartIoMirror == null;
  }

  static bool _getIsLinux() {
    if (_platformWrapper == null) {
      return false;
    }

    return _platformWrapper.isLinux;
  }

  static bool _getIsMacos() {
    if (_platformWrapper == null) {
      return false;
    }

    return _platformWrapper.isMacos;
  }

  static bool _getIsPosix() {
    if (_platformWrapper == null) {
      return false;
    }

    return !isWindows;
  }

  static bool _getIsWindows() {
    if (_platformWrapper == null) {
      return false;
    }

    return _platformWrapper.isWindows;
  }

  static String _getOperatingSystem() {
    if (_platformWrapper == null) {
      return "browser";
    }

    return _platformWrapper.operatingSystem;
  }

  static Uri _getPackageRoot() {
    var root = scriptRoot.toString();
    if (root.isEmpty) {
      return UriHelper.blankUri;
    }

    var packages = "packages";
    if (!isBrowser) {
      String packageRoot = _platformWrapper.packageRoot;
      if (!packageRoot.isEmpty) {
        if (isWindows) {
          packageRoot = packageRoot.replaceAll("\\", "/");
        }

        packageRoot = pathos.normalize(packageRoot);
        if (pathos.isAbsolute(packageRoot)) {
          return new Uri(scheme: "file", path: packageRoot);
        }

        packages = pathos.normalize(packageRoot);
      }
    }

    return Uri.parse(UriHelper.join(root, packages));
  }

  static String _getPathSeparator() {
    if (isBrowser) {
      return "/";
    }

    return _platformWrapper.pathSeparator;
  }

  static ClassWrapper _getPlatformWrapper() {
    return new ClassWrapper("Platform", Uri.parse("dart:io"));
  }

  static Uri _getScriptRoot() {
    Uri uri;
    if (isBrowser) {
      uri = Uri.base;
    } else {
      uri = currentMirrorSystem().isolate.rootLibrary.uri;
    }

    return Uri.parse(UriHelper.dirname(uri.toString()));
  }
}
