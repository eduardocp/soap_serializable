// Copyright (c) 2018, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:soap_annotation/soap_annotation.dart';
import 'package:source_gen/source_gen.dart';

import '../helper_core.dart';
import '../soap_key_utils.dart';
import '../lambda_result.dart';
import '../shared_checkers.dart';
import '../type_helper.dart';

/// A [TypeHelper] that supports classes annotated with implementations of
/// [SoapConverter].
class SoapConverterHelper extends TypeHelper {
  const SoapConverterHelper();

  @override
  Object serialize(DartType targetType, String expression, TypeHelperContext context) {
    final converter = _typeConverter(targetType, context);

    if (converter == null) {
      return null;
    }

    logFieldWithConversionFunction(context.fieldElement);

    return LambdaResult(expression, '${converter.accessString}.toSoap');
  }

  @override
  Object deserialize(DartType targetType, String expression, TypeHelperContext context) {
    final converter = _typeConverter(targetType, context);
    if (converter == null) {
      return null;
    }

    final asContent = asStatement(converter.soapType);

    logFieldWithConversionFunction(context.fieldElement);

    return LambdaResult('$expression$asContent', '${converter.accessString}.fromSoap');
  }
}

class _SoapConvertData {
  final String accessString;
  final DartType soapType;

  _SoapConvertData.className(String className, String accessor, this.soapType) : accessString = 'const $className${_withAccessor(accessor)}()';

  _SoapConvertData.genericClass(String className, String genericTypeArg, String accessor, this.soapType) : accessString = '$className<$genericTypeArg>${_withAccessor(accessor)}()';

  _SoapConvertData.propertyAccess(this.accessString, this.soapType);

  static String _withAccessor(String accessor) => accessor.isEmpty ? '' : '.$accessor';
}

_SoapConvertData _typeConverter(DartType targetType, TypeHelperContext ctx) {
  List<_ConverterMatch> converterMatches(List<ElementAnnotation> items) => items.map((annotation) => _compatibleMatch(targetType, annotation)).where((dt) => dt != null).toList();

  var matchingAnnotations = converterMatches(ctx.fieldElement.metadata);

  if (matchingAnnotations.isEmpty) {
    matchingAnnotations = converterMatches(ctx.fieldElement.getter?.metadata ?? []);

    if (matchingAnnotations.isEmpty) {
      matchingAnnotations = converterMatches(ctx.classElement.metadata);
    }
  }

  return _typeConverterFrom(matchingAnnotations, targetType);
}

_SoapConvertData _typeConverterFrom(List<_ConverterMatch> matchingAnnotations, DartType targetType) {
  if (matchingAnnotations.isEmpty) {
    return null;
  }

  if (matchingAnnotations.length > 1) {
    final targetTypeCode = typeToCode(targetType);
    throw InvalidGenerationSourceError('Found more than one matching converter for `$targetTypeCode`.', element: matchingAnnotations[1].elementAnnotation.element);
  }

  final match = matchingAnnotations.single;

  final annotationElement = match.elementAnnotation.element;
  if (annotationElement is PropertyAccessorElement) {
    final enclosing = annotationElement.enclosingElement;

    var accessString = annotationElement.name;

    if (enclosing is ClassElement) {
      accessString = '${enclosing.name}.$accessString';
    }

    return _SoapConvertData.propertyAccess(accessString, match.soapType);
  }

  final reviver = ConstantReader(match.annotation).revive();

  if (reviver.namedArguments.isNotEmpty || reviver.positionalArguments.isNotEmpty) {
    throw InvalidGenerationSourceError('Generators with constructor arguments are not supported.', element: match.elementAnnotation.element);
  }

  if (match.genericTypeArg != null) {
    return _SoapConvertData.genericClass(match.annotation.type.name, match.genericTypeArg, reviver.accessor, match.soapType);
  }

  return _SoapConvertData.className(match.annotation.type.name, reviver.accessor, match.soapType);
}

class _ConverterMatch {
  final DartObject annotation;
  final DartType soapType;
  final ElementAnnotation elementAnnotation;
  final String genericTypeArg;

  _ConverterMatch(this.elementAnnotation, this.annotation, this.soapType, this.genericTypeArg);
}

_ConverterMatch _compatibleMatch(DartType targetType, ElementAnnotation annotation) {
  final constantValue = annotation.computeConstantValue();

  final converterClassElement = constantValue.type.element as ClassElement;

  final soapConverterSuper = converterClassElement.allSupertypes.singleWhere((e) => e is InterfaceType && _soapConverterChecker.isExactly(e.element), orElse: () => null);

  if (soapConverterSuper == null) {
    return null;
  }

  assert(soapConverterSuper.typeParameters.length == 2);
  assert(soapConverterSuper.typeArguments.length == 2);

  final fieldType = soapConverterSuper.typeArguments[0];

  // TODO: dart-lang/soap_serializable#531 - fix deprecated API usage
  // ignore: deprecated_member_use
  if (fieldType.isEquivalentTo(targetType)) {
    return _ConverterMatch(annotation, constantValue, soapConverterSuper.typeArguments[1], null);
  }

  if (fieldType is TypeParameterType && targetType is TypeParameterType) {
    assert(annotation.element is! PropertyAccessorElement);
    assert(converterClassElement.typeParameters.isNotEmpty);
    if (converterClassElement.typeParameters.length > 1) {
      throw InvalidGenerationSourceError(
          '`SoapConverter` implementations can have no more than one type '
          'argument. `${converterClassElement.name}` has '
          '${converterClassElement.typeParameters.length}.',
          element: converterClassElement);
    }

    return _ConverterMatch(annotation, constantValue, soapConverterSuper.typeArguments[1], targetType.name);
  }

  return null;
}

const _soapConverterChecker = TypeChecker.fromRuntime(SoapConverter);
