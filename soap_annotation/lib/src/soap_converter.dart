// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Implement this class to provide custom converters for a specific [Type].
///
/// [T] is the data type you'd like to convert to and from.
///
/// [S] is the type of the value stored in SOAP. It must be a valid SOAP type
/// such as [String], [int], or [Map<String, dynamic>].
abstract class SoapConverter<T, S> {
  T fromSoap(S soap);
  S toSoap(T object);
}
