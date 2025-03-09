import 'package:guidera_app/models/university.dart';

List<University> mockUniversities = [
  University(
    id: 'ucp-001',
    name: 'University of Central Punjab',
    degree: 'BSSE',
    location: 'Lahore',
    tuitionFee: 180000,
    programDuration: const Duration(days: 1460), // 4 years
    rating: 4.2,
    logoUrl: 'https://ucp.edu.pk/inc/uploads/2019/06/ucp-sticky-logo-white-1.png',
    isPublic: false,
    programStart: DateTime(2025, 6, 1),
    website: 'https://www.ucp.edu.pk',
    isBookmarked: false,
  ),
  University(
    id: 'fast-002',
    name: 'FAST NUCES',
    degree: 'BSSE',
    location: 'Islamabad',
    tuitionFee: 140000,
    programDuration: const Duration(days: 1460),
    rating: 4.8,
    logoUrl: 'https://ucp.edu.pk/inc/uploads/2019/06/ucp-sticky-logo-white-1.png',
    isPublic: true,
    programStart: DateTime(2025, 6, 1),
    website: 'https://www.nu.edu.pk',
    isBookmarked: false,
  ),
  University(
    id: 'comsats-003',
    name: 'COMSATS University',
    degree: 'BSSE',
    location: 'Islamabad',
    tuitionFee: 110000,
    programDuration: const Duration(days: 1460),
    rating: 4.5,
    logoUrl: 'https://ucp.edu.pk/inc/uploads/2019/06/ucp-sticky-logo-white-1.png',
    isPublic: true,
    programStart: DateTime(2025, 6, 1),
    website: 'https://www.comsats.edu.pk',
    isBookmarked: false,
  ),
  // Add 5-7 more universities with different parameters
];