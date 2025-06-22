import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:guidera_app/services/api_service.dart';
import 'package:guidera_app/widgets/header.dart';
import 'package:guidera_app/widgets/fancy_bottom_nav_bar.dart';
import 'package:guidera_app/widgets/fancy_nav_item.dart';
import 'package:guidera_app/theme/app_colors.dart';
import 'package:guidera_app/screens/about_screen.dart';
import 'package:guidera_app/screens/chatbot_screen.dart';
import 'package:guidera_app/screens/entrytest-screen.dart';
import 'package:guidera_app/screens/help_support_screen.dart';
import 'package:guidera_app/screens/notification_screen.dart';
import 'package:guidera_app/screens/privacy_policy.dart';
import 'package:guidera_app/screens/profile_dashboard_screen.dart';
import 'package:guidera_app/screens/rate_share_social_screen.dart';
import 'package:guidera_app/screens/saved_programs_screen.dart';
import 'package:guidera_app/screens/settings_screen.dart';
import 'package:guidera_app/screens/university_search_screen.dart';
import 'package:guidera_app/screens/analytics_screen.dart';
import 'package:guidera_app/widgets/drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  int _selectedDrawerIndex = 0;
  final _api = ApiService();
  Map<String, dynamic>? profile;
  bool _loadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final resp = await _api.getProfile();
      if (resp.statusCode == 200) {
        final profileData = jsonDecode(resp.body);
        print('Profile data loaded: $profileData'); // Debug log
        setState(() {
          profile = profileData;
          _loadingProfile = false;
        });
      } else {
        print('Failed to load profile: ${resp.statusCode}');
        setState(() => _loadingProfile = false);
      }
    } catch (e) {
      print('Error loading profile: $e');
      setState(() => _loadingProfile = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final _screens = [
      HomeTab(profile: profile, loading: _loadingProfile),
      const UniversitySearchScreen(),
      const SavedProgramsScreen(),
      const NotificationScreen(),
    ];
    final items = [
      FancyNavItem(label: "Home", svgPath: "assets/images/home.svg"),
      FancyNavItem(label: "Search", svgPath: "assets/images/search.svg"),
      FancyNavItem(label: "Saved", svgPath: "assets/images/save.svg"),
      FancyNavItem(label: "Notifications", svgPath: "assets/images/notification.svg"),
    ];

    return WillPopScope(
      onWillPop: () async {
        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor(context),
        drawer: const GuideraDrawer(selectedIndex: 0),
        appBar: _currentIndex == 0
            ? PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Builder(builder: (ctx) {
            return Stack(
              children: [
                const GuideraHeader(),
                Positioned(
                  top: 75,
                  left: 10,
                  child: IconButton(
                    icon: Icon(
                      Icons.menu,
                      color: AppColors.textPrimary(context),
                    ),
                    onPressed: () => Scaffold.of(ctx).openDrawer(),
                  ),
                ),
              ],
            );
          }),
        )
            : null,
        body: _screens[_currentIndex],
        bottomNavigationBar: GuideraBottomNavBar(
          items: items,
          initialIndex: _currentIndex,
          onItemSelected: (idx) => setState(() => _currentIndex = idx),
        ),
      ),
    );
  }
}

class HomeTab extends StatefulWidget {
  final Map<String, dynamic>? profile;
  final bool loading;

  const HomeTab({
    Key? key,
    required this.profile,
    required this.loading,
  }) : super(key: key);

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final ApiService _api = ApiService();
  List<Map<String, dynamic>> _recentApplications = [];
  List<Map<String, dynamic>> _upcomingDeadlines = [];
  Map<String, dynamic>? _analyticsData;
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final applications = await _api.getApplications();
      final deadlines = await _api.getDeadlines();
      final analytics = await _api.getApplicationsAnalytics();

      if (applications.statusCode == 200) {
        final appList = jsonDecode(applications.body) as List;
        _recentApplications = List<Map<String, dynamic>>.from(appList.take(3));
      }

      if (deadlines.statusCode == 200) {
        final deadlineList = jsonDecode(deadlines.body) as List;
        _upcomingDeadlines = List<Map<String, dynamic>>.from(deadlineList.take(3));
      }

      if (analytics.statusCode == 200) {
        _analyticsData = jsonDecode(analytics.body);
      }

