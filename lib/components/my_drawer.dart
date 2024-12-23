import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:land_house_verify/pages/registration_page.dart';
import '../pages/admin_validator_approval_page.dart';
import '../pages/register_asset_page.dart';
import '../services/login_or_register.dart';
import 'my_drawer_tile.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

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
            text: 'C R E A T E  A C C O U N T ',
            icon: Icons.account_box,
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
            text: 'A P P R O V A L',
            icon: Icons.approval,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AdminValidatorApproval(),
                ),
              );
            },
          ),
          MyDrawerTile(
            text: 'R E G I S T E R  A S S E T S',
            icon: Icons.app_registration_sharp,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RegisterAssetPage(),
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginOrRegister(),
                ),
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
