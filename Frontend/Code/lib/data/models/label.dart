import 'package:flutter/material.dart';

class Label {
  final String id;
  final String projectId;
  final String name;
  final String colorHex;

  Label({
    required this.id,
    required this.projectId,
    required this.name,
    required this.colorHex,
  });

  Color get color {
    final hex = colorHex.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  factory Label.fromJson(Map<String, dynamic> json) {
    return Label(
      id: json['id'] as String? ?? '',
      projectId:
          json['projectId'] as String? ?? json['project_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      colorHex: json['color'] as String? ?? '#6B7280',
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'color': colorHex};
  }
}
