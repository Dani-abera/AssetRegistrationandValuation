import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

ToastificationItem customToastInfo({
  required BuildContext context,
  String? type = 'Success',
  String? message
}) {
  return toastification.show(
            context: context,
            type: ToastificationType.success,
            title:  Text(type!),
            description: RichText(
              text: TextSpan(
                text: message,
                style: const TextStyle(color: Colors.black),
              ),
            ),
            alignment: Alignment.topRight,
            autoCloseDuration: const Duration(seconds: 5),
            primaryColor:type=='Success'? Colors.green:Colors.red,
            backgroundColor: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color(0x07000000),
                blurRadius: 16,
                offset: Offset(0, 16),
                spreadRadius: 0,
              ),
            ],
            showProgressBar: true,
            closeButtonShowType: CloseButtonShowType.onHover,
            dragToClose: true,
            callbacks: ToastificationCallbacks(
              onTap: (toastItem) =>
                  print('Toast ${toastItem.id} tapped'),
              onDismissed: (toastItem) =>
                  print('Toast ${toastItem.id} dismissed'),
            ),
    );
  }