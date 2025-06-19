import 'dart:convert';

class Program {
  final String id;
  final String? programKey;
  final String programTitle;
  final String? standardizedTitle;
  final String programDescription;
  final String programDuration;
  final String creditHours;
  final List<Fee> fee;
  final String? calculatedTotalFee;
  final List<ImportantDate>? importantDates;
  final dynamic merit;
  final dynamic teachingSystem;
  final List<AdmissionCriteria>? admissionCriteria;
  final List<dynamic>? meritFormula;
  final String? courseOutline;
  final String universityId;
  final String universityTitle;
  final String? mainLink;
  final String location;
  final List<String>? additionalLocations;
  final String? qsRanking;
  final SocialLinks? socialLinks;
  final ContactDetails? contactDetails;
  final String? introduction;
  final dynamic campuses;

  Program({
    required this.id,
    this.programKey,
    required this.programTitle,
    this.standardizedTitle,
    required this.programDescription,
    required this.programDuration,
    required this.creditHours,
    required this.fee,
    this.calculatedTotalFee,
    this.importantDates,
    this.merit,
    this.teachingSystem,
    this.admissionCriteria,
    this.meritFormula,
    this.courseOutline,
    required this.universityId,
    required this.universityTitle,
    this.mainLink,
    required this.location,
    this.additionalLocations,
    this.qsRanking,
    this.socialLinks,
    this.contactDetails,
    this.introduction,
    this.campuses,
  });

  // Helper methods for UI display
  int get totalFee {
    if (calculatedTotalFee != null && calculatedTotalFee!.isNotEmpty) {
      return _parseFeeAmount(calculatedTotalFee!);
    }
    if (fee.isEmpty) return 0;
    return _parseFeeAmount(fee.first.totalTutionFee);
  }

  int get creditFee {
    if (fee.isEmpty) return 0;
    return _parseFeeAmount(fee.first.perCreditHourFee);
  }

  String get durationInSemesters {
    if (programDuration.toLowerCase().contains('year')) {
      final yearMatch = RegExp(r'(\d+)\s*year').firstMatch(programDuration.toLowerCase());
      if (yearMatch != null) {
        final years = int.tryParse(yearMatch.group(1) ?? '0') ?? 0;
        return '${years * 2} Semesters';
      }
    }
    return programDuration;
  }

  bool get hasScholarship {
    return programDescription.toLowerCase().contains('scholarship') ||
        programDescription.toLowerCase().contains('financial aid');
  }

  String get formattedTotalFee {
    // Use calculated total fee if available
    if (calculatedTotalFee != null && calculatedTotalFee!.isNotEmpty && calculatedTotalFee != 'Not Available') {
      return calculatedTotalFee!;
    }

    // Fallback to calculating from fee array
    if (totalFee == 0) return 'N/A';
    return '${totalFee.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} PKR';
  }

  // Get display title - prefer standardized title if available
  String get displayTitle {
    return standardizedTitle?.isNotEmpty == true ? standardizedTitle! : programTitle;
  }

  static int _parseFeeAmount(String feeString) {
    if (feeString.isEmpty || feeString == 'Not Available') return 0;
    // Remove PKR, commas, and any non-numeric characters except decimals
    final cleanFee = feeString.replaceAll(RegExp(r'[^\d]'), '');
    return int.tryParse(cleanFee) ?? 0;
  }

  // Updated factory method to handle new database structure
  factory Program.fromMap(Map<String, dynamic> map) {
    return Program(
      id: map['program_id']?.toString() ?? map['id']?.toString() ?? '',
      programKey: map['program_key']?.toString(),
      programTitle: map['program_title']?.toString() ?? '',
      standardizedTitle: map['standardized_title']?.toString(),
      programDescription: map['program_description']?.toString() ?? '',
      programDuration: map['program_duration']?.toString() ?? '',
      creditHours: map['credit_hours']?.toString() ?? '',
      fee: _parseFeeList(map['fee']),
      calculatedTotalFee: map['calculated_total_fee']?.toString(),
      importantDates: _parseImportantDates(map['important_dates']),
      merit: map['merit'],
      teachingSystem: map['teaching_system'],
      admissionCriteria: _parseAdmissionCriteria(map['admission_criteria']),
      meritFormula: map['merit_formula'] as List<dynamic>?,
      courseOutline: map['course_outline']?.toString(),
      universityId: map['university_id']?.toString() ?? '',
      universityTitle: map['university_title']?.toString() ?? '',
      mainLink: map['main_link']?.toString(),
      location: map['location']?.toString() ?? '',
      additionalLocations: _parseStringList(map['additional_locations']),
      qsRanking: map['qs_ranking']?.toString(),
      socialLinks: map['social_links'] != null
          ? SocialLinks.fromMap(_parseJsonField(map['social_links']))
          : null,
      contactDetails: map['contact_details'] != null
          ? ContactDetails.fromMap(_parseJsonField(map['contact_details']))
          : null,
      introduction: map['introduction']?.toString(),
      campuses: map['campuses'],
    );
  }

  // Helper to parse JSONB fields that might be strings or maps
  static Map<String, dynamic> _parseJsonField(dynamic field) {
    if (field is Map<String, dynamic>) {
      return field;
    } else if (field is String) {
      try {
        return jsonDecode(field) as Map<String, dynamic>;
      } catch (e) {
        return {};
      }
    }
    return {};
  }

  // Helper to parse string arrays
  static List<String>? _parseStringList(dynamic listData) {
    if (listData == null) return null;
    if (listData is List) {
      return listData.map((e) => e.toString()).toList();
    }
    return null;
  }

