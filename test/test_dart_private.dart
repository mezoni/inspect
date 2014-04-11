import "package:inspect/inspect.dart";
import "package:unittest/unittest.dart";

void main() {
  testEval();
  testGetLibraryUri();
  testGetPrivateKey();
}

void testEval() {
  var subject = "DartPrivate.eval()";
  if (DartPrivate.eval == null) {
    return null;
  }

  var code = "(x) => x";
  var expr = DartPrivate.eval(code, null);
  var result = expr("Hello");
  expect(result, "Hello", reason: "$subject $code");
}

void testGetLibraryUri() {
  var subject = "DartPrivate.getLibraryUri()";
  var uri = DartPrivate.getLibraryUri(0.runtimeType).toString();
  expect(uri, "dart:core");
}

void testGetPrivateKey() {
  var subject = "DartPrivate.getPrivateKey()";
  var uri = DartPrivate.getLibraryUri(0.runtimeType);
  var privateKey = DartPrivate.getPrivateKey(uri);
  expect(privateKey.isEmpty, false, reason: "$subject.isEmpty");
  expect(privateKey.startsWith("@"), true, reason: "$subject.startsWith('@')");
}
