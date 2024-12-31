import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:land_house_verify/pages/asset-owner/owner_notification_page.dart';
import 'package:land_house_verify/pages/widget/asset_card_view.dart';
import 'package:land_house_verify/services/login_or_register.dart';

class AssetOwnerPage extends StatefulWidget {
  final String? isEqualTo;
  final String? condition;
  const AssetOwnerPage({super.key,  this.isEqualTo, this.condition});

  @override
  State<AssetOwnerPage> createState() => _AssetOwnerPageState();
}

class _AssetOwnerPageState extends State<AssetOwnerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0).copyWith(left: 16),
          child:  CircleAvatar(backgroundColor: Theme.of(context).disabledColor,radius: 20.0, child: Icon(Icons.person_3_rounded)),
        ),
        title: Text("Owned Assets"),
        actions: [Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              // Navigate to the login or home screen after signing out
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => LoginOrRegister()),
                (route) => false, // Remove all previous routes
              );
            },
            child: Text(
              "Logout", 
              style: TextStyle(
                color: Colors.lightBlueAccent, 
                fontWeight: FontWeight.bold
                ),
              )
            ),
        ),
        GestureDetector(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => OwnerNotificationPage(owner:widget.isEqualTo)));
            },
            child: Stack(
              children: [
                Positioned(
                  right: 8, 
                  top: 0,
                  child: Text("1",
                  style: TextStyle(color: Colors.redAccent),
                  )
                  ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.notifications),
                ),
              ],
            ),
          )
       
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

