import 'package:flutter/material.dart';

void showCustomSnackBar(BuildContext context, String message, {bool isError = false, bool isWarning = false}) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(
            isError ? Icons.cancel_rounded : (isWarning ? Icons.error_outline : Icons.check_circle_rounded),
            color: Colors.white,
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
        ],
      ),
      backgroundColor: isError ? Colors.redAccent : (isWarning ? Colors.orangeAccent : Colors.green),
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height - 160,
        left: 20, right: 20,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      duration: const Duration(seconds: 2),
    ),
  );
}