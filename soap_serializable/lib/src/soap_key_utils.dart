// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:soap_annotation/soap_annotation.dart';
import 'package:source_gen/source_gen.dart';

import 'soap_literal_generator.dart';
import 'utils.dart';

final _soapKeyExpando = Expando<SoapKey>();

SoapKey soapKeyForField(FieldElement field, SoapSerializable classAnnotation) => _soapKeyExpando[field] ??= _from(field, classAnnotation);

/// Will log "info" if [element] has an explicit value for [SoapKey.nullable]
/// telling the programmer that it will be ignored.
void logFieldWithConversionFunction(FieldElement element) {
  final soapKey = _soapKeyExpando[element];
  if (_explicitNullableExpando[soapKey] ?? false) {
    log.info(
      'The `SoapKey.nullable` value on '
      '`${element.enclosingElement.name}.${element.name}` will be ignored '
      'because a custom conversion function is being used.',
    );

    _explicitNullableExpando[soapKey] = null;
  }
}

SoapKey _from(FieldElement element, SoapSerializable classAnnotation) {
  // If an annotation exists on `element` the source is a 'real' field.
  // If the result is `null`, check the getter – it is a property.
  // TODO(kevmoo) setters: github.com/dart-lang/soap_serializable/issues/24
  final obj = soapKeyAnnotation(element);

  if (obj == null) {
    return _populateSoapKey(
      classAnnotation,
      element,
      ignore: classAnnotation.ignoreUnannotated,
    );
  }

  /// Returns a literal value for [dartObject] if possible, otherwise throws
  /// an [InvalidGenerationSourceError] using [typeInformation] to describe
  /// the unsupported type.
  Object literalForObject(
    DartObject dartObject,
    Iterable<String> typeInformation,
  ) {
    if (dartObject.isNull) {
      return null;
    }

    final reader = ConstantReader(dartObject);

    String badType;
    if (reader.isSymbol) {
      badType = 'Symbol';
    } else if (reader.isType) {
      badType = 'Type';
    } else if (dartObject.type is FunctionType) {
      // TODO(kevmoo): Support calling function for the default value?
      badType = 'Function';
    } else if (!reader.isLiteral) {
      badType = dartObject.type.name;
    }

    if (badType != null) {
      badType = typeInformation.followedBy([badType]).join(' > ');
      throwUnsupported(element, '`defaultValue` is `$badType`, it must be a literal.');
    }

    final literal = reader.literalValue;

    if (literal is num || literal is String || literal is bool) {
      return literal;
    } else if (literal is List<DartObject>) {
      return [
        for (var e in literal)
          literalForObject(e, [
            ...typeInformation,
            'List',
          ])
      ];
    } else if (literal is Map<DartObject, DartObject>) {
      final mapTypeInformation = [
        ...typeInformation,
        'Map',
      ];
      return literal.map(
        (k, v) => MapEntry(
          literalForObject(k, mapTypeInformation),
          literalForObject(v, mapTypeInformation),
        ),
      );
    }

    badType = typeInformation.followedBy(['$dartObject']).join(' > ');

    throwUnsupported(
        element,
        'The provided value is not supported: $badType. '
        'This may be an error in package:soap_serializable. '
        'Please rerun your build with `--verbose` and file an issue.');
  }

  /// Returns a literal object representing the value of [fieldName] in [obj].
  ///
  /// If [mustBeEnum] is `true`, throws an [InvalidGenerationSourceError] if
  /// either the annotated field is not an `enum` or if the value in
  /// [fieldName] is not an `enum` value.
  Object _annotationValue(String fieldName, {bool mustBeEnum = false}) {
    final annotationValue = obj.getField(fieldName);

    final enumFields = iterateEnumFields(annotationValue.type);
    if (enumFields != null) {
      if (mustBeEnum && !isEnum(element.type)) {
        throwUnsupported(
          element,
          '`$fieldName` can only be set on fields of type enum.',
        );
      }
      final enumValueNames = enumFields.map((p) => p.name).toList(growable: false);

      final enumValueName = enumValueForDartObject<String>(annotationValue, enumValueNames, (n) => n);

      return '${annotationValue.type.name}.$enumValueName';
    } else {
      final defaultValueLiteral = literalForObject(annotationValue, []);
      if (defaultValueLiteral == null) {
        return null;
      }
      if (mustBeEnum) {
        throwUnsupported(
          element,
          'The value provided for `$fieldName` must be a matching enum.',
        );
      }
      return soapLiteralAsDart(defaultValueLiteral);
    }
  }

  return _populateSoapKey(
    classAnnotation,
    element,
    defaultValue: _annotationValue('defaultValue'),
    disallowNullValue: obj.getField('disallowNullValue').toBoolValue(),
    ignore: obj.getField('ignore').toBoolValue(),
    includeIfNull: obj.getField('includeIfNull').toBoolValue(),
    name: obj.getField('name').toStringValue(),
    nullable: obj.getField('nullable').toBoolValue(),
    required: obj.getField('required').toBoolValue(),
    unknownEnumValue: _annotationValue('unknownEnumValue', mustBeEnum: true),
  );
}

SoapKey _populateSoapKey(
  SoapSerializable classAnnotation,
  FieldElement element, {
  Object defaultValue,
  bool disallowNullValue,
  bool ignore,
  bool includeIfNull,
  String name,
  bool nullable,
  bool required,
  Object unknownEnumValue,
}) {
  if (disallowNullValue == true) {
    if (includeIfNull == true) {
      throwUnsupported(
          element,
          'Cannot set both `disallowNullvalue` and `includeIfNull` to `true`. '
          'This leads to incompatible `toSoap` and `fromSoap` behavior.');
    }
  }

  final soapKey = SoapKey(
    defaultValue: defaultValue,
    disallowNullValue: disallowNullValue ?? false,
    ignore: ignore ?? false,
    includeIfNull: _includeIfNull(includeIfNull, disallowNullValue, classAnnotation.includeIfNull),
    name: _encodedFieldName(classAnnotation, name, element),
    nullable: nullable ?? classAnnotation.nullable,
    required: required ?? false,
    unknownEnumValue: unknownEnumValue,
  );

  _explicitNullableExpando[soapKey] = nullable != null;

  return soapKey;
}

final _explicitNullableExpando = Expando<bool>('explicit nullable');

String _encodedFieldName(SoapSerializable classAnnotation, String soapKeyNameValue, FieldElement fieldElement) {
  if (soapKeyNameValue != null) {
    return soapKeyNameValue;
  }

  switch (classAnnotation.fieldRename) {
    case FieldRename.none:
      return fieldElement.name;
    case FieldRename.snake:
      return snakeCase(fieldElement.name);
    case FieldRename.kebab:
      return kebabCase(fieldElement.name);
    case FieldRename.pascal:
      return pascalCase(fieldElement.name);
  }

  throw ArgumentError.value(
    classAnnotation,
    'classAnnotation',
    'The provided `fieldRename` (${classAnnotation.fieldRename}) is not '
        'supported.',
  );
}

bool _includeIfNull(bool keyIncludeIfNull, bool keyDisallowNullValue, bool classIncludeIfNull) {
  if (keyDisallowNullValue == true) {
    assert(keyIncludeIfNull != true);
    return false;
  }
  return keyIncludeIfNull ?? classIncludeIfNull;
}
