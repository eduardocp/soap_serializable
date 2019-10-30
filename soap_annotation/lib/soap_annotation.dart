// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Provides annotation classes to use with
/// [soap_serializable](https://pub.dev/packages/soap_serializable).
///
/// Also contains helper functions and classes – prefixed with `$` used by
/// `soap_serializable` when the `use_wrappers` or `checked` options are
/// enabled.
library soap_annotation;

export 'src/allowed_keys_helpers.dart';
export 'src/checked_helpers.dart';
export 'src/soap_converter.dart';
export 'src/soap_key.dart';
export 'src/soap_literal.dart';
export 'src/soap_serializable.dart';
export 'src/soap_value.dart';
