class University {
  final String id;
  final String name;
  final String degree;
  final String location;
  final double tuitionFee;
  final Duration programDuration;
  final double rating;
  final bool isPublic;
  final DateTime programStart;
  final String website;
  bool isBookmarked;
  final String logoUrl;

  University({
    required this.id,
    required this.name,
    required this.degree,
    required this.location,
    required this.tuitionFee,
    required this.programDuration,
    required this.rating,
    required this.isPublic,
    required this.programStart,
    required this.website,
    this.isBookmarked = false,
    required this.logoUrl,

  });

  // Helper method to get duration in years
  String get durationInYears {
    final years = programDuration.inDays ~/ 365;
    return '$years Year${years > 1 ? 's' : ''}';
  }

  // CopyWith method for state management
  University copyWith({
    bool? isBookmarked,
  }) {
    return University(
      id: id,
      name: name,
      degree: degree,
      location: location,
      tuitionFee: tuitionFee,
      programDuration: programDuration,
      rating: rating,
      isPublic: isPublic,
      programStart: programStart,
      website: website,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      logoUrl: logoUrl
    );
  }
}