// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:soap_annotation/soap_annotation.dart';
import 'package:source_gen/source_gen.dart';

import '../shared_checkers.dart';
import '../type_helper.dart';
import '../utils.dart';

class SoapHelper extends TypeHelper<TypeHelperContextWithConfig> {
  const SoapHelper();

  /// Simply returns the [expression] provided.
  ///
  /// By default, SOAP encoding in from `dart:convert` calls `toSoap()` on
  /// provided objects.
  @override
  String serialize(DartType targetType, String expression, TypeHelperContextWithConfig context) {
    if (!_canSerialize(context.config, targetType)) {
      return null;
    }

    if (context.config.explicitToSoap) {
      return '$expression${context.nullable ? '?' : ''}.toSoap()';
    }
    return expression;
  }

  @override
  String deserialize(DartType targetType, String expression, TypeHelperContextWithConfig context) {
    if (targetType is! InterfaceType) {
      return null;
    }

    final type = targetType as InterfaceType;
    final classElement = type.element;

    final fromSoapCtor = classElement.constructors.singleWhere((ce) => ce.name == 'fromSoap', orElse: () => null);

    var output = expression;
    if (fromSoapCtor != null) {
      var asCastType = fromSoapCtor.parameters.singleWhere((pe) => pe.isPositional).type;

      if (asCastType is InterfaceType) {
        final instantiated = _instantiate(asCastType as InterfaceType, type);
        if (instantiated != null) {
          asCastType = instantiated;
        }
      }

      output = context.deserialize(asCastType, output).toString();
    } else if (_annotation(context.config, type)?.createFactory == true) {
      if (context.config.anyMap) {
        output += ' as Map';
      } else {
        output += ' as Map<String, dynamic>';
      }
    } else {
      return null;
    }

    // TODO: the type could be imported from a library with a prefix!
    // github.com/dart-lang/soap_serializable/issues/19
    output = '${targetType.name}.fromSoap($output)';

    return commonNullPrefix(context.nullable, expression, output).toString();
  }
}

bool _canSerialize(SoapSerializable config, DartType type) {
  if (type is InterfaceType) {
    final toSoapMethod = _toSoapMethod(type);

    if (toSoapMethod != null) {
      // TODO: validate there are no required parameters
      return true;
    }

    if (_annotation(config, type)?.createToSoap == true) {
      // TODO: consider logging that we're assuming a user will wire up the
      // generated mixin at some point...
      return true;
    }
  }
  return false;
}

/// Returns an instantiation of [ctorParamType] by providing argument types
/// derived by matching corresponding type parameters from [classType].
InterfaceType _instantiate(InterfaceType ctorParamType, InterfaceType classType) {
  final argTypes = ctorParamType.typeArguments.map((arg) {
    final typeParamIndex = classType.typeParameters.indexWhere((e) => e.type == arg);
    if (typeParamIndex >= 0) {
      return classType.typeArguments[typeParamIndex];
    } else {
      // TODO: perhaps throw UnsupportedTypeError?
      return null;
    }
  }).toList();

  if (argTypes.any((e) => e == null)) {
    // TODO: perhaps throw UnsupportedTypeError?
    return null;
  }

  return ctorParamType.instantiate(argTypes);
}

SoapSerializable _annotation(SoapSerializable config, InterfaceType source) {
  final annotations = const TypeChecker.fromRuntime(SoapSerializable).annotationsOfExact(source.element, throwOnUnresolved: false).toList();

  if (annotations.isEmpty) {
    return null;
  }

  return mergeConfig(config, ConstantReader(annotations.single));
}

MethodElement _toSoapMethod(DartType type) => typeImplementations(type).map((dt) => dt is InterfaceType ? dt.getMethod('toSoap') : null).firstWhere((me) => me != null, orElse: () => null);
