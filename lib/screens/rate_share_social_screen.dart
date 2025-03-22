import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:guidera_app/theme/app_colors.dart';
import '../Widgets/drawer.dart';

/// A screen that merges:
/// 1) A star rating bottom sheet (Rate App).
/// 2) A minimal share sheet (Share App) via share_plus.
/// 3) Social icons with original brand colors and fallback URLs.
class RateShareSocialScreen extends StatelessWidget {
  const RateShareSocialScreen({Key? key}) : super(key: key);

  // Dummy Play Store link for the app.
  final String _dummyPlayStoreLink =
      "https://play.google.com/store/apps/details?id=com.guidera.app";

  /// Builds a simple card with a title and content.
  Widget _buildCard({required String title, required Widget child}) {
    return Card(
      color: AppColors.lightBlack,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.myWhite,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  /// Opens the star rating bottom sheet.
  void _showRatingBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.myBlack,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _RatingBottomSheet(),
    );
  }

  /// Uses share_plus to open the system share sheet.
  void _shareApp(BuildContext context) {
    // This text gets shared to WhatsApp, Messages, Gmail, etc.
    Share.share("Check out Guidera! $_dummyPlayStoreLink");
  }

  /// Builds the Rate & Share card with two ListTiles.
  Widget _buildRateShareCard(BuildContext context) {
    return _buildCard(
      title: "Rate & Share",
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.star_rate, color: AppColors.myWhite),
            title: const Text(
              "Rate App",
              style: TextStyle(color: AppColors.myWhite),
            ),
            trailing: const Icon(Icons.arrow_forward_ios,
                color: AppColors.myWhite, size: 16),
            onTap: () => _showRatingBottomSheet(context),
          ),
          const Divider(color: AppColors.myGray),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.share, color: AppColors.myWhite),
            title: const Text(
              "Share App",
              style: TextStyle(color: AppColors.myWhite),
            ),
            trailing: const Icon(Icons.arrow_forward_ios,
                color: AppColors.myWhite, size: 16),
            onTap: () => _shareApp(context),
          ),
        ],
      ),
    );
  }

  /// Attempts to open the respective social app if installed; otherwise opens fallback URL.
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

  /// Builds the Follow Us card with brand-colored social icons (no color override).
  Widget _buildFollowUsCard() {
    return _buildCard(
      title: "Follow Us",
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Facebook
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
          // Instagram
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
          // Twitter
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
          // LinkedIn
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.myBlack,
      // Use the common drawer with selected index 5.
      drawer: const GuideraDrawer(selectedIndex: 5),
      appBar: AppBar(
        backgroundColor: AppColors.myBlack,
        elevation: 0,
        // Menu icon to open the drawer.
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: AppColors.myWhite),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          "Rate & Share / Social",
          style: TextStyle(color: AppColors.myWhite),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildRateShareCard(context),
            _buildFollowUsCard(),
          ],
        ),
      ),
    );
  }
}

/// Private bottom sheet widget for rating the app with stars.
class _RatingBottomSheet extends StatefulWidget {
  const _RatingBottomSheet();

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
          const Text(
            "Rate Guidera",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.myWhite,
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
              // Handle rating submission logic here.
              Navigator.pop(context);
            },
            child: const Text("Submit Rating"),
          ),
        ],
      ),
    );
  }
}
