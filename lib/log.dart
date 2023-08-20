import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

final logger = Logger();

void error(BuildContext context, String message) {
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
        content: Text(message,
            style: TextStyle(color: Theme.of(context).colorScheme.error))));
  }
  logger.e(message);
}

void info(BuildContext context, String message) {
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
        content: Text(message,
            style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary))));
  }
  logger.i(message);
}

void debug(String message) {
  logger.d(message);
}
