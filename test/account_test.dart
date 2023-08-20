import 'package:flutter_test/flutter_test.dart';
import 'package:amadeus/account.m.dart';

void main() {
  group('Account', () {
    test('fromJson() returns a valid Account object', () {
      final json = {
        'url': 'https://example.com',
        'path': '/api/v1',
        'token': 'my_token',
        'id': '123',
        'exchangeRateToUsd': 1.5,
        'defaultContextNum': 5,
        'tokenUnit': 500,
        'fee': 0.05,
      };

      final account = Account.fromJson(json);

      expect(account.url, equals('https://example.com'));
      expect(account.path, equals('/api/v1'));
      expect(account.token, equals('my_token'));
      expect(account.id, equals('123'));
      expect(account.exchangeRateToUsd, equals(1.5));
      expect(account.defaultContextNum, equals(5));
      expect(account.tokenUnit, equals(500));
      expect(account.fee, equals(0.05));
    });

    test('toJson() returns a valid JSON object', () {
      final account = Account(
        url: 'https://example.com',
        path: '/api/v1',
        token: 'my_token',
        id: '123',
        exchangeRateToUsd: 1.5,
        defaultContextNum: 5,
        tokenUnit: 500,
        fee: 0.05,
      );

      final json = account.toJson();

      expect(json['url'], equals('https://example.com'));
      expect(json['path'], equals('/api/v1'));
      expect(json['token'], equals('my_token'));
      expect(json['id'], equals('123'));
      expect(json['exchangeRateToUsd'], equals(1.5));
      expect(json['defaultContextNum'], equals(5));
      expect(json['tokenUnit'], equals(500));
      expect(json['fee'], equals(0.05));
    });
  });
}
