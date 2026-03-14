import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';

/// Admin login against Firestore `superadmin` collection.
/// Documents should have: username (string), passwordHash (string, SHA-256 hex).
/// To create an admin in Firebase Console: add a doc to `superadmin` with
/// username and passwordHash = SHA256(yourPassword) as hex string.
const String _collection = 'superadmin';

class AdminAuthService {
  AdminAuthService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Returns true if a document in `superadmin` has matching username and password.
  /// Supports:
  /// - Field `passwordHash`: SHA-256 hex of password (preferred).
  /// - Field `password`: plain text password (so you can store password directly in Firestore for simplicity).
  /// Document can be found by field `username` or by document ID = username.
  Future<bool> verifyAdmin({
    required String username,
    required String password,
  }) async {
    final trimmedUser = username.trim();
    final trimmedPass = password.trim();
    if (trimmedUser.isEmpty || trimmedPass.isEmpty) return false;

    // 1) Query by username field
    DocumentSnapshot<Map<String, dynamic>>? doc;
    final query = await _firestore
        .collection(_collection)
        .where('username', isEqualTo: trimmedUser)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      doc = query.docs.first;
    } else {
      // 2) Fallback: document ID = username
      final byId = await _firestore.collection(_collection).doc(trimmedUser).get();
      if (byId.exists && byId.data() != null) {
        doc = byId as DocumentSnapshot<Map<String, dynamic>>;
      }
    }

    if (doc == null || !doc.exists) return false;
    final data = doc.data() ?? {};

    // Prefer passwordHash (SHA-256 hex); else plain text password
    final storedHash = data['passwordHash'] as String?;
    final storedPlain = data['password'] as String?;

    if (storedHash != null && storedHash.isNotEmpty) {
      final inputHash = _hashPassword(trimmedPass);
      return storedHash == inputHash;
    }
    if (storedPlain != null) {
      return storedPlain == trimmedPass;
    }
    return false;
  }

  /// Use this to generate passwordHash when adding an admin in Firestore.
  /// Run in Dart: AdminAuthService.hashPasswordForStorage('your_password')
  /// Password is trimmed so it matches login behavior.
  static String hashPasswordForStorage(String password) {
    final bytes = utf8.encode(password.trim());
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
