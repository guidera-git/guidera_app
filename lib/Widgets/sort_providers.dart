import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

enum SortBy {
  feeAsc,
  feeDesc,
  dateAsc,
  dateDesc,
  universityAsc,
  universityDesc,
  statusAsc,
  statusDesc,
}

final sortProvider = StateNotifierProvider<SortNotifier, SortBy>((ref) {
  return SortNotifier();
});

class SortNotifier extends StateNotifier<SortBy> {
  SortNotifier() : super(SortBy.universityAsc);

  void changeSorting(SortBy newSort) {
    state = newSort;
  }
}

extension SortByExtension on SortBy {
  String get label {
    switch (this) {
      case SortBy.feeAsc:
        return 'Fee: Low to High';
      case SortBy.feeDesc:
        return 'Fee: High to Low';
      case SortBy.dateAsc:
        return 'Date: Earliest First';
      case SortBy.dateDesc:
        return 'Date: Latest First';
      case SortBy.universityAsc:
        return 'University: A to Z';
      case SortBy.universityDesc:
        return 'University: Z to A';
      case SortBy.statusAsc:
        return 'Status: Open First';
      case SortBy.statusDesc:
        return 'Status: Closed First';
    }
  }

  IconData get icon {
    switch (this) {
      case SortBy.feeAsc:
      case SortBy.feeDesc:
        return Icons.attach_money;
      case SortBy.dateAsc:
      case SortBy.dateDesc:
        return Icons.calendar_today;
      case SortBy.universityAsc:
      case SortBy.universityDesc:
        return Icons.school;
      case SortBy.statusAsc:
      case SortBy.statusDesc:
        return Icons.timeline;
    }
  }
}
