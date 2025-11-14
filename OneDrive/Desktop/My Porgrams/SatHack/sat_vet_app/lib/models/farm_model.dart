import 'package:flutter/material.dart';

class Farm {
  final String id;
  final String name;
  final String owner;
  final int compliance;
  final bool isPending;

  const Farm({
    required this.id,
    required this.name,
    required this.owner,
    required this.compliance,
    this.isPending = false,
  });
}
