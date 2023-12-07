import 'package:flutter/material.dart';
import 'package:task_master/presentation/RepositoryManager.dart';

Widget logOutIconButton(BuildContext context) {
  return IconButton(onPressed: () async {
    await RepositoryManager().authRepository.logOut();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }, icon: const Icon(Icons.logout));
}