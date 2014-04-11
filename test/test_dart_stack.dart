import 'package:inspect/inspect.dart';
import 'package:path/path.dart' as pathos;
import 'package:unittest/unittest.dart';

void testLineNumber() {
  var subject = "DartStackFrame.lineNumber";
  var line = new DartStack().getFrame(1).lineNumber;
  expect(line, 7, reason: "$subject");
}

void main() {
  testIsClosure();
  testLineNumber();
  testMethodName();
  testSource();
  testTypeName();
}

void testIsClosure() {
  var subject = "DartStackFrame.isClosure";
  var object = new Foo();
  var reason = "$subject for getter";
  expect(object.getter.isClosure, false, reason: reason);
  reason = "$subject for method";
  expect(object.method().isClosure, false, reason: reason);
  reason = "$subject for method with closure";
  expect(object.methodWithClosure().isClosure, true, reason: reason);
  reason = "$subject for global method";
  expect(new DartStack().getFrame(1).isClosure, false, reason: reason);
  reason = "$subject for global method with closure";
  var frame = () {
    return new DartStack().getFrame(1);
  }();
  expect(frame.isClosure, true, reason: reason);
}

void testMethodName() {
  var subject = "DartStackFrame.typeName";
  var object = new Foo();
  var reason = "$subject for getter";
  expect(object.getter.methodName, "getter", reason: reason);
  reason = "$subject for method";
  expect(object.method().methodName, "method", reason: reason);
  reason = "$subject for method with closure";
  expect(object.methodWithClosure().methodName, "methodWithClosure", reason: reason);
  reason = "$subject for global method";
  expect(new DartStack().getFrame(1).methodName, "testMethodName", reason: reason);
  reason = "$subject for global method with closure";
  var frame = () {
    return new DartStack().getFrame(1);
  }();
  expect(frame.methodName, "testMethodName", reason: reason);
}

testSource() {
  var subject = "DartStackFrame.source";
  var frame = new DartStack().getFrame(1);
  var path = Uri.parse(frame.source).toFilePath();
  var file = pathos.basename(path);
  var reason = "$subject";
  expect(file, "test_dart_stack.dart", reason: reason);
}

void testTypeName() {
  var subject = "DartStackFrame.typeName";
  var object = new Foo();
  var className = object.runtimeType.toString();
  var reason = "$subject for getter";
  expect(object.getter.typeName, className, reason: reason);
  reason = "$subject for method";
  expect(object.method().typeName, className, reason: reason);
  reason = "$subject for method with closure";
  expect(object.methodWithClosure().typeName, className, reason: reason);
  reason = "$subject for global method";
  expect(new DartStack().getFrame(1).typeName, "", reason: reason);
  reason = "$subject for global method with closure";
  var frame = () {
    return new DartStack().getFrame(1);
  }();
  expect(frame.typeName, "", reason: reason);
}

class Foo {
  DartStackFrame get getter => new DartStack().getFrame(1);
  DartStackFrame method() => new DartStack().getFrame(1);
  DartStackFrame methodWithClosure() => () {
    return new DartStack().getFrame(1);
  }();
}
