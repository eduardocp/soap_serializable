// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'allowed_keys_helpers.dart';

/// Helper function used in generated code when
/// `SoapSerializableGenerator.checked` is `true`.
///
/// Should not be used directly.
T $checkedNew<T>(String className, Map map, T constructor(), {Map<String, String> fieldKeyMap}) {
  fieldKeyMap ??= const {};

  try {
    return constructor();
  } on CheckedFromSoapException catch (e) {
    if (identical(e.map, map) && e._className == null) {
      e._className = className;
    }
    rethrow;
  } catch (error, stack) {
    String key;
    if (error is ArgumentError) {
      key = fieldKeyMap[error.name] ?? error.name;
    } else if (error is MissingRequiredKeysException) {
      key = error.missingKeys.first;
    } else if (error is DisallowedNullValueException) {
      key = error.keysWithNullValues.first;
    }
    throw CheckedFromSoapException._(error, stack, map, key, className: className);
  }
}

/// Helper function used in generated code when
/// `SoapSerializableGenerator.checked` is `true`.
///
/// Should not be used directly.
T $checkedConvert<T>(Map map, String key, T castFunc(Object value)) {
  try {
    return castFunc(map[key]);
  } on CheckedFromSoapException {
    rethrow;
  } catch (error, stack) {
    throw CheckedFromSoapException._(error, stack, map, key);
  }
}

/// Exception thrown if there is a runtime exception in `fromSoap`
/// code generated when `SoapSerializableGenerator.checked` is `true`
class CheckedFromSoapException implements Exception {
  /// The [Error] or [Exception] that triggered this exception.
  ///
  /// If this instance was created by user code, this field will be `null`.
  final Object innerError;

  /// The [StackTrace] for the [Error] or [Exception] that triggered this
  /// exception.
  ///
  /// If this instance was created by user code, this field will be `null`.
  final StackTrace innerStack;

  /// The key from [map] that corresponds to the thrown [innerError].
  ///
  /// May be `null`.
  final String key;

  /// The source [Map] that was used for decoding when the [innerError] was
  /// thrown.
  final Map map;

  /// A human-readable message corresponding to [innerError].
  ///
  /// May be `null`.
  final String message;

  /// The name of the class being created when [innerError] was thrown.
  String get className => _className;
  String _className;

  /// If this was thrown due to an invalid or unsupported key, as opposed to an
  /// invalid value.
  final bool badKey;

  /// Creates a new instance of [CheckedFromSoapException].
  CheckedFromSoapException(
    this.map,
    this.key,
    String className,
    this.message, {
    bool badKey = false,
  })  : _className = className,
        badKey = badKey ?? false,
        innerError = null,
        innerStack = null;

  CheckedFromSoapException._(
    this.innerError,
    this.innerStack,
    this.map,
    this.key, {
    String className,
  })  : _className = className,
        badKey = innerError is BadKeyException,
        message = _getMessage(innerError);

  static String _getMessage(Object error) {
    if (error is ArgumentError) {
      return error.message?.toString();
    } else if (error is BadKeyException) {
      return error.message;
    } else if (error is FormatException) {
      var message = error.message;
      if (error.offset != null) {
        message = '$message at offset ${error.offset}.';
      }
      return message;
    }
    return null;
  }

  @override
  String toString() => <String>[
        'CheckedFromSoapException',
        if (_className != null) 'Could not create `$_className`.',
        if (key != null) 'There is a problem with "$key".',
        if (message != null) message,
        if (message == null && innerError != null) innerError.toString(),
      ].join('\n');
}
