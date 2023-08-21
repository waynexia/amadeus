import 'dart:convert';

import 'package:amadeus/account_list.dart';
import 'package:amadeus/chat.dart';
import 'package:amadeus/log.dart';
import 'package:amadeus/prompt.m.dart';
import 'package:amadeus/prompt_form.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PromptListWidget extends StatefulWidget {
  const PromptListWidget({super.key});

  @override
  _PromptListWidgetState createState() => _PromptListWidgetState();
}

class _PromptListWidgetState extends State<PromptListWidget> {
  List<Prompt>? _prompts;
  bool _needReload = false;

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final prefix = Prompt.storagePrefix();

    List<Prompt> prompts = [];
    for (final key in keys) {
      if (key.startsWith(prefix)) {
        final rawJson = prefs.getString(key);
        final json = jsonDecode(rawJson!);
        final prompt = Prompt.fromJson(json);
        prompts.add(prompt);
      }
    }

    debug("loaded ${prompts.length} prompts");

    setState(() {
      _prompts = prompts;
      _needReload = false;
    });
  }

  void pushEditPrompt(int index) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Scaffold(
                appBar: AppBar(
                  backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                  title: const Text('Prompt Form'),
                  shadowColor: Theme.of(context).colorScheme.shadow,
                ),
                body: PromptForm(
                  allowUpdate: true,
                  prompt: _prompts![index],
                )))).then((_) => setState(() {
          _needReload = true;
        }));
  }

  @override
  Widget build(BuildContext context) {
    if (_prompts == null || _needReload) {
      _loadData();
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Amadeus'),
          shadowColor: Theme.of(context).colorScheme.shadow,
          actions: [
            TextButton(
                child: const Text("Accounts"),
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AccountListWidget(),
                    ))),
          ]),
      body: ListView.builder(
        itemCount: _prompts!.length + 1,
        itemBuilder: (context, index) {
          if (index == _prompts!.length) {
            return ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Scaffold(
                              appBar: AppBar(
                                title: const Text('Add Prompt'),
                              ),
                              body: const PromptForm(allowUpdate: false),
                            ))).then((_) => setState(() {
                      _needReload = true;
                    }));
              },
              child: const Text('Add Prompt'),
            );
          }
          return Card(
            child: InkWell(
              child: Column(
                children: [
                  ListTile(
                    title: Text(_prompts![index].name),
                    subtitle: Text(_prompts![index].description),
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    Text(
                      "account: ${_prompts![index].accountId}",
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "estimated fee: ${_prompts![index].estimatedFee}",
                    ),
                  ]),
                ],
              ),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatWidget(_prompts![index].name),
                  )),
              onSecondaryTap: () => pushEditPrompt(index),
              onLongPress: () => pushEditPrompt(index),
            ),
          );
        },
      ),
    );
  }
}
