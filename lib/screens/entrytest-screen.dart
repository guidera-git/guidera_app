import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:guidera_app/Widgets/header.dart';
import 'package:guidera_app/screens/question-screen.dart';
import 'package:guidera_app/theme/app_colors.dart';
import 'package:guidera_app/services/api_service.dart';
import 'dart:math' as math;

class SubjectCard {
  final String title;
  final String iconPath;
  final LinearGradient gradient;
  final Color titleColor;
  final Color circleColor;
  final Color iconColor;
  final String code;

  const SubjectCard({
    required this.title,
    required this.iconPath,
    required this.gradient,
    required this.titleColor,
    required this.circleColor,
    required this.iconColor,
    required this.code,
  });
}

class EntryTestScreen extends StatefulWidget {
  const EntryTestScreen({Key? key}) : super(key: key);

  @override
  State<EntryTestScreen> createState() => _EntryTestScreenState();
}

class _EntryTestScreenState extends State<EntryTestScreen> {
  final ApiService _apiService = ApiService();

  List<SubjectCard> _getSubjects(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (isDarkMode) {
      return [
        SubjectCard(
          title: 'Chemistry',
          iconPath: 'assets/images/chemistry.svg',
          gradient: LinearGradient(colors: [AppColors.myWhite, AppColors.myWhite]),
          titleColor: AppColors.darkBlue,
          circleColor: AppColors.darkBlue,
          iconColor: AppColors.myWhite,
          code: 'CHEMISTRY',
        ),
        SubjectCard(
          title: 'Biology',
          iconPath: 'assets/images/biology.svg',
          gradient: LinearGradient(colors: [AppColors.darkBlue, AppColors.darkBlue]),
          titleColor: AppColors.myWhite,
          circleColor: AppColors.myWhite,
          iconColor: AppColors.darkBlue,
          code: 'BIOLOGY',
        ),
        SubjectCard(
          title: 'Physics',
          iconPath: 'assets/images/physics.svg',
          gradient: LinearGradient(colors: [AppColors.darkBlue, AppColors.darkBlue]),
          titleColor: AppColors.myWhite,
          circleColor: AppColors.myWhite,
          iconColor: AppColors.myBlack,
          code: 'PHYSICS',
        ),
        SubjectCard(
          title: 'English',
          iconPath: 'assets/images/english.svg',
          gradient: LinearGradient(colors: [AppColors.myWhite, AppColors.myWhite]),
          titleColor: AppColors.darkBlue,
          circleColor: AppColors.darkBlue,
          iconColor: AppColors.myWhite,
          code: 'ENGLISH',
        ),
        SubjectCard(
          title: 'Analytical ',
          iconPath: 'assets/images/test.svg',
          gradient: LinearGradient(colors: [AppColors.myWhite, AppColors.myWhite]),
          titleColor: AppColors.darkBlue,
          circleColor: AppColors.myWhite,
          iconColor: AppColors.darkBlue,
          code: 'ANALYTICAL_REASONING',
        ),
      ];
    } else {
      return [
        SubjectCard(
          title: 'Chemistry',
          iconPath: 'assets/images/chemistry.svg',
          gradient: LinearGradient(colors: [AppColors.lightSurface, AppColors.lightSurface]),
          titleColor: AppColors.darkBlue,
          circleColor: AppColors.lightBlue.withOpacity(0.1),
          iconColor: AppColors.lightBlue,
          code: 'CHEMISTRY',
        ),
        SubjectCard(
          title: 'Biology',
          iconPath: 'assets/images/biology.svg',
          gradient: LinearGradient(colors: [AppColors.lightSurface, AppColors.lightSurface]),
          titleColor: AppColors.darkBlue,
          circleColor: AppColors.lightBlue.withOpacity(0.15),
          iconColor: AppColors.lightBlue,
          code: 'BIOLOGY',
        ),
        SubjectCard(
          title: 'Physics',
          iconPath: 'assets/images/physics.svg',
          gradient: LinearGradient(colors: [AppColors.lightSurface, AppColors.lightSurface]),
          titleColor: AppColors.darkBlue,
          circleColor: AppColors.lightBlue.withOpacity(0.1),
          iconColor: AppColors.lightBlue,
          code: 'PHYSICS',
        ),
        SubjectCard(
          title: 'English',
          iconPath: 'assets/images/english.svg',
          gradient: LinearGradient(colors: [AppColors.lightSurface, AppColors.lightSurface]),
          titleColor: AppColors.darkBlue,
          circleColor: AppColors.lightBlue.withOpacity(0.1),
          iconColor: AppColors.lightBlue,
          code: 'ENGLISH',
        ),
        SubjectCard(
          title: 'Analytical',
          iconPath: 'assets/images/test.svg',
          gradient: LinearGradient(colors: [AppColors.lightSurface, AppColors.lightSurface]),
          titleColor: AppColors.darkBlue,
          circleColor: AppColors.lightBlue.withOpacity(0.1),
          iconColor: AppColors.lightBlue,
          code: 'ANALYTICAL_REASONING',
        ),
      ];
    }
  }

