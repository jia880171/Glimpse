import 'dart:convert';

import 'package:flutter/material.dart';

class Glimpse {
  final int? id;
  final DateTime date;
  final List<String> imgPaths;
  final String content;
  final int GType;

  Glimpse({
    this.id,
    required this.date,
    required this.imgPaths,
    required this.content,
    required this.GType,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'imgPath': jsonEncode(imgPaths), // Converts list to JSON String
      'content': content,
      'GType': GType,
    };
  }

  factory Glimpse.fromMap(Map<String, dynamic> map) {
    return Glimpse(
      id: map['id'],
      date: DateTime.parse(map['date']),
      // imgPaths: List<String>.from(jsonDecode(map['imgPaths'])),
      imgPaths: map['imgPaths'] != null ? List<String>.from(jsonDecode(map['imgPaths'])) : [],
      content: map['content'],
      GType: map['GType'],
    );
  }
}
