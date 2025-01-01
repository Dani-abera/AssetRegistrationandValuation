import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:land_house_verify/pages/asset-owner/owner_notification_page.dart';
import 'package:land_house_verify/pages/widget/asset_card_view.dart';
import 'package:land_house_verify/services/login_or_register.dart';
import 'package:land_house_verify/provider/notification_provider.dart';

class AssetOwnerPage extends ConsumerStatefulWidget {
  final String? isEqualTo;
  final String? condition;

  const AssetOwnerPage({super.key, this.isEqualTo, this.condition});

  @override
  ConsumerState<AssetOwnerPage> createState() => _AssetOwnerPageState();
}

class _AssetOwnerPageState extends ConsumerState<AssetOwnerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0).copyWith(left: 16),
          child: CircleAvatar(
            backgroundColor: Theme.of(context).disabledColor,
            radius: 20.0,
            child: Icon(Icons.person_3_rounded),
          ),
        ),
        title: Text("Owned Assets"),
        actions: [
          PopupMenuButton(
            icon: Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'logout',
                child: const Text("Logout"),
              ),
              PopupMenuItem(
                value: 'notifications',
                child: Text("Notifications"),
              ),
            ],
            onSelected: (value) async {
              if (value == 'logout') {
                await FirebaseAuth.instance.signOut();
                // Navigate to the login or home screen after signing out
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginOrRegister()),
                  (route) => false, // Remove all previous routes
                );
              } else if (value == 'notifications') {
                if (widget.isEqualTo != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          OwnerNotificationPage(owner: widget.isEqualTo!),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('No owner specified.')),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: AssetsCard(
        condition: widget.condition,
        isEqualTo: widget.isEqualTo,
        widget: widget,
        role: 'Assetowner',
      ),
    );
  }
}