  Future<void> _startTest(SubjectCard subject) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => TestLoadingDialog(subjectTitle: subject.title),
    );

    try {
      final response = await _apiService.startTest(subject.code);
      Navigator.of(context).pop();

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final attemptId = data['attemptId'];
        final questions = data['questions'];

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => QuestionScreen(
              subjectName: subject.title,
              attemptId: attemptId,
              questions: questions,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start test: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final subjects = _getSubjects(context);
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
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
                  'assets/images/back.svg',
                  color: AppColors.textPrimary(context),
                  height: 30,
                ),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          WelcomeCard(userName: 'Stay Focused!'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
                itemCount: subjects.length,
                itemBuilder: (context, index) {
                  final subject = subjects[index];
                  return SubjectCardWidget(
                    data: subject,
                    onTap: () => _startTest(subject),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TestLoadingDialog extends StatefulWidget {
  final String subjectTitle;

  const TestLoadingDialog({Key? key, required this.subjectTitle}) : super(key: key);

  @override
  State<TestLoadingDialog> createState() => _TestLoadingDialogState();
}

class _TestLoadingDialogState extends State<TestLoadingDialog>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _scaleController.forward();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(32),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: AppColors.surfaceColor(context),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: isDarkMode
                    ? Colors.black.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 5,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Custom animated loading indicator
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: isDarkMode
                        ? [AppColors.darkBlue, AppColors.lightBlue]
                        : [AppColors.lightBlue, AppColors.darkBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.lightBlue.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer rotating ring
                    AnimatedBuilder(
                      animation: _rotationController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _rotationController.value * 2 * math.pi,
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: CustomPaint(
                              painter: LoadingRingPainter(
                                progress: _rotationController.value,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    // Center icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.play_arrow_rounded,
                        color: AppColors.lightBlue,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Subject title
              Text(
                widget.subjectTitle,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // Loading text with animated dots
              AnimatedBuilder(
                animation: _rotationController,
                builder: (context, child) {
                  int dotCount = ((_rotationController.value * 3) % 3).floor() + 1;
                  return Text(
                    'Preparing your test${'.' * dotCount}',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary(context),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  );
                },
              ),

              const SizedBox(height: 16),

              // Motivational text
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.lightBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.lightBlue.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  'Get ready to showcase your knowledge!',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.lightBlue,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoadingRingPainter extends CustomPainter {
  final double progress;

  LoadingRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 5;

    // Draw the progress arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class SubjectCardWidget extends StatelessWidget {
  final SubjectCard data;
  final VoidCallback onTap;

  const SubjectCardWidget({Key? key, required this.data, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16.0),
      child: Ink(
        decoration: BoxDecoration(
          gradient: data.gradient,
          borderRadius: BorderRadius.circular(16.0),
          border: isDarkMode ? null : Border.all(
            color: AppColors.borderColor(context),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor(context),
              blurRadius: isDarkMode ? 8 : 12,
              spreadRadius: isDarkMode ? 2 : 3,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16.0),
          onTap: onTap,
          child: Stack(
            children: [
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: data.titleColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: data.titleColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    data.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: data.titleColor,
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
                    color: data.circleColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowColor(context),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Transform.rotate(
                    angle: 145 * math.pi / 180,
                    child: SvgPicture.asset(
                      'assets/images/back.svg',
                      width: 16,
                      height: 16,
                      color: data.iconColor,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                right: 12,
                child: SvgPicture.asset(
                  data.iconPath,
                  height: 50,
                  width: 50,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WelcomeCard extends StatelessWidget {
  final String userName;

  const WelcomeCard({Key? key, required this.userName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: isDarkMode
            ? const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [AppColors.myWhite, AppColors.myGray],
        )
            : LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [AppColors.lightSurface, AppColors.lightBorder],
        ),
        borderRadius: BorderRadius.circular(16.0),
        border: isDarkMode ? null : Border.all(
          color: AppColors.borderColor(context),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor(context),
            blurRadius: isDarkMode ? 6 : 10,
            spreadRadius: isDarkMode ? 1 : 2,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enjoy Preparing',
                  style: TextStyle(
                    fontSize: 20.0,
                    color: AppColors.darkBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  userName,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.normal,
                    color: isDarkMode ? AppColors.myBlack : AppColors.lightTextPrimary,
                  ),
                ),
              ],
            ),
          ),
          SvgPicture.asset(
            'assets/images/student_laptop.svg',
            height: 100.0,
            width: 80.0,
          ),
        ],
      ),
    );
  }
}