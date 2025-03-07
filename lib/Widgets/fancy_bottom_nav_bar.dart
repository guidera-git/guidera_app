import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'fancy_nav_item.dart';
import 'package:guidera_app/theme/app_colors.dart'; // <-- Import your color constants file

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

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    widget.onItemSelected(index);
  }

  @override
  Widget build(BuildContext context) {
    // Determine if we're in dark mode
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Nav bar color: if dark mode => myGray, else => myBlack
    final Color navBarColor =
    isDarkMode ? AppColors.myGray : AppColors.myBlack;

    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: navBarColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(widget.items.length, (index) {
          final item = widget.items[index];
          final bool isSelected = (index == _selectedIndex);

          // Highlight container color:
          // if selected => black(ish) overlay in dark mode, white(ish) overlay in light mode
          final Color highlightColor = isSelected
              ? (isDarkMode
              ? AppColors.myBlack.withOpacity(0.2)
              : AppColors.myWhite.withOpacity(0.1))
              : Colors.transparent;

          // Icon color filter:
          // if selected => darkBlue (dark mode) or lightBlue (light mode),
          // else => myBlack for unselected
          final Color iconColor = isSelected
              ? (isDarkMode ? AppColors.darkBlue : AppColors.lightBlue)
              : (isDarkMode ? AppColors.myBlack : AppColors.myWhite);

          // Text color:
          // if selected => darkBlue (dark mode) or lightBlue (light mode),
          // else => myBlack
          final Color textColor = isSelected
              ? (isDarkMode ? AppColors.darkBlue : AppColors.lightBlue)
              : (isDarkMode ? AppColors.myBlack : AppColors.myWhite);

          return GestureDetector(
            onTap: () => _onTap(index),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Highlight container (only around icon)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: highlightColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SvgPicture.asset(
                    item.svgPath,
                    width: 20,
                    height: 25,
                    colorFilter: ColorFilter.mode(
                      iconColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // Text outside highlight container
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: textColor,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
