import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/category.dart';

class CategoryModel extends Category {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.createdAt,
    super.colorValue,
  });

  factory CategoryModel.fromEntity(Category c) => CategoryModel(
        id: c.id,
        name: c.name,
        colorValue: c.colorValue,
        createdAt: c.createdAt,
      );

  factory CategoryModel.fromRow(CategoryRow r) => CategoryModel(
        id: r.id,
        name: r.name,
        colorValue: r.colorValue,
        createdAt: r.createdAt,
      );

  factory CategoryModel.fromJson(Map<String, dynamic> j) => CategoryModel(
        id: j['id'] as String,
        name: j['name'] as String,
        colorValue: j['colorValue'] as int?,
        createdAt: DateTime.parse(j['createdAt'] as String),
      );

  CategoriesCompanion toCompanion() => CategoriesCompanion(
        id: Value(id),
        name: Value(name),
        colorValue: Value(colorValue),
        createdAt: Value(createdAt),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'colorValue': colorValue,
        'createdAt': createdAt.toIso8601String(),
      };
}
