import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import 'dashboard_screen.dart';
import '../../sales/screens/sales_list_screen.dart';
import '../../sales/screens/add_sale_screen.dart';
import '../../sales/screens/invoices_screen.dart';
import '../../profile/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const SalesListScreen(),
    // Add padding to lift the "Submit" button above the floating nav bar
    const AddSaleScreen(),
    const InvoicesScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: false, // Solid bottom bar
      body: IndexedStack(
        index: _currentIndex,
        children: _screens.map((screen) {
          // Add padding for sticky bottom bars (like in AddSaleScreen)
          // to prevent overlap with floating nav bar.
          // Note: AddSaleScreen has its own Scaffold. Wrapping it might be tricky.
          // If the screen is AddSaleScreen, we might need specific handling or just let it be.
          // For now, let's keep it simple.
          return screen;
        }).toList(),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
