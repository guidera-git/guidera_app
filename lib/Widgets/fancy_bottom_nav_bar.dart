import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_colors.dart';
import 'fancy_nav_item.dart';
import '../services/api_service.dart';

class GuideraBottomNavBar extends StatefulWidget {
  final List<FancyNavItem> items;
  final int initialIndex;
  final ValueChanged<int> onItemSelected;

  const GuideraBottomNavBar({
    Key? key,
    required this.items,
    this.initialIndex = 0,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  State<GuideraBottomNavBar> createState() => _GuideraBottomNavBarState();
}

class _GuideraBottomNavBarState extends State<GuideraBottomNavBar> {
  late int _selectedIndex;
  final ApiService _apiService = ApiService();
  bool _hasUnreadNotifications = false;
  int _unreadNotificationCount = 0;
  int _savedProgramsCount = 0;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _loadCounts();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _loadCounts();
    });
  }

  Future<void> _loadCounts() async {
    await Future.wait([
      _checkUnreadNotifications(),
      _loadSavedProgramsCount(),
    ]);
  }

  Future<void> _checkUnreadNotifications() async {
    try {
      final resp = await _apiService.getNotifications();
      if (resp.statusCode == 200) {
        final List<dynamic> list = jsonDecode(resp.body);
        final unreadNotifications = list.where((n) => n['is_read'] == false).toList();
        final hasUnread = unreadNotifications.isNotEmpty;
        final count = unreadNotifications.length;

        if (mounted) {
          setState(() {
            _hasUnreadNotifications = hasUnread;
            _unreadNotificationCount = count;
          });
        }
      }
    } catch (e) {
      debugPrint('Notification check failed: $e');
    }
  }

  Future<void> _loadSavedProgramsCount() async {
    try {
      final resp = await _apiService.getSavedPrograms();
      if (resp.statusCode == 200) {
        final List<dynamic> list = jsonDecode(resp.body);
        final count = list.length;

        if (mounted) {
          setState(() {
            _savedProgramsCount = count;
          });
        }
      }
    } catch (e) {
      debugPrint('Saved programs count check failed: $e');
    }
  }

  void _onTap(int index) {
    setState(() => _selectedIndex = index);
    widget.onItemSelected(index);

    // Force refresh counts when specific tabs are tapped
    final tappedItem = widget.items[index].label.toLowerCase();
    if (tappedItem == 'notifications' || tappedItem == 'saved') {
      _loadCounts();
    }
  }

  Widget _buildBadge(int count) {
    if (count <= 0) return const SizedBox.shrink();

    return Positioned(
      top: 0,
      right: 0,
      child: Container(
        constraints: const BoxConstraints(
          minWidth: 18,
          minHeight: 18,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.myGray
                  : AppColors.myBlack,
              width: 1.5
          ),
        ),
        child: Text(
          count > 99 ? '99+' : count.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bg = isDark ? AppColors.myGray : AppColors.myBlack;

    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: widget.items.asMap().entries.map((entry) {
          final idx = entry.key;
          final item = entry.value;
          final sel = idx == _selectedIndex;
          final itemLabel = item.label.toLowerCase();
          final isNotif = itemLabel == 'notifications';
          final isSaved = itemLabel == 'saved';

          final Color highlight = sel
              ? (isDark
              ? AppColors.myBlack.withOpacity(0.2)
              : AppColors.myWhite.withOpacity(0.1))
              : Colors.transparent;
          final Color iconColor = sel
              ? (isDark ? AppColors.darkBlue : AppColors.lightBlue)
              : (isDark ? AppColors.myBlack : AppColors.myWhite);
          final Color textColor = iconColor;

          return GestureDetector(
            onTap: () => _onTap(idx),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: highlight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _buildIcon(itemLabel, iconColor),
                    ),
                    // Notification badge
                    if (isNotif && _hasUnreadNotifications)
                      _buildBadge(_unreadNotificationCount),
                    // Saved programs badge
                    if (isSaved && _savedProgramsCount > 0)
                      _buildBadge(_savedProgramsCount),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                    color: textColor,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildIcon(String label, Color iconColor) {
    switch (label) {
      case 'home':
        return SvgPicture.asset(
          'assets/images/home.svg',
          width: 24,
          height: 24,
          color: iconColor,
        );
      case 'saved':
        return SvgPicture.asset(
          'assets/images/save.svg',
          width: 24,
          height: 24,
          color: iconColor,
        );
      case 'search':
      case 'find':
        return SvgPicture.asset(
          'assets/images/search.svg',
          width: 24,
          height: 24,
          color: iconColor,
        );
      case 'notifications':
        return SvgPicture.asset(
          'assets/images/notification.svg',
          width: 24,
          height: 24,
          color: iconColor,
        );
      default:
        return Icon(
          _getIcon(label),
          size: 24,
          color: iconColor,
        );
    }
  }

  IconData _getIcon(String label) {
    switch (label.toLowerCase()) {
      case 'home':
        return Icons.home;
      case 'search':
      case 'find':
        return Icons.search;
      case 'analytics':
        return Icons.analytics;
      case 'entry test':
      case 'test':
        return Icons.school;
      case 'chatbot':
        return Icons.chat_bubble;
      case 'saved':
        return Icons.save;
      case 'notifications':
        return Icons.notifications;
      default:
        return Icons.circle;
    }
  }
}