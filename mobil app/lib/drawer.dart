import 'package:bluetooth_app/bart_chart_page.dart';
import 'package:flutter/material.dart';
import 'constants.dart';
import 'main.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.neavyBlue,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: AppColors.neavyBlue,
            ),
            child: Text(
              '𝙁𝙞𝙩𝙣𝙚𝙨𝙨𝙏𝙧𝙖𝙘𝙠𝙚𝙧',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            title: const Text(
              'Home',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 24,
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FlutterBlueApp()),
              );
            },
          ),
          ListTile(
            title: const Text(
              'Statistics',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 24,
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BarChartPage()),
              );
            },
          ),
          ListTile(
            title: const Text(
              'Settings',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 24,
              ),
            ),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
