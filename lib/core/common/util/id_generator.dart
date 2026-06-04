import 'dart:math';

/// Generates a secure, random alphanumeric ID of specified length.
String generateNanoId({int length = 10}) {
  const chars =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final random = Random.secure();
  return List.generate(
    length,
    (index) => chars[random.nextInt(chars.length)],
  ).join();
}
