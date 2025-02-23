import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:land_house_verify/provider/notification_provider.dart';
import 'package:toastification/toastification.dart';
import 'package:url_launcher/url_launcher.dart';

class OwnerNotificationPage extends ConsumerWidget {
  final String owner;

  const OwnerNotificationPage({super.key, required this.owner});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<FirestoreQuerySnapshot> notificationStream = 
        ref.watch(notificationProvider(owner));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notification"),
      ),
      body: notificationStream.when(
        data: (snapshot) {
          if (snapshot.docs.isEmpty) {
            return const Center(child: Text("No notifications"));
          }

          return ListView.builder(
            itemCount: snapshot.docs.length,
            itemBuilder: (context, index) {
              final data = snapshot.docs[index].data();
              final reportUrl = data['reportUrl'];
              final message = data['msg'];
              final notificationId = snapshot.docs[index].id;
              return Padding(padding: EdgeInsets.only(left:8, right: 8, top:10),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ClipRect(
                          child: Icon(Icons.folder, size: 30,),
                        ),
                        SizedBox(width: 5,),
                        Expanded(
                          child: Text(
                            message,
                            style: TextStyle(
                              overflow: TextOverflow.ellipsis,
                            ),
                            maxLines: 1,
                          ),
                        ),
                       
                    // More Options Button
                    PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'View') {
                          // Open the report URL
                          try {
                              final Uri url = Uri.parse(reportUrl);
                              if (reportUrl.isNotEmpty && await canLaunchUrl(url)) {
                                // Use `LaunchMode.externalApplication` for documents
                                await launchUrl(url, mode: LaunchMode.externalApplication);
                              } else {
                                toastification.show(
                                  context: context,
                                  title: const Text('Error'),
                                  description: const Text('Could not open the report URL or URL is invalid'),
                                  type: ToastificationType.error,
                                );
                              }
                            } catch (e) {
                              toastification.show(
                                context: context,
                                title: const Text('Error'),
                                description: Text('An error occurred: $e'),
                                type: ToastificationType.error,
                              );
                            }
                        } else if (value == 'Delete') {
                          // Handle delete notification
                          onDelete(context, notificationId);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'View',
                          child: ListTile(
                            leading: Icon(Icons.open_in_browser),
                            title: Text('View'),
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'Delete',
                          child: ListTile(
                            leading: Icon(Icons.delete, color: Colors.red),
                            title: Text('Delete'),
                          ),
                        ),
                      ],
                      icon: const Icon(Icons.more_vert),
                    ),
                      ]
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
      ),
    );
  }
  
  Future<void> onDelete(BuildContext context, String notificationId) async {
    try {
      await FirebaseFirestore.instance
          .collection("valuation-report")
          .doc(notificationId)
          .delete();
      
        toastification.show(
          context: context,
          title: const Text('Notification Deleted'),
          description: const Text('The notification has been removed.'),
          type: ToastificationType.success,
        );

    } catch (e) {

        toastification.show(
          context: context,
          title: const Text("Can't Delete Notification"),
          description: Text("Error deleting notification: $e"),
          type: ToastificationType.error,
        );

    }
  }
}
