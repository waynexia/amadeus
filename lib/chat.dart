import 'dart:convert';

import 'package:amadeus/account.m.dart';
import 'package:amadeus/log.dart';
import 'package:amadeus/openai.dart';
import 'package:amadeus/prompt.m.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatWidget extends StatefulWidget {
  final String promptName;

  const ChatWidget(
    this.promptName,
  ) : super();

  @override
  _ChatWidgetState createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  List<Message> _history = [];
  late Prompt _prompt;
  bool isInited = false;
  late OpenaiClient _client;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    final promptRawJson = prefs.getString(Prompt.storageKey(widget.promptName));
    final promptJson = jsonDecode(promptRawJson!);
    final prompt = Prompt.fromJson(promptJson);

    final accountRawJson =
        prefs.getString(Account.storageKey(prompt.accountId));
    final accountJson = jsonDecode(accountRawJson!);
    final account = Account.fromJson(accountJson);
    final client = OpenaiClient(
        url: account.url, path: account.path, token: account.token);

    debug("loaded account and prompt from storage");

    setState(() {
      isInited = true;
      _prompt = prompt;
      _client = client;
    });
  }

  final TextEditingController chatTextFieldController = TextEditingController();
  late final _focusNode = FocusNode(
    onKey: _handleKeyPress,
  );

  KeyEventResult _handleKeyPress(FocusNode focusNode, RawKeyEvent event) {
    // handles submit on enter
    if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
      if (!event.isShiftPressed && !event.isControlPressed) {
        _sendMessage();
      } else {
        chatTextFieldController.text += "\n";
      }
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _sendMessage() {
    if (chatTextFieldController.text.trim().isNotEmpty) {
      // Do something with your input text
      setState(() {
        _history.add(Message(
          chatTextFieldController.text,
          "User",
          DateTime.now(),
          false,
        ));
      });

      _client.request(_prompt.prompt, _history).then((result) {
        setState(() {
          _history.add(Message(
            result.message,
            "assistant",
            DateTime.now(),
            false,
          ));
        });
      }).catchError((error) {
        setState(() {
          _history.add(Message(
            error.toString(),
            "assistant",
            DateTime.now(),
            false,
          ));
        });
      });

      // bring focus back to the input field
      Future.delayed(Duration.zero, () {
        _focusNode.requestFocus();
        chatTextFieldController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isInited) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.promptName),
          shadowColor: Theme.of(context).colorScheme.shadow,
          actions: [
            TextButton(
              child: const Text("Clear History"),
              onPressed: () {
                setState(() {
                  _history = [];
                });
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
                child: SingleChildScrollView(
                    child: Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (Message item in _history)
                      if (item.isNewConversation)
                        const Divider()
                      else if (item.sender == "User")
                        Text(
                          item.text,
                          textAlign: TextAlign.right,
                        )
                      else
                        Text(
                          item.text,
                          textAlign: TextAlign.left,
                        ),
                  ]),
            ))),
            Align(
              alignment: Alignment.bottomCenter,
              child: TextField(
                maxLines: null,
                autofocus: true,
                focusNode: _focusNode,
                controller: chatTextFieldController,
                decoration: const InputDecoration(
                  hintText: 'Enter message...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ));
  }
}

class Message {
  final String text;
  final String sender;
  final DateTime timestamp;
  final bool isNewConversation;

  Message(this.text, this.sender, this.timestamp, this.isNewConversation);
}
