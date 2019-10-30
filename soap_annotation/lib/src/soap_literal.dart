// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// An annotation used to generate a private field containing the contents of a
/// SOAP file.
///
/// The annotation can be applied to any member, but usually it's applied to
/// top-level getter.
///
/// In this example, the SOAP content of `data.soap` is populated into a
/// top-level, final field `_$glossaryDataSoapLiteral` in the generated file.
///
/// ```dart
/// @SoapLiteral('data.soap')
/// Map get glossaryData => _$glossaryDataSoapLiteral;
/// ```
class SoapLiteral {
  /// The relative path from the Dart file with the annotation to the file
  /// containing the source SOAP.
  final String path;

  /// `true` if the SOAP literal should be written as a constant.
  final bool asConst;

  /// Creates a new [SoapLiteral] instance.
  const SoapLiteral(this.path, {bool asConst = false}) : asConst = asConst ?? false;
}
