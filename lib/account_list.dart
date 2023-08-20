import 'dart:convert';

import 'package:amadeus/account.m.dart';
import 'package:amadeus/account_form.dart';
import 'package:amadeus/log.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountListWidget extends StatefulWidget {
  @override
  _AccountListWidgetState createState() => _AccountListWidgetState();
}

class _AccountListWidgetState extends State<AccountListWidget> {
  List<Account>? _accounts;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final prefix = Account.storagePrefix();

    List<Account> accounts = [];
    for (final key in keys) {
      if (key.startsWith(prefix)) {
        final rawJson = prefs.getString(key);
        final json = jsonDecode(rawJson!);
        final account = Account.fromJson(json);
        accounts.add(account);
      }
    }

    debug("loaded ${accounts.length} prompts");

    setState(() {
      _accounts = accounts;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_accounts == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Accounts'),
        shadowColor: Theme.of(context).colorScheme.shadow,
        actions: [
          TextButton(
            child: const Text("Add Account"),
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Scaffold(
                        appBar: AppBar(
                          backgroundColor:
                              Theme.of(context).colorScheme.inversePrimary,
                          title: const Text('Account Form'),
                          shadowColor: Theme.of(context).colorScheme.shadow,
                        ),
                        body: const AccountForm(
                          allowUpdate: false,
                        )))),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _accounts!.length,
        itemBuilder: (context, index) {
          return Card(
            child: Column(
              children: [
                ListTile(
                  title: Text(_accounts![index].id),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
