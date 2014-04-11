import "package:inspect/inspect.dart";
import "package:path/path.dart" as pathos;
import "package:unittest/unittest.dart";

void main() {
  testBaseRoot();
  testIsBrowser();
  testPackagesRoot();
  testResolvePackageUri();
}

void testBaseRoot() {
  var subject = "DartPlatform.scriptRoot";
  var scriptRoot = DartPlatform.scriptRoot;
  var result = pathos.basename(scriptRoot.path);
  var reason = "$subject";
  expect(result, "test", reason: reason);
}

void testIsBrowser() {
  var subject = "DartPlatform.isBrowser";
  var result = DartPlatform.isBrowser;
  var reason = "$subject";
  expect(result, false, reason: reason);
}

void testPackagesRoot() {
  var subject = "DartPlatform.packagesRoot";
  var packageRoot = DartPlatform.packageRoot;
  var scriptRoot = DartPlatform.scriptRoot;
  var result = pathos.join(scriptRoot.path, "packages");
  var reason = "$subject";
  expect(result, packageRoot.path, reason: reason);
}

void testResolvePackageUri() {
  var subject = "DartPlatform.resolvePackageUri";
  var uri = Uri.parse("package:inspect/inspect.dart");
  uri = DartPlatform.resolvePackageUri(uri);
  var reason = "$subject";
  var packageRoot = DartPlatform.packageRoot;
  var scriptRoot = DartPlatform.scriptRoot;
  var result = pathos.join(scriptRoot.path, "packages", "inspect/inspect.dart");
  expect(result, uri.path, reason: reason);
}
