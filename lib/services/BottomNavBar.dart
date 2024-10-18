// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:toyflow/screens/adminPage/adminHomeScreen/adminHomeScreen.dart';
import 'package:toyflow/screens/adminPage/adminWorkShopPage/adminWorkShopScreen.dart';
import 'package:toyflow/screens/chatScreen/chatScreen.dart';

import '../screens/adminPage/adminSearchPage/adminSearchScreen.dart';

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
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashFactory: NoSplash.splashFactory, 
          highlightColor: Colors.transparent, 
        ),
        child: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.home_work_outlined, 0), 
              label: '',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.cut_outlined, 1), 
              label: '',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.chat_bubble_outline, 2), 
              label: '',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.search_outlined, 3), 
              label: '',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          elevation: 0, 
          backgroundColor: Colors.white, 
        ),
      ),
      body: _pages[_selectedIndex], 
    );
  }

  // İkonu oluşturmak için yardımcı metot
  Widget _buildIcon(IconData icon, int index) {
    bool isSelected = _selectedIndex == index;
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? Colors.black : Colors.transparent, 
      ),
      padding: const EdgeInsets.all(8.0), 
      child: Icon(
        icon,
        color: isSelected ? Colors.white : Colors.black, 
        size: isSelected ? 20 : 18, 
      ),
    );
  }
}