  // Safe fee parsing
  static List<Fee> _parseFeeList(dynamic feeData) {
    if (feeData == null) return [];

    List<dynamic> feeList = [];
    if (feeData is String) {
      try {
        feeList = jsonDecode(feeData) as List<dynamic>;
      } catch (e) {
        return [];
      }
    } else if (feeData is List) {
      feeList = feeData;
    } else {
      return [];
    }

    return feeList
        .where((e) => e is Map<String, dynamic>)
        .map((e) => Fee.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  // Safe important dates parsing
  static List<ImportantDate>? _parseImportantDates(dynamic datesData) {
    if (datesData == null) return null;

    List<dynamic> datesList = [];
    if (datesData is String) {
      try {
        datesList = jsonDecode(datesData) as List<dynamic>;
      } catch (e) {
        return null;
      }
    } else if (datesData is List) {
      datesList = datesData;
    } else {
      return null;
    }

    return datesList
        .where((e) => e is Map<String, dynamic>)
        .map((e) => ImportantDate.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  // Safe admission criteria parsing
  static List<AdmissionCriteria>? _parseAdmissionCriteria(dynamic criteriaData) {
    if (criteriaData == null) return null;

    List<dynamic> criteriaList = [];
    if (criteriaData is String) {
      try {
        criteriaList = jsonDecode(criteriaData) as List<dynamic>;
      } catch (e) {
        return null;
      }
    } else if (criteriaData is List) {
      criteriaList = criteriaData;
    } else {
      return null;
    }

    return criteriaList
        .where((e) => e is Map<String, dynamic>)
        .map((e) => AdmissionCriteria.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Map<String, dynamic> toMap() {
    return {
      'program_id': id,
      'program_key': programKey,
      'program_title': programTitle,
      'standardized_title': standardizedTitle,
      'program_description': programDescription,
      'program_duration': programDuration,
      'credit_hours': creditHours,
      'fee': fee.map((e) => e.toMap()).toList(),
      'calculated_total_fee': calculatedTotalFee,
      'important_dates': importantDates?.map((e) => e.toMap()).toList(),
      'merit': merit,
      'teaching_system': teachingSystem,
      'admission_criteria': admissionCriteria?.map((e) => e.toMap()).toList(),
      'merit_formula': meritFormula,
      'course_outline': courseOutline,
      'university_id': universityId,
      'university_title': universityTitle,
      'main_link': mainLink,
      'location': location,
      'additional_locations': additionalLocations,
      'qs_ranking': qsRanking,
      'social_links': socialLinks?.toMap(),
      'contact_details': contactDetails?.toMap(),
      'introduction': introduction,
      'campuses': campuses,
    };
  }

  String toJson() => json.encode(toMap());
  factory Program.fromJson(String source) => Program.fromMap(json.decode(source));
}

class Fee {
  final String totalTutionFee;
  final String perCreditHourFee;

  Fee({
    required this.totalTutionFee,
    required this.perCreditHourFee,
  });

  factory Fee.fromMap(Map<String, dynamic> map) {
    return Fee(
      totalTutionFee: map['total_tution_fee']?.toString() ?? '',
      perCreditHourFee: map['per_credit_hour_fee']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'total_tution_fee': totalTutionFee,
      'per_credit_hour_fee': perCreditHourFee,
    };
  }
}

class ImportantDate {
  final String? deadlineApplicationSubmission;
  final String? deadlineAdmissionTestECAT;
  final String? commencementOfClasses;
  final String? deadlineSAT;
  final String? deadlineACT;

  ImportantDate({
    this.deadlineApplicationSubmission,
    this.deadlineAdmissionTestECAT,
    this.commencementOfClasses,
    this.deadlineSAT,
    this.deadlineACT,
  });

  factory ImportantDate.fromMap(Map<String, dynamic> map) {
    return ImportantDate(
      deadlineApplicationSubmission: map['deadline_application_submission']?.toString(),
      deadlineAdmissionTestECAT: map['deadline_admission_test_ECAT']?.toString(),
      commencementOfClasses: map['commencement_of_classes']?.toString(),
      deadlineSAT: map['daedline_SAT']?.toString(), // Note: API has typo "daedline"
      deadlineACT: map['daedline_ACT']?.toString(), // Note: API has typo "daedline"
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'deadline_application_submission': deadlineApplicationSubmission,
      'deadline_admission_test_ECAT': deadlineAdmissionTestECAT,
      'commencement_of_classes': commencementOfClasses,
      'daedline_SAT': deadlineSAT,
      'daedline_ACT': deadlineACT,
    };
  }
}

class AdmissionCriteria {
  final int sNo;
  final String criteria;

  AdmissionCriteria({
    required this.sNo,
    required this.criteria,
  });

  factory AdmissionCriteria.fromMap(Map<String, dynamic> map) {
    return AdmissionCriteria(
      sNo: map['s.no']?.toInt() ?? 0,
      criteria: map['criteria']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      's.no': sNo,
      'criteria': criteria,
    };
  }
}

class SocialLinks {
  final String? facebook;
  final String? twitter;
  final String? instagram;

  SocialLinks({
    this.facebook,
    this.twitter,
    this.instagram,
  });

  factory SocialLinks.fromMap(Map<String, dynamic> map) {
    return SocialLinks(
      facebook: map['facebook']?.toString(),
      twitter: map['twitter']?.toString(),
      instagram: map['instagram']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'facebook': facebook,
      'twitter': twitter,
      'instagram': instagram,
    };
  }
}

class ContactDetails {
  final String? call;
  final String? infoEmail;

  ContactDetails({
    this.call,
    this.infoEmail,
  });

  factory ContactDetails.fromMap(Map<String, dynamic> map) {
    return ContactDetails(
      call: map['call']?.toString(),
      infoEmail: map['info_email']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'call': call,
      'info_email': infoEmail,
    };
  }
}