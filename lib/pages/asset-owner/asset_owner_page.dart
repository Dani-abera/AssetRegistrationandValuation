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
    // Listening to the notification stream from the provider
    final notificationStream = ref.watch(notificationProvider(widget.isEqualTo ?? ''));
    
    // Calculate the notification count
    final notificationCount = notificationStream.when(
      data: (snapshot) {
        return snapshot.docs.length;
      },
      loading: () => 0, // Show 0 while loading
      error: (err, stack) => 0, // Handle error by showing 0
    );

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0).copyWith(left: 16),
          child: CircleAvatar(
            backgroundColor: Colors.grey[200],
            radius: 20.0,
            child: Icon(Icons.person_3_rounded),
          ),
        ),
        title: Text(
          "Owned Assets",
          style: Theme.of(context).primaryTextTheme.headlineMedium,
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(value: 'logout', child: const Text("Logout")),
              PopupMenuItem(
                value: 'notifications',
                child: Text.rich(TextSpan(children: [
                  TextSpan(text: "Notifications "),
                  TextSpan(text: "$notificationCount", style: TextStyle(fontSize: 8, color: Colors.redAccent)),
                ])),
              ),
            ],
            onSelected: (value) async {
              if (value == 'logout') {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginOrRegister()),
                  (route) => false,
                );
              } else if (value == 'notifications') {
                if (widget.isEqualTo != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => OwnerNotificationPage(owner: widget.isEqualTo!)),
                  );
                }
              }
            },
          ),
        ],
      ),
       body:  AssetsCard(
         condition: widget.condition,
         isEqualTo: widget.isEqualTo,
         widget: widget,
         role: 'Assetowner',
       ), 
    );
  }
}
