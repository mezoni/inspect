inspect
=======

```dart
import "package:inspect/inspect.dart";

void main() {
  inspectPlatform();
  inspectPrivate();
  inspectStack();
}

void inspectPlatform() {
  printTitle("Dart platform");

  var isBrowser = DartPlatform.isBrowser;
  var scriptRoot = DartPlatform.scriptRoot;
  var packageRoot = DartPlatform.packageRoot;
  var uri = Uri.parse("package:inspect/inspect.dart");
  var resolvedPath = DartPlatform.resolvePackageUri(uri);

  print("isBrowser    : $isBrowser");
  print("scriptRoot   : $scriptRoot");
  print("packageRoot  : $packageRoot");
  print("package uri  : $uri");
  print("resolved path: $resolvedPath");
}

void inspectPrivate() {
  printTitle("Dart private");

  var type = new List().runtimeType;
  var typeName = DartPrivate.getTypeName(type);
  var uri = DartPrivate.getLibraryUri(type);
  var privateKey = DartPrivate.getPrivateKey(uri);

  print("type       : $type");
  print("type name  : $typeName");
  print("library uri: $uri");
  print("pivate key : $privateKey");

  if (DartPrivate.eval != null) {
    print("");
    
    var expr = "(x, y) => x + y";
    var x = 10;
    var y = 20;
    var func = DartPrivate.eval(expr, null);
    var result = func(x, y);

    print("expression : $expr");
    print("evaluate   : ($x, $y)");
    print("result     : $result");
  }
}

void inspectStack() {
  printTitle("Dart stack");

  var frame = new DartStack().getFrame(1);
  var raw = frame.raw;
  var source = frame.source;
  var file = frame.file;
  var lineNumber = frame.lineNumber;
  var caller = frame.caller;
  var typeName = frame.typeName;
  var methodName = frame.methodName;
  var isClosure = frame.isClosure;

  print("frame      : $raw");
  print("source     : $source");
  print("file       : $file");
  print("line number: $lineNumber");
  print("caller     : $caller");
  print("type name  : $typeName");
  print("method name: $methodName");
  print("is closure : $isClosure");
}

void printTitle(String title) {
  print("");
  print("=========================");
  print("Inspect: $title:");
  print("=========================");
}
```
Output:

```
=========================
Inspect: Dart platform:
=========================
isBrowser    : false
scriptRoot   : file:///home/user/dart/inspect/example
packageRoot  : file:///home/user/dart/inspect/example/packages
package uri  : package:inspect/inspect.dart
resolved path: file:///home/user/dart/inspect/example/packages/inspect/inspect.dart

=========================
Inspect: Dart private:
=========================
type       : List
type name  : _GrowableList
library uri: dart:core
pivate key : @0x36924d72

expression : (x, y) => x + y
evaluate   : (10, 20)
result     : 30

=========================
Inspect: Dart stack:
=========================
frame      : #1      inspectStack (file:///home/user/dart/inspect/example/example.dart:58:19)
source     : file:///home/user/dart/inspect/example/example.dart
file       : file:///home/user/dart/inspect/example/example.dart
line number: 58
caller     : inspectStack
type name  : 
method name: inspectStack
is closure : false
```