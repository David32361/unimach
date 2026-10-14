import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unimatch_user/providers/auth_providers.dart';

void listenForAuthErrors(BuildContext context, WidgetRef ref) {
  ref.listen<AsyncValue<void>>(authControllerProvider, (_, next) {
    if (next.hasError && !next.isLoading) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(next.error.toString())));
    }
  });
}
