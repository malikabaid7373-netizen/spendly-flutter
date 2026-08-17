import 'dart:convert';

class UserProfile {
  const UserProfile({required this.name, required this.email, this.currencyCode = 'SAR'});

  final String name;
  final String email;
  final String currencyCode;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'S';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  String toJson() => jsonEncode({'name': name, 'email': email, 'currencyCode': currencyCode});

  factory UserProfile.fromJson(String source) {
    final map = jsonDecode(source) as Map<String, dynamic>;
    return UserProfile(name: map['name'] as String, email: map['email'] as String, currencyCode: (map['currencyCode'] as String?) ?? 'SAR');
  }
}
