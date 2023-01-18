import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:recase/recase.dart';
import 'package:resourcer/widgets/resource_table_view.dart';

import 'repository.dart';

abstract class Resource<T> {
  int? get id;

  String? get name;

  bool get isEmpty;

  Map<String, dynamic> toMap();

  T fromMap(Map<String, dynamic> map);

  ResourceRow getResourceRow(TableController controller) {
    throw UnimplementedError();
  }

  ResourceColumn getResourceColumn() {
    throw UnimplementedError();
  }

  List<Field> getFields();

  Future<String> fileUploader(Uint8List data) {
    throw UnimplementedError();
  }

  Future<Uint8List> fileDownloader(String url) {
    throw UnimplementedError();
  }
}

class Field {
  final String name;
  final FieldType type;
  final String? label;
  final String? hint;
  final bool isRequired;
  final bool isSearchable;
  final Repository<Resource>? foreignRepository;

  Field(
    this.name,
    this.type, {
    this.label,
    this.hint,
    this.isRequired = false,
    this.foreignRepository,
    this.isSearchable = false,
  });

  int compareTo(Field other) {
    return type.priority.compareTo(other.type.priority);
  }

  @override
  String toString() {
    return 'Field($name)';
  }

  String get formattedName {
    return ReCase(name).titleCase;
  }
}

enum FieldType {
  image,
  date,
  name,
  text,
  email,
  dropdown,
  foreign,
  phoneNumber,
  number,
  password,
}

extension FieldTypeExtension on FieldType {
  int get priority {
    switch (this) {
      case FieldType.image:
        return 1;
      case FieldType.name:
        return 2;
      case FieldType.number:
        return 3;
      case FieldType.text:
        return 4;
      case FieldType.dropdown:
        return 5;
      case FieldType.foreign:
        return 6;
      case FieldType.date:
        return 7;
      case FieldType.phoneNumber:
        return 8;
      case FieldType.email:
        return 9;
      case FieldType.password:
        return 10;
    }
  }

  TextInputType get textInputType {
    switch (this) {
      case FieldType.email:
        return TextInputType.emailAddress;
      case FieldType.phoneNumber:
        return TextInputType.phone;
      case FieldType.password:
        return TextInputType.visiblePassword;
      case FieldType.name:
        return TextInputType.name;
      case FieldType.text:
        return TextInputType.text;
      case FieldType.image:
        return TextInputType.url;
      case FieldType.dropdown:
        return TextInputType.name;
      case FieldType.date:
        return TextInputType.datetime;
      case FieldType.number:
        return TextInputType.number;
      case FieldType.foreign:
        return TextInputType.number;
    }
  }
}

extension FieldsExtension on List<Field> {
  Map<FieldType, List<Field>> groupBy<FieldType>(
          FieldType Function(Field) keyFunction) =>
      fold(
          <FieldType, List<Field>>{},
          (Map<FieldType, List<Field>> map, Field element) => map
            ..putIfAbsent(keyFunction(element), () => <Field>[]).add(element));
}

class ResourceRow {
  final List<Cell> cells;

  ResourceRow({required this.cells});

  static ResourceRow get empty => ResourceRow(cells: []);
}

class ResourceColumn {
  final List<String> columns;

  ResourceColumn({required this.columns});

  static ResourceColumn get empty => ResourceColumn(columns: []);
}

class Cell {
  final String? data;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isAction;
  final List<Cell> children;

  Cell({
    this.data,
    this.icon,
    this.onPressed,
    this.isAction = false,
    this.children = const [],
  });
}
