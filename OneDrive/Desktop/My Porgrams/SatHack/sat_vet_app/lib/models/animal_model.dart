import 'package:flutter/material.dart';

class AnimalDetail {
  final String id;
  final String tag;
  final String species;
  final String age;
  final String status;
  final String withdrawalEnd;
  final List<Treatment> history;

  const AnimalDetail({
    required this.id,
    required this.tag,
    required this.species,
    required this.age,
    required this.status,
    required this.withdrawalEnd,
    required this.history,
  });
}

class Treatment {
  final String id;
  final String drugName;
  final String date;
  final String dosage;
  final String vetName;

  const Treatment({
    required this.id,
    required this.drugName,
    required this.date,
    required this.dosage,
    required this.vetName,
  });
}
