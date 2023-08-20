import 'package:flutter_test/flutter_test.dart';
import 'package:amadeus/prompt.m.dart';

void main() {
  group('Prompt', () {
    test('fromJson() returns a valid Prompt object', () {
      final json = {
        'name': 'My Prompt',
        'description': 'This is a test prompt',
        'prompt': 'Enter your name',
        'accountId': '123',
        'estimatedFee': 0.05,
      };

      final prompt = Prompt.fromJson(json);

      expect(prompt.name, equals('My Prompt'));
      expect(prompt.description, equals('This is a test prompt'));
      expect(prompt.prompt, equals('Enter your name'));
      expect(prompt.accountId, equals('123'));
      expect(prompt.estimatedFee, equals(0.05));
    });

    test('toJson() returns a valid JSON object', () {
      final prompt = Prompt(
        name: 'My Prompt',
        description: 'This is a test prompt',
        prompt: 'Enter your name',
        accountId: '123',
        estimatedFee: 0.05,
      );

      final json = prompt.toJson();

      expect(json['name'], equals('My Prompt'));
      expect(json['description'], equals('This is a test prompt'));
      expect(json['prompt'], equals('Enter your name'));
      expect(json['accountId'], equals('123'));
      expect(json['estimatedFee'], equals(0.05));
    });
  });
}
