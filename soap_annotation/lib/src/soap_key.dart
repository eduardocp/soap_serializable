// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'allowed_keys_helpers.dart';
import 'soap_serializable.dart';

/// An annotation used to specify how a field is serialized.
class SoapKey {
  /// The value to use if the source SOAP does not contain this key or if the
  /// value is `null`.
  final Object defaultValue;

  /// If `true`, generated code will throw a [DisallowedNullValueException] if
  /// the corresponding key exists, but the value is `null`.
  ///
  /// Note: this value does not affect the behavior of a SOAP map *without* the
  /// associated key.
  ///
  /// If [disallowNullValue] is `true`, [includeIfNull] will be treated as
  /// `false` to ensure compatibility between `toSoap` and `fromSoap`.
  ///
  /// If both [includeIfNull] and [disallowNullValue] are set to `true` on the
  /// same field, an exception will be thrown during code generation.
  final bool disallowNullValue;

  /// A [Function] to use when decoding the associated SOAP value to the
  /// annotated field.
  ///
  /// Must be a top-level or static [Function] that takes one argument mapping
  /// a SOAP literal to a value compatible with the type of the annotated field.
  ///
  /// When creating a class that supports both `toSoap` and `fromSoap`
  /// (the default), you should also set [toSoap] if you set [fromSoap].
  /// Values returned by [toSoap] should "round-trip" through [fromSoap].
  final Function fromSoap;

  /// `true` if the generator should ignore this field completely.
  ///
  /// If `null` (the default) or `false`, the field will be considered for
  /// serialization.
  final bool ignore;

  /// Whether the generator should include fields with `null` values in the
  /// serialized output.
  ///
  /// If `true`, the generator should include the field in the serialized
  /// output, even if the value is `null`.
  ///
  /// The default value, `null`, indicates that the behavior should be
  /// acquired from the [SoapSerializable.includeIfNull] annotation on the
  /// enclosing class.
  ///
  /// If [disallowNullValue] is `true`, this value is treated as `false` to
  /// ensure compatibility between `toSoap` and `fromSoap`.
  ///
  /// If both [includeIfNull] and [disallowNullValue] are set to `true` on the
  /// same field, an exception will be thrown during code generation.
  final bool includeIfNull;

  /// The key in a SOAP map to use when reading and writing values corresponding
  /// to the annotated fields.
  ///
  /// If `null`, the field name is used.
  final String name;

  /// When `true`, `null` fields are handled gracefully when encoding to SOAP
  /// and when decoding `null` and nonexistent values from SOAP.
  ///
  /// Setting to `false` eliminates `null` verification in the generated code
  /// for the annotated field, which reduces the code size. Errors may be thrown
  /// at runtime if `null` values are encountered, but the original class should
  /// also implement `null` runtime validation if it's critical.
  ///
  /// The default value, `null`, indicates that the behavior should be
  /// acquired from the [SoapSerializable.nullable] annotation on the
  /// enclosing class.
  final bool nullable;

  /// When `true`, generated code for `fromSoap` will verify that the source
  /// SOAP map contains the associated key.
  ///
  /// If the key does not exist, a [MissingRequiredKeysException] exception is
  /// thrown.
  ///
  /// Note: only the existence of the key is checked. A key with a `null` value
  /// is considered valid.
  final bool required;

  /// A [Function] to use when encoding the annotated field to SOAP.
  ///
  /// Must be a top-level or static [Function] with one parameter compatible
  /// with the field being serialized that returns a SOAP-compatible value.
  ///
  /// When creating a class that supports both `toSoap` and `fromSoap`
  /// (the default), you should also set [fromSoap] if you set [toSoap].
  /// Values returned by [toSoap] should "round-trip" through [fromSoap].
  final Function toSoap;

  /// The value to use for an enum field when the value provided is not in the
  /// source enum.
  ///
  /// Valid only on enum fields with a compatible enum value.
  final Object unknownEnumValue;

  /// Creates a new [SoapKey] instance.
  ///
  /// Only required when the default behavior is not desired.
  const SoapKey({
    this.defaultValue,
    this.disallowNullValue,
    this.fromSoap,
    this.ignore,
    this.includeIfNull,
    this.name,
    this.nullable,
    this.required,
    this.toSoap,
    this.unknownEnumValue,
  });
}
