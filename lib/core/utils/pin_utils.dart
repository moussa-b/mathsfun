import 'dart:convert';

import 'package:crypto/crypto.dart';

bool isValidPin(String pin) => RegExp(r'^\d{4}$').hasMatch(pin);

String hashPin(String pin) => sha256.convert(utf8.encode(pin)).toString();

bool verifyPin(String pin, String? hash) {
  if (hash == null) {
    return true;
  }
  return hashPin(pin) == hash;
}
