import 'package:flutter_riverpod/flutter_riverpod.dart';

final userProvider = FutureProvider<User>((ref) async {
  await Future.delayed(const Duration(seconds: 2)); // API call simulation
  return User(name: "Asish", age: 22);
});

class User {
  final String name;
  final int age;
  User({required this.name, required this.age});
}
