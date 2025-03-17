import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:guidera_app/theme/app_colors.dart';

import '../Widgets/header.dart';
import 'home_screen.dart';

/// Data model for a notification item.
class NotificationItem {
  final String avatarUrl;
  final String username;
  final String message;
  final DateTime time;
  final String? imageUrl; // Optional image preview

  NotificationItem({
    required this.avatarUrl,
    required this.username,
    required this.message,
    required this.time,
    this.imageUrl,
  });
}

/// Data model for a deadline item.
class DeadlineItem {
  final String university;
  final DateTime deadline;

  DeadlineItem({
    required this.university,
    required this.deadline,
  });
}

/// NotificationScreen combines a multi-deadline carousel card with a notifications list.
/// The scaffold background is AppColors.myBlack and the header remains unchanged.
class NotificationScreen extends StatelessWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  /// Dummy deadlines list for multiple applications.
  List<DeadlineItem> get dummyDeadlines => [
    DeadlineItem(
      university: "FAST University",
      deadline: DateTime(2025, 3, 25, 23, 59, 59),
    ),
    DeadlineItem(
      university: "NUST",
      deadline: DateTime(2025, 4, 1, 23, 59, 59),
    ),
    DeadlineItem(
      university: "LUMS",
      deadline: DateTime(2025, 4, 15, 23, 59, 59),
    ),
  ];

  /// Dummy notifications list.
  List<NotificationItem> get dummyNotifications => [
    NotificationItem(
      avatarUrl:
      "https://media.licdn.com/dms/image/v2/D4D03AQGny3fTTojZ0w/profile-displayphoto-shrink_100_100/profile-displayphoto-shrink_100_100/0/1724948029439?e=1747872000&v=beta&t=AyRl0cKnFepv_LuLq-CoZfFyfqaqFA0M9Q2sfUMLXFE",
      username: "Aaliyan: ",
      message: "Join our upcoming tech seminar for career insights.",
      time: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    NotificationItem(
      avatarUrl: "https://avatars.githubusercontent.com/u/168419532?v=4",
      username: "Saad: ",
      message: "New internship opportunities at top MNCs available.",
      time: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
    NotificationItem(
      avatarUrl:
      "https://media.licdn.com/dms/image/v2/D5603AQFrkQWdrUsCng/profile-displayphoto-shrink_100_100/profile-displayphoto-shrink_100_100/0/1732851505442?e=1747872000&v=beta&t=bnsf3cMY04HJgS7WJOP5Rf8vYBoBXIAIeXseUQrPRYA",
      username: "Hamza: ",
      message: "New application deadline approaching! Check your details.",
      time: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    NotificationItem(
      avatarUrl:
      "https://media.licdn.com/dms/image/v2/D4E03AQGFNhJPK5r-ng/profile-displayphoto-shrink_100_100/profile-displayphoto-shrink_100_100/0/1715785167813?e=1747872000&v=beta&t=8uzZn-KJyAKYUw_1UXHl0UwX66PUalyxXsceHkY9Cyg",
      username: "Sami Ullah: ",
      message:
      "Your profile is 90% complete – update now for better matches.",
      time: DateTime.now().subtract(const Duration(minutes: 20)),
    ),
  ];

  /// Formats a timestamp as a relative string (e.g. "15m", "2h", "1d").
  String _formatTime(DateTime time) {
    final duration = DateTime.now().difference(time);
    if (duration.inMinutes < 60) {
      return "${duration.inMinutes}m";
    } else if (duration.inHours < 24) {
      return "${duration.inHours}h";
    } else {
      return "${duration.inDays}d";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.myBlack,
      // Custom AppBar using GuideraHeader with a back button.
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: Stack(
          children: [
            const GuideraHeader(),
            Positioned(
              top: 70,
              left: 10,
              child: IconButton(
                icon: SvgPicture.asset(
                  "assets/images/back.svg",
                  color: AppColors.myWhite,
                  height: 30,
                ),
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    // Fallback: navigate to a default screen (e.g., HomeScreen)
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      // Single ListView containing the multi-deadline carousel card and notification cards.
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: dummyNotifications.length + 1, // Extra card at index 0.
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == 0) {
            // Multi-deadline carousel card.
            return DeadlineCarouselCard(deadlines: dummyDeadlines);
          } else {
            // Improved notification card.
            final notification = dummyNotifications[index - 1];
            final timeStr = _formatTime(notification.time);
            return NotificationCard(
              notification: notification,
              timeStr: timeStr,
            );
          }
        },
      ),
    );
  }
}

/// A custom notification card with an enhanced look and feel.
class NotificationCard extends StatelessWidget {
  final NotificationItem notification;
  final String timeStr;
  const NotificationCard({
    Key? key,
    required this.notification,
    required this.timeStr,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightBlack,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 25,
            backgroundImage: NetworkImage(notification.avatarUrl),
          ),
          const SizedBox(width: 12),
          // Username and message
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                        fontSize: 16, color: AppColors.myWhite),
                    children: [
                      TextSpan(
                        text: notification.username,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: " ${notification.message}"),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeStr,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.myGray),
                ),
              ],
            ),
          ),
          // Optional image preview
          notification.imageUrl != null
              ? Container(
            width: 50,
            height: 50,
            margin: const EdgeInsets.only(left: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(notification.imageUrl!),
                fit: BoxFit.cover,
              ),
            ),
          )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}

/// A multi-deadline carousel card that displays several application deadlines.
/// Each slide shows "Time remaining:" on one line with the countdown below,
/// and the associated university name on a new line.
class DeadlineCarouselCard extends StatefulWidget {
  final List<DeadlineItem> deadlines;
  const DeadlineCarouselCard({Key? key, required this.deadlines})
      : super(key: key);

  @override
  _DeadlineCarouselCardState createState() => _DeadlineCarouselCardState();
}

class _DeadlineCarouselCardState extends State<DeadlineCarouselCard> {
  Timer? _timer;
  int _currentPage = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    // Update the countdown every second.
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  /// Formats a duration as "Xd Xh Xm Xs". If the duration is negative, shows "Deadline Passed".
  String _formatDuration(Duration duration) {
    if (duration.isNegative) return "Deadline Passed";
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    return "$days d $hours h $minutes m $seconds s";
  }

  /// Returns a color based on how close the deadline is.
  Color _getCountdownColor(Duration remaining) {
    if (remaining.isNegative) return Colors.grey;
    if (remaining.inHours < 24) return Colors.red; // Near deadline
    if (remaining.inDays < 3) return Colors.orange; // Mid deadline
    return AppColors.myWhite; // Far deadline
  }

  @override
  Widget build(BuildContext context) {
    // Increase the container height slightly to accommodate all content.
    return Container(
      height: 150,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.lightBlack, AppColors.lightBlack],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 6,
            offset: Offset(0, 4),
          )
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 105,
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.deadlines.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                final deadlineItem = widget.deadlines[index];
                final remaining =
                deadlineItem.deadline.difference(DateTime.now());
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Time remaining:",
                      style: TextStyle(
                        color: AppColors.myWhite,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDuration(remaining),
                      style: TextStyle(
                        color: _getCountdownColor(remaining),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "for ${deadlineItem.university}",
                      style: const TextStyle(
                        color: AppColors.lightGray,
                        fontSize: 16,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          // Dot indicator for the carousel.
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.deadlines.length, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 12 : 8,
                height: _currentPage == index ? 12 : 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? AppColors.lightBlue
                      : AppColors.myGray,
                  shape: BoxShape.circle,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
