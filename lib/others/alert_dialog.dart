import 'package:flutter/material.dart';

void showAlertDialog({
  required BuildContext context, required String title, required String message, required VoidCallback onOkay}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Close dialog
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              onOkay(); // Execute the passed function
            },
            child: const Text("Okay"),
          ),
        ],
      );
    },
  );
}
