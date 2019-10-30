// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'soap_serializable.dart';

// **************************************************************************
// SoapSerializableGenerator
// **************************************************************************

SoapSerializable _$SoapSerializableFromSoap(Map<String, dynamic> soap) {
  return $checkedNew('SoapSerializable', soap, () {
    $checkKeys(soap, allowedKeys: const [
      'any_map',
      'checked',
      'create_factory',
      'create_to_soap',
      'disallow_unrecognized_keys',
      'explicit_to_soap',
      'field_rename',
      'ignore_unannotated',
      'include_if_null',
      'nullable',
    ]);
    final val = SoapSerializable(
      anyMap: $checkedConvert(soap, 'any_map', (v) => v as bool),
      checked: $checkedConvert(soap, 'checked', (v) => v as bool),
      createFactory: $checkedConvert(soap, 'create_factory', (v) => v as bool),
      createToSoap: $checkedConvert(soap, 'create_to_soap', (v) => v as bool),
      disallowUnrecognizedKeys: $checkedConvert(soap, 'disallow_unrecognized_keys', (v) => v as bool),
      explicitToSoap: $checkedConvert(soap, 'explicit_to_soap', (v) => v as bool),
      fieldRename: $checkedConvert(soap, 'field_rename', (v) => _$enumDecodeNullable(_$FieldRenameEnumMap, v)),
      ignoreUnannotated: $checkedConvert(soap, 'ignore_unannotated', (v) => v as bool),
      includeIfNull: $checkedConvert(soap, 'include_if_null', (v) => v as bool),
      nullable: $checkedConvert(soap, 'nullable', (v) => v as bool),
    );
    return val;
  }, fieldKeyMap: const {
    'anyMap': 'any_map',
    'createFactory': 'create_factory',
    'createToSoap': 'create_to_soap',
    'disallowUnrecognizedKeys': 'disallow_unrecognized_keys',
    'explicitToSoap': 'explicit_to_soap',
    'fieldRename': 'field_rename',
    'ignoreUnannotated': 'ignore_unannotated',
    'includeIfNull': 'include_if_null',
  });
}

Map<String, dynamic> _$SoapSerializableToSoap(SoapSerializable instance) => <String, dynamic>{
      'any_map': instance.anyMap,
      'checked': instance.checked,
      'create_factory': instance.createFactory,
      'create_to_soap': instance.createToSoap,
      'disallow_unrecognized_keys': instance.disallowUnrecognizedKeys,
      'explicit_to_soap': instance.explicitToSoap,
      'field_rename': _$FieldRenameEnumMap[instance.fieldRename],
      'ignore_unannotated': instance.ignoreUnannotated,
      'include_if_null': instance.includeIfNull,
      'nullable': instance.nullable,
    };

T _$enumDecode<T>(Map<T, dynamic> enumValues, dynamic source) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }
  return enumValues.entries
      .singleWhere((e) => e.value == source,
          orElse: () => throw ArgumentError('`$source` is not one of the supported values: '
              '${enumValues.values.join(', ')}'))
      .key;
}

T _$enumDecodeNullable<T>(Map<T, dynamic> enumValues, dynamic source) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source);
}

const _$FieldRenameEnumMap = <FieldRename, dynamic>{FieldRename.none: 'none', FieldRename.kebab: 'kebab', FieldRename.snake: 'snake', FieldRename.pascal: 'pascal'};
