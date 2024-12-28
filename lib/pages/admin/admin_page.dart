import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:land_house_verify/components/my_drawer.dart';
import 'asset_detail_page.dart';

class AdminPage extends StatefulWidget {
  final String name;
  const AdminPage({required this.name, super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(),
      appBar: AppBar(
        title: Text('Welcome, ${widget.name.toUpperCase()}',style: TextStyle(color: Colors.black),),
        backgroundColor: Colors.transparent,
        
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('assets').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading assets'));
          }

          final assets = snapshot.data?.docs ?? [];

          if (assets.isEmpty) {
            return const Center(child: Text('No assets found'));
          }

          return ListView.builder(
            itemCount: assets.length,
            itemBuilder: (context, index) {
              final data = assets[index].data() as Map<String, dynamic>;
              final docId = assets[index].id;

              final assetImage = (data['assetImage'] as List?)?.first ?? '';
              final assetName = data['assetName'] ?? 'Unknown Asset';
              final ownership = data['ownership'] ?? 'Unknown Owner';
              final validator = data['validator'] ?? 'Not Assigned';

              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                          ),
                          child: assetImage.isNotEmpty
                              ? Image.network(
                                  assetImage,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Center(
                                      child: Text('Image not available'),
                                    );
                                  },
                                )
                              : Image.asset(
                                  'assets/images/image.png',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Center(
                                      child: Text('Image not available'),
                                    );
                                  },
                                )
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text('Asset Name: $assetName'),
                      const SizedBox(height: 5),
                      Text('Asset Owner: $ownership'),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Text('Valuator:'),
                          const SizedBox(width: 10),
                          Container(
                            height: 20,
                            width: 100,
                            padding: const EdgeInsets.only(left: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: const Color.fromARGB(255, 207, 209, 214),
                            ),
                            child: Text(validator),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                     Row(children: [
                        Text("Status: "),
                        SizedBox(width: 10,),
                        Container(
                          height: 20, 
                          width: 100,
                          padding: EdgeInsets.only(left: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: const Color.fromARGB(255, 207, 209, 214)
                          ),
                          child: Text(' ${data['status']}'),)
                          
                      ],),
                      const SizedBox(height: 15,),
                      Container(
                        height: 40, 
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5), 
                          gradient: const LinearGradient(colors: [
                            Colors.lightGreen,
                            Colors.greenAccent
                          ])
                        ),
                        child: ElevatedButton(onPressed: (){
                          // Navigate to detailed asset page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AssetDetailPage(assetId: docId),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          shadowColor: Colors.transparent,
                          backgroundColor: Colors.transparent
                        ), child: Text("View Detail", style: TextStyle(color: Colors.white,fontSize: 17, fontWeight: FontWeight.bold),),
                        )
                      ),
                    ],
                  ),
              );
            },
          );
        },
      ),
    );
  }
}
