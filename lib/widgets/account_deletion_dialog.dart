// widgets/account_deletion_dialog.dart
import 'package:flutter/material.dart';

class AccountDeletionDialog extends StatelessWidget {
  const AccountDeletionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Account'),
      content: const Text(
        'Are you sure you want to delete your account? This action cannot be undone.'
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('CANCEL'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('DELETE'),
        ),
      ],
    );
  }
}