// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, file_names

import 'package:flutter/material.dart';
import 'package:toyflow/screens/adminPage/adminHomeScreen/admin_home_screen.dart';
import 'package:toyflow/screens/adminPage/adminWorkShopPage/admin_work_shop_screen.dart';
import 'package:toyflow/screens/chatScreen/chat_screen.dart';
import '../screens/adminPage/adminSearchPage/admin_search_screen.dart';

class BottomNavBarWithPages extends StatefulWidget {
  @override
  _BottomNavBarWithPagesState createState() => _BottomNavBarWithPagesState();
}

class _BottomNavBarWithPagesState extends State<BottomNavBarWithPages> {
  int _selectedIndex = 0; // Aktif sayfa indeksi

  final List<Widget> _pages = [
    const AdminHomeScreen(),
    const AdminWorkShopScreen(),
    const ChatScreen(),
    const AdminSearchScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Seçilen indeksi güncelle
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        child: Theme(
          data: Theme.of(context).copyWith(
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: _buildAnimatedIcon(Icons.home_work_outlined, 0),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: _buildAnimatedIcon(Icons.cut_outlined, 1),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: _buildAnimatedIcon(Icons.chat_bubble_outline, 2),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: _buildAnimatedIcon(Icons.search_outlined, 3),
                label: '',
              ),
            ],
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
        ),
      ),
      body: _pages[_selectedIndex],
    );
  }

  // Daha ince ve küçük boyutlarda animasyonlu ikon metodu
  Widget _buildAnimatedIcon(IconData icon, int index) {
    bool isSelected = _selectedIndex == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      margin: EdgeInsets.only(bottom: isSelected ? 6 : 0), // Daha küçük zıplama etkisi
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? Colors.black : Colors.transparent,
      ),
      padding: EdgeInsets.all(isSelected ? 8.0 : 4.0), // Daha ince padding
      child: Icon(
        icon,
        color: isSelected ? Colors.white : Colors.black,
        size: isSelected ? 20 : 16, // Daha küçük ikon boyutu
      ),
    );
  }
}
