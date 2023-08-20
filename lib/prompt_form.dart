// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:amadeus/account.m.dart';
import 'package:amadeus/log.dart';
import 'package:amadeus/prompt.m.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PromptForm extends StatefulWidget {
  const PromptForm({
    required this.allowUpdate,
    Key? key,
  }) : super(key: key);
  final bool allowUpdate;

  @override
  _PromptFormState createState() => _PromptFormState();
}

class _PromptFormState extends State<PromptForm> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _description;
  late String _prompt;
  late String _accountId;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            decoration: const InputDecoration(labelText: 'Prompt Name'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a name';
              }
              return null;
            },
            onSaved: (value) {
              _name = value!;
            },
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Description'),
            onSaved: (value) {
              _description = value ?? "";
            },
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Prompt'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a prompt';
              }
              return null;
            },
            onSaved: (value) {
              _prompt = value!;
            },
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Account ID'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an account ID';
              }
              return null;
            },
            onSaved: (value) {
              _accountId = value!;
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () => validateAndSubmit(context),
              child: const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> validateAndSubmit(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final prompt = Prompt(
        name: _name,
        description: _description,
        prompt: _prompt,
        accountId: _accountId,
      );

      final prefs = await SharedPreferences.getInstance();

      // check if the account exists
      final accountKey = Account.storageKey(prompt.accountId);
      final promptKey = Prompt.storageKey(prompt.name);
      if (!prefs.containsKey(accountKey)) {
        error(context, "$accountKey doesn't exists");
      } else if (prefs.containsKey(promptKey) && !widget.allowUpdate) {
        error(context, "Prompt ${prompt.name} already exists");
      } else {
        final accountJson = jsonEncode(prompt.toJson());
        await prefs.setString(promptKey, accountJson);
        info(context, "stored prompt: $promptKey");

        if (context.mounted) Navigator.of(context).pop();
      }
    }
  }
}
