// Copyright (c) 2018, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';

import 'constants.dart';
import 'helper_core.dart';
import 'type_helpers/soap_converter_helper.dart';
import 'unsupported_type_error.dart';

abstract class EncodeHelper implements HelperCore {
  String _fieldAccess(FieldElement field) => '$_toSoapParamName.${field.name}';

  Iterable<String> createToSoap(Set<FieldElement> accessibleFields) sync* {
    assert(config.createToSoap);

    final buffer = StringBuffer();

    final functionName = '${prefix}ToSoap${genericClassArgumentsImpl(true)}';
    buffer.write('Map<String, dynamic> $functionName'
        '($targetClassReference $_toSoapParamName) ');

    final writeNaive = accessibleFields.every(_writeSoapValueNaive);

    if (writeNaive) {
      // write simple `toSoap` method that includes all keys...
      _writeToSoapSimple(buffer, accessibleFields);
    } else {
      // At least one field should be excluded if null
      _writeToSoapWithNullChecks(buffer, accessibleFields);
    }

    yield buffer.toString();
  }

  void _writeToSoapSimple(StringBuffer buffer, Iterable<FieldElement> fields) {
    buffer.writeln('=> <String, dynamic>{');

    buffer.writeAll(fields.map((field) {
      final access = _fieldAccess(field);
      final value = '${safeNameAccess(field)}: ${_serializeField(field, access)}';
      return '        $value,\n';
    }));

    buffer.writeln('};');
  }

  static const _toSoapParamName = 'instance';

  void _writeToSoapWithNullChecks(StringBuffer buffer, Iterable<FieldElement> fields) {
    buffer.writeln('{');

    buffer.writeln('    final $generatedLocalVarName = <String, dynamic>{');

    // Note that the map literal is left open above. As long as target fields
    // don't need to be intercepted by the `only if null` logic, write them
    // to the map literal directly. In theory, should allow more efficient
    // serialization.
    var directWrite = true;

    for (final field in fields) {
      var safeFieldAccess = _fieldAccess(field);
      final safeSoapKeyString = safeNameAccess(field);

      // If `fieldName` collides with one of the local helpers, prefix
      // access with `this.`.
      if (safeFieldAccess == generatedLocalVarName || safeFieldAccess == toSoapMapHelperName) {
        safeFieldAccess = 'this.$safeFieldAccess';
      }

      final expression = _serializeField(field, safeFieldAccess);
      if (_writeSoapValueNaive(field)) {
        if (directWrite) {
          buffer.writeln('      $safeSoapKeyString: $expression,');
        } else {
          buffer.writeln('    $generatedLocalVarName[$safeSoapKeyString] = $expression;');
        }
      } else {
        if (directWrite) {
          // close the still-open map literal
          buffer.writeln('    };');
          buffer.writeln();

          // write the helper to be used by all following null-excluding
          // fields
          buffer.writeln('''
    void $toSoapMapHelperName(String key, dynamic value) {
      if (value != null) {
        $generatedLocalVarName[key] = value;
      }
    }
''');
          directWrite = false;
        }
        buffer.writeln('    $toSoapMapHelperName($safeSoapKeyString, $expression);');
      }
    }

    buffer.writeln('    return $generatedLocalVarName;');
    buffer.writeln('  }');
  }

  String _serializeField(FieldElement field, String accessExpression) {
    try {
      return getHelperContext(field).serialize(field.type, accessExpression).toString();
    } on UnsupportedTypeError catch (e) {
      throw createInvalidGenerationError('toSoap', field, e);
    }
  }

  /// Returns `true` if the field can be written to SOAP 'naively' – meaning
  /// we can avoid checking for `null`.
  bool _writeSoapValueNaive(FieldElement field) {
    final soapKey = soapKeyFor(field);
    return soapKey.includeIfNull || (!soapKey.nullable && !_fieldHasCustomEncoder(field));
  }

  /// Returns `true` if [field] has a user-defined encoder.
  ///
  /// This can be either a `toSoap` function in [SoapKey] or a [SoapConverter]
  /// annotation.
  bool _fieldHasCustomEncoder(FieldElement field) {
    final helperContext = getHelperContext(field);
    return helperContext.serializeConvertData != null || const SoapConverterHelper().serialize(field.type, 'test', helperContext) != null;
  }
}
