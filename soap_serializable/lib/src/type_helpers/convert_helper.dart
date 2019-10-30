// Copyright (c) 2018, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/type.dart';

import '../soap_key_utils.dart';
import '../shared_checkers.dart';
import '../type_helper.dart';

/// Information used by [ConvertHelper] when handling `SoapKey`-annotated
/// fields with `toSoap` or `fromSoap` values set.
class ConvertData {
  final String name;
  final DartType paramType;

  ConvertData(this.name, this.paramType);
}

abstract class TypeHelperContextWithConvert extends TypeHelperContext {
  ConvertData get serializeConvertData;

  ConvertData get deserializeConvertData;
}

class ConvertHelper extends TypeHelper<TypeHelperContextWithConvert> {
  const ConvertHelper();

  @override
  String serialize(DartType targetType, String expression, TypeHelperContextWithConvert context) {
    final toSoapData = context.serializeConvertData;
    if (toSoapData == null) {
      return null;
    }

    logFieldWithConversionFunction(context.fieldElement);

    assert(toSoapData.paramType is TypeParameterType ||
        // TODO: dart-lang/soap_serializable#531 - fix deprecated API usage
        // ignore: deprecated_member_use
        targetType.isAssignableTo(toSoapData.paramType));
    return '${toSoapData.name}($expression)';
  }

  @override
  String deserialize(DartType targetType, String expression, TypeHelperContextWithConvert context) {
    final fromSoapData = context.deserializeConvertData;
    if (fromSoapData == null) {
      return null;
    }

    logFieldWithConversionFunction(context.fieldElement);

    final asContent = asStatement(fromSoapData.paramType);
    return '${fromSoapData.name}($expression$asContent)';
  }
}
