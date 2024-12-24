import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:land_house_verify/pages/registration_page.dart';
import 'package:land_house_verify/pages/setting_page.dart';
import 'package:land_house_verify/pages/valuation_Input_page.dart';
import '../pages/register_asset_page.dart';
import '../services/login_or_register.dart';
import 'my_drawer_tile.dart';

class MyDrawerValidator extends StatelessWidget {
  const MyDrawerValidator({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.background,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 100.0),
            child: Icon(
              Icons.lock_open_rounded,
              size: 80,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Divider(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          MyDrawerTile(
            text: 'H O M E',
            icon: Icons.home,
            onTap: () => Navigator.pop(context),
          ),
          MyDrawerTile(
            text: 'C R E A T E  R E P O R T S',
            icon: Icons.insert_drive_file_rounded,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RegisterPage(onTap: () {}),
                ),
              );
            },
          ),
          MyDrawerTile(
            text: 'E V A L U A T I O N',
            icon: Icons.input_rounded,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ValuationInputPage(assetId: '1'),
                ),
              );
            },
          ),
          MyDrawerTile(
            text: 'R E V A L U A T I O N',
            icon: Icons.refresh_rounded,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RegisterAssetPage(),
                ),
              );
            },
          ),
          MyDrawerTile(
            text: 'S E T T I N G',
            icon: Icons.assignment,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingPage(),
                ),
              );
            },
          ),
          const Spacer(),
          MyDrawerTile(
            text: 'L O G O U T',
            icon: Icons.logout,
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              // Navigate to the login or home screen after signing out
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => LoginOrRegister()),
                (route) => false, // Remove all previous routes
              );
            },
          ),
          SizedBox(
            height: 25,
          )
        ],
      ),
    );
  }
}
