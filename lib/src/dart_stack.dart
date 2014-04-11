part of inspect;

class DartStack {
  List<int> _chunks;

  List<DartStackFrame> _frames;

  int _frameCount;

  String _raw;

  StackTrace _stackTrace;

  DartStack() {
    try {
      throw "";
    } catch (e, s) {
      _stackTrace = s;
      _raw = s.toString();
    }
  }

  /**
   * Returns the number of stack frames.
   */
  int get frameCount {
    if (_frameCount == null) {
      _parseFrames();
    }

    return _frameCount;
  }

  /**
   * Returns the original stack trace.
   */
  StackTrace get stackTrace => _stackTrace;

  /**
   * Returns the stack frame by the specified [index].
   */
  DartStackFrame getFrame(int index) {
    if (index == null) {
      throw new ArgumentError("index: $index");
    }

    if (index < 0 || index > frameCount - 1) {
      throw new RangeError(index);
    }

    var result = _frames[index];
    if (result == null) {
      var raw = _raw.substring(_chunks[index], _chunks[index + 1] - 1);
      result = new DartStackFrame._internal(this, raw);
      _frames[index] = result;
    }

    return result;
  }

  void _parseFrames() {
    var length = _raw.length;
    var position = 0;
    _chunks = new List<int>();
    _chunks.add(0);
    while (true) {
      if (position == length) {
        break;
      }

      if (_raw.codeUnitAt(position++) == 10) {
        _chunks.add(position);
      }
    }

    if (position != length) {
      _chunks.add(length);
    }

    _frameCount = _chunks.length - 1;
    _frames = new List<DartStackFrame>(length);
  }
}

class DartStackFrame {
  static const String _ANONYMOUS_CLOSURE = "<anonymous closure>";

  String _caller = "";

  List<int> _callerSeparators = new List<int>();

  bool _isClosure;

  Uri _file;



  int _lineNumber = 1;

  String _methodName;

  DartStack _owner;

  String _raw = "";

  String _source;

  int _sourceEnd;

  int _sourceStart;

  String _typeName;

  Uri _uri;

  DartStackFrame._internal(this._owner, this._raw) {
    _parse();
  }

  /**
   * Returns the caller of this frame in form 'Class.method.<anonymous closure>'.
   */
  String get caller {
    return _caller;
  }

  /**
   * Returns true if the caller is a closure; otherwise false.
   */
  bool get isClosure {
    if (_isClosure == null) {
      _parseCaller();
    }

    return _isClosure;
  }

  /**
   * Returns the resolved file uri of the caller if this possible;
   * otherwise empty uri.
   */
  Uri get file {
    if (_file == null) {
      _file = _getFileUri();
    }

    return _file;
  }

  /*
   * Returns the line number of the caller.
   */
  int get lineNumber => _lineNumber;

  /**
   * Returns the method name.
   */
  String get methodName {
    if (_methodName == null) {
      _parseCaller();
    }

    return _methodName;
  }

  /**
   * Returns the raw frame string.
   */
  String get raw => _raw;

  /**
   * Returns the source location as a string.
   */
  String get source {
    if (_source == null) {
      if (_sourceStart != null && _sourceEnd != null) {
        _source = _raw.substring(_sourceStart, _sourceEnd);
      } else {
        _source = "";
      }
    }

    return _source;
  }

  /**
   * Returns the owner of this frame.
   */
  DartStack get stack => _owner;

  /**
    * Returns the type name of the caller.
    * If the caller is not a type returns empty string.
    */
  String get typeName {
    if (_typeName == null) {
      _parseCaller();
    }

    return _typeName;
  }

  /**
   * Returns the uri of source location.
   */
  Uri get uri {
    if (_uri == null) {
      _uri = Uri.parse(source);
    }

    return _uri;
  }

  Uri _getFileUri() {
    if (source == null || source.isEmpty) {
      return UriHelper.blankUri;
    }

    switch (uri.scheme) {
      case "dart":
      case "dart-ext":
        return UriHelper.blankUri;
      case "package":
        return DartPlatform.resolvePackageUri(uri);
    }

    return uri;
  }

  void _parse() {
    var length = _raw.length;
    var pos = 0;
    if (pos == length) {
      return;
    }

    // Skip "#"
    if (_raw.codeUnitAt(pos++) != 35) {
      return;
    }

    // Skip "frame number"
    while (true) {
      if (pos == length) {
        return;
      }

      if (_raw.codeUnitAt(pos++) == 32) {
        break;
      }
    }

    // Skip spaces between "frame number" and "caller"
    while (true) {
      if (pos == length) {
        return;
      }

      if (_raw.codeUnitAt(pos++) != 32) {
        break;
      }
    }

    var callerStart = pos - 1;
    // Parse "caller"
    while (true) {
      if (pos == length) {
        return;
      }

      var c = _raw.codeUnitAt(pos++);
      if (c == 46) {
        _callerSeparators.add(pos - callerStart - 1);
      } else if (c == 40) {
        var end = pos - 1;
        while (true) {
          if (_raw.codeUnitAt(end--) != 32) {
            break;
          }
        }

        _caller = _raw.substring(callerStart, end);
        break;
      }
    }

    // Parse "source url"
    _sourceStart = pos;
    var separators = [];
    while (true) {
      if (pos == length) {
        return;
      }

      var c = _raw.codeUnitAt(pos++);
      if (c == 58) {
        separators.add(pos - 1);
      } else if (c == 41) {
        break;
      }
    }

    // Locate "line number"
    _sourceEnd = pos - 1;
    var lineLength = 0;
    for (int start,
        i = separators.length - 1; i >= 0; i--, lineLength = _sourceEnd - start, _sourceEnd = start - 1) {
      start = separators[i] + 1;
      var success = false;
      for (var j = start; j < _sourceEnd; j++) {
        var c = _raw.codeUnitAt(j);
        if (c >= 48 && c <= 57) {
          success = true;
        } else {
          success = false;
          break;
        }
      }

      if (!success) {
        break;
      }
    }

    // Parse "line number"
    if (_sourceEnd != pos - 1) {
      var number = 0;
      var power = 1;
      var start = _sourceEnd + 1;
      for (var i = lineLength - 1; i >= 0; i--, power *= 10) {
        number += (_raw.codeUnitAt(start + i) - 48) * power;
      }

      _lineNumber = number;
    }
  }

  void _parseCaller() {
    var caller = this.caller;
    _isClosure = false;
    _methodName = "";
    _typeName = "";
    var length = _caller.length;
    var count = _callerSeparators.length;
    if (count == 0) {
      _methodName = _caller;
      return;
    }

    var start = _callerSeparators[0] + 1;
    var next = count == 1 ? length : _callerSeparators[1];
    var part2 = _caller.substring(start, next);
    if (part2 == _ANONYMOUS_CLOSURE) {
      _methodName = _caller.substring(0, start - 1);
      _isClosure = true;
      return;
    }

    _typeName = _caller.substring(0, start - 1);
    _methodName = _caller.substring(start, next);
    if (count > 1) {
      _isClosure = true;
    }
  }

  String toString() => _raw;
}
