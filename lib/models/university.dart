import 'package:flutter/material.dart';

class University {
  final String id;
  final String name;
  final String degree;
  final String beginning;
  final int feePerSem;
  final int duration;
  final String location;
  final double rating;

  University({
    required this.id,
    required this.name,
    required this.degree,
    required this.beginning,
    required this.feePerSem,
    required this.duration,
    required this.location,
    required this.rating,
  });
}

class FilterOptions {
  String? location;
  List<String> degreeTypes = [];
  double minFee = 0;
  double maxFee = 300000;
  int minDuration = 1;
  double minRating = 0;
  bool hasScholarship = false;
}
