// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'allowed_keys_helpers.dart';
import 'checked_helpers.dart';
import 'soap_key.dart';

part 'soap_serializable.g.dart';

/// Values for the automatic field renaming behavior for [SoapSerializable].
enum FieldRename {
  /// Use the field name without changes.
  none,

  /// Encodes a field named `kebabCase` with a SOAP key `kebab-case`.
  kebab,

  /// Encodes a field named `snakeCase` with a SOAP key `snake_case`.
  snake,

  /// Encodes a field named `pascalCase` with a SOAP key `PascalCase`.
  pascal
}

/// An annotation used to specify a class to generate code for.
@SoapSerializable(
  checked: true,
  disallowUnrecognizedKeys: true,
  fieldRename: FieldRename.snake,
)
class SoapSerializable {
  /// If `true`, [Map] types are *not* assumed to be [Map<String, dynamic>]
  /// – which is the default type of [Map] instances return by SOAP decode in
  /// `dart:convert`.
  ///
  /// This will increase the code size, but allows [Map] types returned
  /// from other sources, such as `package:yaml`.
  ///
  /// *Note: in many cases the key values are still assumed to be [String]*.
  final bool anyMap;

  /// If `true`, generated `fromSoap` functions include extra checks to validate
  /// proper deserialization of types.
  ///
  /// If an exception is thrown during deserialization, a
  /// [CheckedFromSoapException] is thrown.
  final bool checked;

  /// If `true` (the default), a private, static `_$ExampleFromSoap` method
  /// is created in the generated part file.
  ///
  /// Call this method from a factory constructor added to the source class:
  ///
  /// ```dart
  /// @SoapSerializable()
  /// class Example {
  ///   // ...
  ///   factory Example.fromSoap(Map<String, dynamic> soap) =>
  ///     _$ExampleFromSoap(soap);
  /// }
  /// ```
  final bool createFactory;

  /// If `true` (the default), A top-level function is created that you can
  /// reference from your class.
  ///
  /// ```dart
  /// @SoapSerializable()
  /// class Example {
  ///   Map<String, dynamic> toSoap() => _$ExampleToSoap(this);
  /// }
  /// ```
  final bool createToSoap;

  /// If `false` (the default), then the generated `FromSoap` function will
  /// ignore unrecognized keys in the provided SOAP [Map].
  ///
  /// If `true`, unrecognized keys will cause an [UnrecognizedKeysException] to
  /// be thrown.
  final bool disallowUnrecognizedKeys;

  /// If `true`, generated `toSoap` methods will explicitly call `toSoap` on
  /// nested objects.
  ///
  /// When using SOAP encoding support in `dart:convert`, `toSoap` is
  /// automatically called on objects, so the default behavior
  /// (`explicitToSoap: false`) is to omit the `toSoap` call.
  ///
  /// Example of `explicitToSoap: false` (default)
  ///
  /// ```dart
  /// Map<String, dynamic> toSoap() => {'child': child};
  /// ```
  ///
  /// Example of `explicitToSoap: true`
  ///
  /// ```dart
  /// Map<String, dynamic> toSoap() => {'child': child?.toSoap()};
  /// ```
  final bool explicitToSoap;

  /// Defines the automatic naming strategy when converting class field names
  /// into SOAP map keys.
  ///
  /// With a value [FieldRename.none] (the default), the name of the field is
  /// used without modification.
  ///
  /// See [FieldRename] for details on the other options.
  ///
  /// Note: the value for [SoapKey.name] takes precedence over this option for
  /// fields annotated with [SoapKey].
  final FieldRename fieldRename;

  /// When `true`, only fields annotated with [SoapKey] will have code
  /// generated.
  ///
  /// It will have the same effect as if those fields had been annotated with
  /// `@SoapKey(ignore: true)`.
  final bool ignoreUnannotated;

  /// Whether the generator should include fields with `null` values in the
  /// serialized output.
  ///
  /// If `true` (the default), all fields are written to SOAP, even if they are
  /// `null`.
  ///
  /// If a field is annotated with `SoapKey` with a non-`null` value for
  /// `includeIfNull`, that value takes precedent.
  final bool includeIfNull;

  /// When `true` (the default), `null` fields are handled gracefully when
  /// encoding to SOAP and when decoding `null` and nonexistent values from
  /// SOAP.
  ///
  /// Setting to `false` eliminates `null` verification in the generated code,
  /// which reduces the code size. Errors may be thrown at runtime if `null`
  /// values are encountered, but the original class should also implement
  /// `null` runtime validation if it's critical.
  final bool nullable;

  /// Creates a new [SoapSerializable] instance.
  const SoapSerializable({
    this.anyMap,
    this.checked,
    this.createFactory,
    this.createToSoap,
    this.disallowUnrecognizedKeys,
    this.explicitToSoap,
    this.fieldRename,
    this.ignoreUnannotated,
    this.includeIfNull,
    this.nullable,
  });

  factory SoapSerializable.fromSoap(Map<String, dynamic> soap) => _$SoapSerializableFromSoap(soap);

  /// An instance of [SoapSerializable] with all fields set to their default
  /// values.
  static const defaults = SoapSerializable(
    anyMap: false,
    checked: false,
    createFactory: true,
    createToSoap: true,
    disallowUnrecognizedKeys: false,
    explicitToSoap: false,
    fieldRename: FieldRename.none,
    ignoreUnannotated: false,
    includeIfNull: true,
    nullable: true,
  );

  /// Returns a new [SoapSerializable] instance with fields equal to the
  /// corresponding values in `this`, if not `null`.
  ///
  /// Otherwise, the returned value has the default value as defined in
  /// [defaults].
  SoapSerializable withDefaults() => SoapSerializable(
        anyMap: anyMap ?? defaults.anyMap,
        checked: checked ?? defaults.checked,
        createFactory: createFactory ?? defaults.createFactory,
        createToSoap: createToSoap ?? defaults.createToSoap,
        disallowUnrecognizedKeys: disallowUnrecognizedKeys ?? defaults.disallowUnrecognizedKeys,
        explicitToSoap: explicitToSoap ?? defaults.explicitToSoap,
        fieldRename: fieldRename ?? defaults.fieldRename,
        ignoreUnannotated: ignoreUnannotated ?? defaults.ignoreUnannotated,
        includeIfNull: includeIfNull ?? defaults.includeIfNull,
        nullable: nullable ?? defaults.nullable,
      );

  Map<String, dynamic> toSoap() => _$SoapSerializableToSoap(this);
}
