/*
 * Author: Gerald Addo-Tetteh
 * Stereo Beats Music Player for Android mobile devices.
 * Addo Develop
 * Email: addodevelop@gmail.com
 * Toast (Component)
*/

// This widget is used to form toasts
// A specific message and icon is provided based on the context

// package imports
import 'package:flutter/material.dart';

class ToastComponent extends StatelessWidget {
  final Color? color;
  final String message;
  final IconData icon;
  final Color? iconColor;
  ToastComponent({
    required this.color,
    required this.icon,
    required this.message,
    required this.iconColor,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: color,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: iconColor,
          ),
          SizedBox(
            width: 12.0,
          ),
          Text(message),
        ],
      ),
    );
  }
}
