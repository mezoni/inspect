part of inspect;

class DartPrivate {
  static const int _NAME_START = 8;

  /**
   * Compiles the expression and returns the closure.
   *
   * This is an experimental feature and  it can be unavailable
   * at any time. If you need more information you can find it
   * in the Dart SDK source code.
   *
   * Usage: eval(String experession, String privateKey)
   *
   * String expr = "(x, y) => x + 1";
   * String privateKey = null;
   * var add = DartPrivate.eval(expr, privateKey);
   * var result = add(10, 20);
   */
  static final Function eval = _getEval();

  static final MirrorSystem _mirrorSystem = currentMirrorSystem();

  static Map<Uri, String> _privateKeys = new Map<Uri, String>();

  static Map<Type, Uri> _uri = new Map<Type, Uri>();

  /**
   * Returns the uri of the library for the specified [type].
   */
  static Uri getLibraryUri(Type type) {
    if (type == null) {
      throw new ArgumentError("type: $type");
    }

    var uri = _uri[type];
    if (uri != null) {
      return uri;
    }

    var typeMirror = reflectType(type);
    if (typeMirror is ClassMirror) {
      LibraryMirror library = typeMirror.owner;
      uri = library.uri;
    } else {
      uri = UriHelper.blankUri;
    }

    _uri[type] = uri;
    return uri;
  }

  /*
   * Returns the private key for the specified library uri.
   */
  static String getPrivateKey(Uri uri) {
    if (uri == null) {
      return "";
    }

    var privateKey = _privateKeys[uri];
    if (privateKey != null) {
      return privateKey;
    } else {
      privateKey = "";
    }

    var found = false;
    var library = _mirrorSystem.libraries[uri];
    for (var declaration in library.declarations.values) {
      var name = declaration.simpleName.toString();
      var length = name.length;
      if (length > _NAME_START && name.codeUnitAt(_NAME_START) != 95) {
        continue;
      }

      for (var i = _NAME_START + 1; i < length; i++) {
        if (name.codeUnitAt(i) == 64) {
          privateKey = name.substring(i, length - 2);
          _privateKeys[uri] = privateKey;
          found = true;
        }
      }

      if (found) {
        break;
      }
    }

    return privateKey;
  }

  /**
   * Returns the type name as defined in the type declaration.
   */
  static String getTypeName(Type type) {
    if (type == null) {
      throw new ArgumentError("type: $type");
    }

    return MirrorSystem.getName(reflectType(type).simpleName);
  }

  static Function _getEval() {
    var instance = reflect(null);
    var type = instance.runtimeType;
    var typeMirror = reflectType(type);
    var uri = getLibraryUri(type);
    var privateKey = getPrivateKey(uri);
    if (typeMirror is ClassMirror) {
      var name = new Symbol("_eval$privateKey");
      return typeMirror.getField(name).reflectee;
    }

    return null;
  }
}
