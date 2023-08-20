// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:amadeus/account.m.dart';
import 'package:amadeus/log.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountForm extends StatefulWidget {
  const AccountForm({
    required this.allowUpdate,
    this.account,
    Key? key,
  }) : super(key: key);
  final bool allowUpdate;
  final Account? account;

  @override
  _AccountFormState createState() => _AccountFormState();
}

class _AccountFormState extends State<AccountForm> {
  final _formKey = GlobalKey<FormState>();
  late String _url;
  late String _path;
  late String _token;
  late String _id;
  late double _exchangeRateToUsd;
  late int _defaultContextNum;
  late int _tokenUnit;
  late double _fee;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            decoration: const InputDecoration(labelText: 'URL'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a URL';
              }
              return null;
            },
            onSaved: (value) {
              _url = value!;
            },
            initialValue: widget.account?.url,
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Path'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a path';
              }
              return null;
            },
            onSaved: (value) {
              _path = value!;
            },
            initialValue: widget.account?.path,
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Token'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a token';
              }
              return null;
            },
            onSaved: (value) {
              _token = value!;
            },
            initialValue: widget.account?.token,
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'ID'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an ID';
              }
              return null;
            },
            onSaved: (value) {
              _id = value!;
            },
            initialValue: widget.account?.id,
          ),
          TextFormField(
            decoration:
                const InputDecoration(labelText: 'Exchange Rate to USD'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an exchange rate';
              }
              if (double.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
            onSaved: (value) {
              _exchangeRateToUsd = double.parse(value!);
            },
            initialValue: widget.account?.exchangeRateToUsd.toString(),
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Default Context Num'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a default context num';
              }
              if (int.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
            onSaved: (value) {
              _defaultContextNum = int.parse(value!);
            },
            initialValue: widget.account?.defaultContextNum.toString(),
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Token Unit'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a token unit';
              }
              if (int.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
            onSaved: (value) {
              _tokenUnit = int.parse(value!);
            },
            initialValue: widget.account?.tokenUnit.toString(),
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Fee'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a fee';
              }
              if (double.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
            onSaved: (value) {
              _fee = double.parse(value!);
            },
            initialValue: widget.account?.fee.toString(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  final account = Account(
                    url: _url,
                    path: _path,
                    token: _token,
                    id: _id,
                    exchangeRateToUsd: _exchangeRateToUsd,
                    defaultContextNum: _defaultContextNum,
                    tokenUnit: _tokenUnit,
                    fee: _fee,
                  );

                  final prefs = await SharedPreferences.getInstance();

                  // check if the account already exists
                  final storageKey = Account.storageKey(account.id);
                  if (prefs.containsKey(storageKey) && !widget.allowUpdate) {
                    error(context, "${account.id} already exists");
                  } else {
                    final accountJson = jsonEncode(account.toJson());
                    await prefs.setString(storageKey, accountJson);
                    info(context, "stored account: $storageKey");

                    if (context.mounted) Navigator.of(context).pop();
                  }
                }
              },
              child: const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }
}
