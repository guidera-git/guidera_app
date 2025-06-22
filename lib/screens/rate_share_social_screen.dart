import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:guidera_app/theme/app_colors.dart';
import 'package:guidera_app/widgets/header.dart';
import '../widgets/drawer.dart';

class RateShareSocialScreen extends StatelessWidget {
  const RateShareSocialScreen({Key? key}) : super(key: key);

  final String _dummyPlayStoreLink =
      "https://play.google.com/store/apps/details?id=com.guidera.app";

  Widget _buildCard({required String title, required Widget child, required BuildContext context}) {
    return Card(
      color: AppColors.surfaceColor(context),
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  void _showRatingBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceColor(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _RatingBottomSheet(),
    );
  }

  void _shareApp(BuildContext context) {
    Share.share("Check out Guidera! $_dummyPlayStoreLink");
  }

  Widget _buildRateShareCard(BuildContext context) {
    return _buildCard(
      title: "Rate & Share",
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.star_rate, color: AppColors.textPrimary(context)),
            title: Text(
              "Rate App",
              style: TextStyle(color: AppColors.textPrimary(context)),
            ),
            trailing: Icon(Icons.arrow_forward_ios,
                color: AppColors.textPrimary(context), size: 16),
            onTap: () => _showRatingBottomSheet(context),
          ),
          Divider(color: AppColors.borderColor(context)),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.share, color: AppColors.textPrimary(context)),
            title: Text(
              "Share App",
              style: TextStyle(color: AppColors.textPrimary(context)),
            ),
            trailing: Icon(Icons.arrow_forward_ios,
                color: AppColors.textPrimary(context), size: 16),
            onTap: () => _shareApp(context),
          ),
        ],
      ),
      context: context,
    );
  }

  Future<void> _openSocialApp({
    required String appUrlScheme,
    required String fallbackUrl,
  }) async {
    final appUri = Uri.parse(appUrlScheme);
    final fallbackUri = Uri.parse(fallbackUrl);

    if (await canLaunchUrl(appUri)) {
      await launchUrl(appUri);
    } else {
      await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildFollowUsCard(BuildContext context) {
    return _buildCard(
      title: "Follow Us",
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          InkWell(
            onTap: () => _openSocialApp(
              appUrlScheme: "fb://page/guidera",
              fallbackUrl: "https://facebook.com/guidera",
            ),
            child: SvgPicture.asset(
              "assets/images/facebook.svg",
              height: 40,
              width: 40,
            ),
          ),
          InkWell(
            onTap: () => _openSocialApp(
              appUrlScheme: "instagram://user?username=guidera",
              fallbackUrl: "https://instagram.com/guidera",
            ),
            child: SvgPicture.asset(
              "assets/images/instagram.svg",
              height: 40,
              width: 40,
            ),
          ),
          InkWell(
            onTap: () => _openSocialApp(
              appUrlScheme: "twitter://user?screen_name=guidera",
              fallbackUrl: "https://twitter.com/guidera",
            ),
            child: SvgPicture.asset(
              "assets/images/twitter.svg",
              height: 40,
              width: 40,
            ),
          ),
          InkWell(
            onTap: () => _openSocialApp(
              appUrlScheme: "linkedin://company/guidera",
              fallbackUrl: "https://linkedin.com/company/guidera",
            ),
            child: SvgPicture.asset(
              "assets/images/linkedin.svg",
              height: 40,
              width: 40,
            ),
          ),
        ],
      ),
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      drawer: const GuideraDrawer(selectedIndex: 5),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: Stack(
          children: [
            const GuideraHeader(),
            Positioned(
              top: 70,
              left: 10,
              child: Builder(
                builder: (context) => IconButton(
                  icon: SvgPicture.asset(
                    "assets/images/menu.svg",
                    color: AppColors.textPrimary(context),
                    height: 30,
                  ),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Rate & Share / Social",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 20),
            _buildRateShareCard(context),
            _buildFollowUsCard(context),
          ],
        ),
      ),
    );
  }
}

class _RatingBottomSheet extends StatefulWidget {
  @override
  State<_RatingBottomSheet> createState() => __RatingBottomSheetState();
}

class __RatingBottomSheetState extends State<_RatingBottomSheet> {
  int _selectedRating = 0;

  Widget _buildStar(int index) {
    return IconButton(
      onPressed: () {
        setState(() {
          _selectedRating = index;
        });
      },
      icon: Icon(
        index <= _selectedRating ? Icons.star : Icons.star_border,
        color: AppColors.lightBlue,
        size: 32,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            "Rate Guidera",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) => _buildStar(index + 1)),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lightBlue,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Submit Rating"),
          ),
        ],
      ),
    );
  }
}