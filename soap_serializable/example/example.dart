// Copyright (c) 2017, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:soap_annotation/soap_annotation.dart';

part 'example.g.dart';
	
@SoapSerializable(nullable: false)
class Person {
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  Person({this.firstName, this.lastName, this.dateOfBirth});
  factory Person.fromSoap(Map<String, dynamic> soap) => _$PersonFromSoap(soap);
  Map<String, dynamic> toSoap() => _$PersonToSoap(this);
}
