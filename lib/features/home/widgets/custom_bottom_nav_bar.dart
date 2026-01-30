import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'nav_bar_painter.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Total height of the bar + floating button area
    final Size size = MediaQuery.of(context).size;
    final double height = 80;

    return SizedBox(
      width: size.width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none, // Allow button to float above
        children: [
          // Background with Painter
          Positioned(
            bottom: 0,
            left: 0,
            width: size.width,
            height: 80, // Height of the bar itself
            child: CustomPaint(
              size: Size(size.width, 80),
              painter: NavBarPainter(
                backgroundColor: Colors.white,
                borderColor: Colors.grey.withOpacity(0.3), // Light grey border
              ),
            ),
          ),

          // Center Floating Button (New Sale)
          Positioned(
            top: -12, // Moved up further as requested
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () => onTap(2), // Index 2 is New Sale
                child: Container(
                  width: 52, // Slightly larger
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.secondary.withOpacity(
                        0.2,
                      ), // Subtle border
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1), // Softer shadow
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      CupertinoIcons.add_circled,
                      color: AppColors.secondary, // Blue icon
                      size: 32, // Larger icon
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Center Button Label (Optional, below the float) or inside?
          // The image shows label "Offers" below the floating button.
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "New Sale",
                style: TextStyle(
                  color: currentIndex == 2 ? AppColors.secondary : Colors.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  fontFamily: '.SF Pro Text',
                ),
              ),
            ),
          ),

          // Items
          Positioned(
            bottom: 0,
            left: 0,
            width: size.width,
            height: 80,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, CupertinoIcons.home, 'Home'),
                  _buildNavItem(1, CupertinoIcons.doc_text_search, 'Sales'),
                  // Spacer for center button
                  const SizedBox(width: 60),
                  _buildNavItem(3, CupertinoIcons.doc_plaintext, 'Invoices'),
                  _buildNavItem(4, CupertinoIcons.person, 'Profile'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = currentIndex == index;
    final color = isSelected ? AppColors.secondary : Colors.grey;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontFamily: '.SF Pro Text',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
