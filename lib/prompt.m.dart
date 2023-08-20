class Prompt {
  final String name;
  final String description;
  final String prompt;
  final String accountId;
  final double estimatedFee;

  Prompt({
    required this.name,
    required this.description,
    required this.prompt,
    required this.accountId,
    this.estimatedFee = 0,
  });

  factory Prompt.fromJson(Map<String, dynamic> json) {
    return Prompt(
      name: json['name'],
      description: json['description'],
      prompt: json['prompt'],
      accountId: json['accountId'],
      estimatedFee: json['estimatedFee'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'prompt': prompt,
      'accountId': accountId,
      'estimatedFee': estimatedFee,
    };
  }

  static String storageKey(String name) {
    return 'prompt:$name';
  }

  static String storagePrefix() {
    return 'prompt:';
  }
}
