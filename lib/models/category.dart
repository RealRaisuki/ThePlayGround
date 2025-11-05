import 'package:flutter/material.dart';

class Category {
  String id;
  String name;
  Color color;

  Category({required this.id, required this.name, required this.color});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      color: Color(json['color']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color.toARGB32(),
    };
  }

  Category copyWith({String? id, String? name, Color? color}) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
    );
  }
}
