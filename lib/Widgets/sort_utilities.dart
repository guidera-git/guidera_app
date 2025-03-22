import '../screens/saved_programs_screen.dart';
import '../Widgets/sort_providers.dart';

List<SavedProgram> sortPrograms(List<SavedProgram> programs, SortBy sortBy) {
  switch (sortBy) {
    case SortBy.feeAsc:
      return _sortByFee(programs, ascending: true);
    case SortBy.feeDesc:
      return _sortByFee(programs, ascending: false);
    case SortBy.dateAsc:
      return _sortByDate(programs, ascending: true);
    case SortBy.dateDesc:
      return _sortByDate(programs, ascending: false);
    case SortBy.universityAsc:
      return _sortByUniversity(programs, ascending: true);
    case SortBy.universityDesc:
      return _sortByUniversity(programs, ascending: false);
    case SortBy.statusAsc:
      return _sortByStatus(programs, ascending: true);
    case SortBy.statusDesc:
      return _sortByStatus(programs, ascending: false);
  }
}

List<SavedProgram> _sortByFee(List<SavedProgram> programs, {required bool ascending}) {
  programs.sort((a, b) => ascending ? a.fee.compareTo(b.fee) : b.fee.compareTo(a.fee));
  return programs.toList();
}

List<SavedProgram> _sortByDate(List<SavedProgram> programs, {required bool ascending}) {
  final dateOrder = {
    'Spring': 1,
    'Summer': 2,
    'Fall': 3,
    'Winter': 4,
  };

  programs.sort((a, b) {
    final aSplit = a.startDate.split(' ');
    final bSplit = b.startDate.split(' ');
    final aYear = int.parse(aSplit[1]);
    final bYear = int.parse(bSplit[1]);
    final aSeason = dateOrder[aSplit[0]] ?? 0;
    final bSeason = dateOrder[bSplit[0]] ?? 0;

    if (aYear != bYear) {
      return ascending ? aYear.compareTo(bYear) : bYear.compareTo(aYear);
    }
    return ascending ? aSeason.compareTo(bSeason) : bSeason.compareTo(aSeason);
  });

  return programs.toList();
}

List<SavedProgram> _sortByUniversity(List<SavedProgram> programs, {required bool ascending}) {
  programs.sort((a, b) => ascending
      ? a.university.compareTo(b.university)
      : b.university.compareTo(a.university));
  return programs.toList();
}

List<SavedProgram> _sortByStatus(List<SavedProgram> programs, {required bool ascending}) {
  final statusOrder = {
    'Admission is open': 1,
    'Opening in': 2,
    'Closing in': 3,
  };

  programs.sort((a, b) {
    final aStatusKey = statusOrder.keys.firstWhere(
          (key) => a.status.contains(key),
      orElse: () => 'Other',
    );
    final bStatusKey = statusOrder.keys.firstWhere(
          (key) => b.status.contains(key),
      orElse: () => 'Other',
    );

    return ascending
        ? statusOrder[aStatusKey]!.compareTo(statusOrder[bStatusKey]!)
        : statusOrder[bStatusKey]!.compareTo(statusOrder[aStatusKey]!);
  });

  return programs.toList();
}
