class Account {
  final String url;
  final String path;
  final String token;
  final String id;
  final double exchangeRateToUsd;
  final int defaultContextNum;
  // e.g.: 0.03 usd per 1000 token.
  // - fee = 0.03
  // - token_unit = 1000
  final int tokenUnit;
  final double fee;

  Account({
    required this.url,
    required this.path,
    required this.token,
    required this.id,
    this.exchangeRateToUsd = 1,
    this.defaultContextNum = 10,
    this.tokenUnit = 1000,
    required this.fee,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      url: json['url'],
      path: json['path'],
      token: json['token'],
      id: json['id'],
      exchangeRateToUsd: json['exchangeRateToUsd'],
      defaultContextNum: json['defaultContextNum'],
      tokenUnit: json['tokenUnit'],
      fee: json['fee'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'path': path,
      'token': token,
      'id': id,
      'exchangeRateToUsd': exchangeRateToUsd,
      'defaultContextNum': defaultContextNum,
      'tokenUnit': tokenUnit,
      'fee': fee,
    };
  }

  static String storageKey(String id) {
    return 'account:$id';
  }

  static String storagePrefix() {
    return 'account:';
  }
}
