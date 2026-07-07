import 'package:flutter/foundation.dart';

@immutable
class UserModel {
  const UserModel({
    this.id,
    required this.name,
    required this.phone,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  final int? id;
  final String name;
  final String phone;
  final bool? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: (map['id'] as num?)?.toInt(),
      name: (map['name'] ?? '') as String,
      phone: (map['phone'] ?? '') as String,
      status: map['status'] as bool?,
      createdAt: DateTime.tryParse((map['created_at'] ?? '') as String),
      updatedAt: DateTime.tryParse((map['updated_at'] ?? '') as String),
    );
  }
}
