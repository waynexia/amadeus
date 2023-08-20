import 'dart:convert';

import 'package:amadeus/chat.dart';
import 'package:http/http.dart' as http;

class OpenaiClient {
  final String url;
  final String path;
  final String token;

  OpenaiClient({required this.url, required this.path, required this.token});

  Future<Result> request(
    String prompt,
    List<Message> history,
  ) async {
    var endpoint = Uri.parse(url + path);
    var response = await http.post(endpoint,
        headers: {"api-key": token, "Content-Type": "application/json"},
        body: jsonEncode({
          "messages": concatMessages(prompt, history),
          'max_tokens': 400,
          'temperature': 1,
          "frequency_penalty": 0,
          "presence_penalty": 0,
          "top_p": 0.95,
          "stop": null,
        }));

    if (response.statusCode == 200) {
      return decodeResult(response.body);
    } else {
      return fail(response.statusCode.toString() + response.body);
    }
  }

  Result fail(String message) {
    return Result(
        isSuccess: false,
        message: message,
        completionTokens: 0,
        promptTokens: 0);
  }

  static Result decodeResult(String bodyJson) {
    var body = jsonDecode(bodyJson);
    var completionTokens = body['usage']['completion_tokens'];
    var promptTokens = body['usage']['prompt_tokens'];
    var messages = body['choices'][0]['message'];
    var message = utf8.decode(messages['content'].runes.toList());
    return Result(
        isSuccess: true,
        message: message,
        completionTokens: completionTokens,
        promptTokens: promptTokens);
  }
}

List<Map<String, String>> concatMessages(
  String prompt,
  List<Message> history,
) {
  List<Map<String, String>> result = [
    {"role": "system", "content": prompt}
  ];
  for (Message item in history) {
    if (item.isNewConversation) {
      result = [
        {"role": "system", "content": prompt}
      ];
    } else {
      String role;
      if (item.sender == "User") {
        role = "user";
      } else {
        role = "assistant";
      }
      result.add({
        "role": role,
        "content": item.text,
      });
    }
  }
  return result;
}

class Result {
  final bool isSuccess;
  final String message;
  final int completionTokens;
  final int promptTokens;

  Result(
      {required this.isSuccess,
      required this.message,
      required this.completionTokens,
      required this.promptTokens});
}