      setState(() => _isLoadingData = false);
    } catch (e) {
      print('Error loading dashboard data: $e');
      setState(() => _isLoadingData = false);
    }
  }

  // Enhanced profile completion calculation with better validation
  double _calculateProfileCompletion() {
    if (widget.profile == null) {
      print('Profile is null');
      return 0.0;
    }

    print('Calculating profile completion for: ${widget.profile}');

    int completedFields = 0;
    int totalFields = 5; // profilephoto, backgroundphoto, gender, birthdate, aboutme

    // Helper function to check if a field is valid
    bool isFieldValid(dynamic field) {
      if (field == null) return false;
      final fieldStr = field.toString().trim();
      return fieldStr.isNotEmpty &&
          fieldStr.toLowerCase() != 'null' &&
          fieldStr != 'undefined';
    }

    // Check profile photo
    if (isFieldValid(widget.profile!['profilephoto'])) {
      completedFields++;
      print('Profile photo: ✓');
    } else {
      print('Profile photo: ✗ (${widget.profile!['profilephoto']})');
    }

    // Check background photo
    if (isFieldValid(widget.profile!['backgroundphoto'])) {
      completedFields++;
      print('Background photo: ✓');
    } else {
      print('Background photo: ✗ (${widget.profile!['backgroundphoto']})');
    }

    // Check gender
    if (isFieldValid(widget.profile!['gender'])) {
      completedFields++;
      print('Gender: ✓');
    } else {
      print('Gender: ✗ (${widget.profile!['gender']})');
    }

    // FIX: Check birthdate (not dateofbirth)
    if (isFieldValid(widget.profile!['birthdate'])) {
      completedFields++;
      print('Date of birth: ✓');
    } else {
      print('Date of birth: ✗ (${widget.profile!['birthdate']})');
    }

    // FIX: Check aboutme (not aboutMe or about_me)
    if (isFieldValid(widget.profile!['aboutme'])) {
      completedFields++;
      print('About me: ✓');
    } else {
      print('About me: ✗ (aboutme: ${widget.profile!['aboutme']})');
    }

    final completion = completedFields / totalFields;
    print('Profile completion: $completedFields/$totalFields = ${(completion * 100).round()}%');

    return completion;
  }


  Widget _buildDashboardCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: isDarkMode ? 4 : 10, // Sharper shadows in light mode
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppColors.surfaceColor(context),
      shadowColor: isDarkMode
          ? AppColors.shadowColor(context).withOpacity(0.2)
          : AppColors.shadowColor(context).withOpacity(0.4), // Sharper shadows
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          // Additional shadow for light mode
          boxShadow: isDarkMode ? null : [
            BoxShadow(
              color: AppColors.shadowColor(context).withOpacity(0.12),
              blurRadius: 12,
              spreadRadius: 2,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isDarkMode ? null : [
                      BoxShadow(
                        color: color.withOpacity(0.1),
                        blurRadius: 4,
                        spreadRadius: 1,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
                if (trailing != null) trailing,
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.textSecondary(context),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildQuickStatsCard() {
    if (_isLoadingData) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: AppColors.surfaceColor(context),
        shadowColor: AppColors.shadowColor(context),
        child: const Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final totalApps = _recentApplications.length;
    final urgentDeadlines = _upcomingDeadlines.where((d) => d['is_urgent'] == true).length;
    final profileCompletion = (_calculateProfileCompletion() * 100).round();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppColors.surfaceColor(context),
      shadowColor: AppColors.shadowColor(context),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Applications',
                    totalApps.toString(),
                    AppColors.lightBlue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Urgent Deadlines',
                    urgentDeadlines.toString(),
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Profile',
                    '$profileCompletion%',
                    Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary(context),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Enhanced grid card with improved light mode styling
  // Enhanced grid card with improved styling for both modes
  Widget _buildGridCard(
      BuildContext context,
      String title,
      String iconPath,
      int index,
      ) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Enhanced styling for both modes
    Color cardColor;
    Color titleBackgroundColor;
    Color titleTextColor;
    Color circleColor;
    Color circleIconColor;

    if (isDarkMode) {
      // Dark mode colors - enhanced for better contrast
      cardColor = AppColors.surfaceColor(context);
      titleBackgroundColor = AppColors.myWhite;
      titleTextColor = AppColors.darkBlue;
      circleColor = AppColors.myWhite;
      circleIconColor = AppColors.darkBlue;
    } else {
      // Light mode - enhanced styling for better contrast
      cardColor = AppColors.myWhite;
      titleBackgroundColor = AppColors.lightBlue.withOpacity(0.1);
      titleTextColor = AppColors.darkBlue;
      circleColor = AppColors.lightBlue.withOpacity(0.15);
      circleIconColor = AppColors.darkBlue;
    }

    return Card(
      elevation: isDarkMode ? 4 : 12, // Sharper shadows in light mode
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: cardColor,
      shadowColor: isDarkMode
          ? AppColors.shadowColor(context).withOpacity(0.2)
          : AppColors.shadowColor(context).withOpacity(0.4), // Sharper shadows in light mode
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          switch (index) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UniversitySearchScreen(),
                ),
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AnalyticsScreen(),
                ),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EntryTestScreen(),
                ),
              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChatbotScreen(),
                ),
              );
              break;
          }
        },
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            // Add subtle gradient for light mode
            gradient: isDarkMode ? null : LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                cardColor,
                cardColor.withOpacity(0.95),
              ],
            ),
            // Enhanced box shadow for light mode
            boxShadow: isDarkMode ? null : [
              BoxShadow(
                color: AppColors.shadowColor(context).withOpacity(0.15),
                blurRadius: 8,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: AppColors.shadowColor(context).withOpacity(0.1),
                blurRadius: 16,
                spreadRadius: 1,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: titleBackgroundColor,
                    borderRadius: BorderRadius.circular(16),
                    border: isDarkMode ? null : Border.all(
                      color: AppColors.lightBlue.withOpacity(0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowColor(context).withOpacity(0.15),
                        blurRadius: isDarkMode ? 2 : 6,
                        spreadRadius: isDarkMode ? 0 : 1,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: titleTextColor,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: circleColor,
                    shape: BoxShape.circle,
                    border: isDarkMode ? null : Border.all(
                      color: AppColors.lightBlue.withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowColor(context).withOpacity(0.2),
                        blurRadius: isDarkMode ? 3 : 8,
                        spreadRadius: isDarkMode ? 0 : 1,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Transform.rotate(
                    angle: 145 * math.pi / 180,
                    child: SvgPicture.asset(
                      "assets/images/back.svg",
                      width: 16,
                      height: 16,
                      color: circleIconColor,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: isDarkMode ? null : [
                      BoxShadow(
                        color: AppColors.shadowColor(context).withOpacity(0.1),
                        blurRadius: 6,
                        spreadRadius: 1,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: SvgPicture.asset(
                    iconPath,
                    height: 64,
                    width: 64,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  String _getLastLogin() {
    // Mock last login time - you should get this from your API
    final lastLogin = DateTime.now().subtract(const Duration(hours: 2, minutes: 30));
    final now = DateTime.now();
    final difference = now.difference(lastLogin);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final String displayName = widget.loading
        ? 'Loading…'
        : widget.profile?['fullname']?.split(' ').first.trim() ?? 'Guest';

    Widget avatar;
    if (widget.loading) {
      avatar = CircleAvatar(
        radius: 25,
        backgroundColor: AppColors.surfaceColor(context),
        child: CircularProgressIndicator(color: AppColors.primary(context)),
      );
    } else {
      final String? url = widget.profile?['profilephoto'] as String?;
      if (url != null && url.isNotEmpty && url != 'null') {
        avatar = CircleAvatar(radius: 25, backgroundImage: NetworkImage(url));
      } else {
        avatar = CircleAvatar(
          radius: 25,
          backgroundColor: Colors.transparent,
          child: SvgPicture.asset(
            'assets/images/default_avatar.svg',
            width: 48,
            height: 48,
            color: AppColors.textPrimary(context),
          ),
        );
      }
    }

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section with Last Login
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back,',
                        style: TextStyle(
                          color: AppColors.textSecondary(context),
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        displayName,
                        style: TextStyle(
                          color: AppColors.textPrimary(context),
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Last login: ${_getLastLogin()}',
                        style: TextStyle(
                          color: AppColors.textSecondary(context),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const UserProfileScreen()),
                      );
                    },
                    borderRadius: BorderRadius.circular(25),
                    child: avatar,
                  ),
                ],
              ),
            ),

            // Quick Stats
            _buildQuickStatsCard(),

            // Dashboard Cards
            _buildDashboardCard(
              title: 'Recent Applications',
              subtitle: _isLoadingData
                  ? 'Loading...'
                  : _recentApplications.isEmpty
                  ? 'No applications yet'
                  : '${_recentApplications.length} active applications',
              icon: Icons.assignment,
              color: AppColors.lightBlue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
                );
              },
            ),

            _buildDashboardCard(
              title: 'Upcoming Deadlines',
              subtitle: _isLoadingData
                  ? 'Loading...'
                  : _upcomingDeadlines.isEmpty
                  ? 'No upcoming deadlines'
                  : '${_upcomingDeadlines.length} deadlines approaching',
              icon: Icons.schedule,
              color: Colors.orange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationScreen()),
                );
              },
              trailing: _upcomingDeadlines.where((d) => d['is_urgent'] == true).isNotEmpty
                  ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'URGENT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
                  : null,
            ),

            _buildDashboardCard(
              title: 'Profile Completion',
              subtitle: '${(_calculateProfileCompletion() * 100).round()}% completed',
              icon: Icons.person,
              color: Colors.green,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UserProfileScreen()),
                );
              },
              trailing: CircularProgressIndicator(
                value: _calculateProfileCompletion(),
                backgroundColor: AppColors.borderColor(context),
                valueColor: const AlwaysStoppedAnimation(Colors.green),
                strokeWidth: 3,
              ),
            ),

            // Quick Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 1.2,
                children: [
                  _buildGridCard(context, "Find University", "assets/images/find.svg", 0),
                  _buildGridCard(context, "Analytics", "assets/images/visual.svg", 1),
                  _buildGridCard(context, "Prepare Test", "assets/images/test.svg", 2),
                  _buildGridCard(context, "Chatbot", "assets/images/chat.svg", 3),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}