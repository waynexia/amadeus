import 'dart:convert';
import 'dart:math';

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
  int _tokenUsed = 0;
  late Account _account;

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
      _account = account;
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
          _tokenUsed += result.completionTokens + result.promptTokens;
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

    double estFeeUsd =
        roundDouble(_tokenUsed / _account.tokenUnit * _account.fee, 5);
    double estFeeCustom =
        roundDouble(estFeeUsd * _account.exchangeRateToUsd, 5);

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
              child: Column(children: [
                Row(children: [
                  TextButton(
                      onPressed: () {
                        setState(() {
                          _history.add(Message(
                            "",
                            "User",
                            DateTime.now(),
                            true,
                          ));
                        });
                      },
                      child: const Text("New Conversation")),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Text("Tokens used: $_tokenUsed")),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Text("Est.: \$$estFeeUsd")),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Text("Est. in your currency: $estFeeCustom"))
                ]),
                TextField(
                  maxLines: null,
                  autofocus: true,
                  focusNode: _focusNode,
                  controller: chatTextFieldController,
                  decoration: const InputDecoration(
                    hintText: 'Enter message...',
                    border: OutlineInputBorder(),
                  ),
                )
              ]),
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

double roundDouble(double value, int places) {
  num mod = pow(10.0, places);
  return ((value * mod).round().toDouble() / mod);
}
