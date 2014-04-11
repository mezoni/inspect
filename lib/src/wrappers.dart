library inspect.src.wrappers;

import "dart:mirrors";

@proxy
class ClassWrapper extends ObjectMirrorWrapper {
  ClassWrapper(String name, Uri library) {
    var lib = currentMirrorSystem().libraries[library];
    _mirror = lib.declarations[new Symbol(name)];
  }
}

@proxy
class ObjectMirrorWrapper {
  ObjectMirror _mirror;

  dynamic noSuchMethod(Invocation invocation) {
    var memberName = invocation.memberName;
    if (invocation.isGetter) {
      return _mirror.getField(memberName).reflectee;
    }

    if (invocation.isSetter) {
      var value = invocation.positionalArguments[0];
      _mirror.setField(memberName, value).reflectee;
    }

    if (invocation.isMethod) {
      var positionalArguments = invocation.positionalArguments;
      var namedArguments = invocation.namedArguments;
      return _mirror.invoke(memberName, positionalArguments, namedArguments).reflectee;
    }

    return super.noSuchMethod(invocation);
  }
}
