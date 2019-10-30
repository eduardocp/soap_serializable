// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'example.dart';

// **************************************************************************
// SoapSerializableGenerator
// **************************************************************************

Person _$PersonFromSoap(Map<String, dynamic> soap) {
  return Person(
    firstName: soap['firstName'] as String,
    lastName: soap['lastName'] as String,
    dateOfBirth: DateTime.parse(soap['dateOfBirth'] as String),
  );
}

Map<String, dynamic> _$PersonToSoap(Person instance) => <String, dynamic>{
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'dateOfBirth': instance.dateOfBirth.toIso8601String(),
    };
