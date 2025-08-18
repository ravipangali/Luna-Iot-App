import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorageService {
  static const _storage = FlutterSecureStorage();

  static const _phoneKey = 'phone';
  static const _tokenKey = 'token';
  static const _savedAccountsKey =
      'saved_accounts'; // New key for multiple accounts

  static Future<void> saveAuth(String phone, String token) async {
    await Future.wait([
      _storage.write(key: _phoneKey, value: phone),
      _storage.write(key: _tokenKey, value: token),
    ]);
  }

  // Save credentials for multiple accounts
  static Future<void> saveCredentials(String phone, String password) async {
    try {
      // Get existing saved accounts
      List<Map<String, String>> savedAccounts = await getSavedAccounts();

      // Check if account already exists
      bool accountExists = savedAccounts.any(
        (account) => account['phone'] == phone,
      );

      if (!accountExists) {
        // Add new account
        savedAccounts.add({
          'phone': phone,
          'password': password,
          'timestamp': DateTime.now().toIso8601String(),
        });

        // Save updated list
        await _storage.write(
          key: _savedAccountsKey,
          value: jsonEncode(savedAccounts),
        );
      } else {
        // Update existing account password
        int index = savedAccounts.indexWhere(
          (account) => account['phone'] == phone,
        );
        if (index != -1) {
          savedAccounts[index]['password'] = password;
          savedAccounts[index]['timestamp'] = DateTime.now().toIso8601String();

          await _storage.write(
            key: _savedAccountsKey,
            value: jsonEncode(savedAccounts),
          );
        }
      }
    } catch (e) {
      print('Error saving credentials: $e');
    }
  }

  // Get all saved accounts
  static Future<List<Map<String, String>>> getSavedAccounts() async {
    try {
      final accountsJson = await _storage.read(key: _savedAccountsKey);
      if (accountsJson != null) {
        List<dynamic> accountsList = jsonDecode(accountsJson);
        return accountsList
            .map((account) => Map<String, String>.from(account))
            .toList();
      }
    } catch (e) {
      print('Error loading saved accounts: $e');
    }
    return [];
  }

  // Get all saved phone numbers
  static Future<List<String>> getSavedPhones() async {
    final accounts = await getSavedAccounts();
    return accounts.map((account) => account['phone']!).toList();
  }

  // Get all saved passwords
  static Future<List<String>> getSavedPasswords() async {
    final accounts = await getSavedAccounts();
    return accounts.map((account) => account['password']!).toList();
  }

  // Get password for specific phone
  static Future<String?> getPasswordForPhone(String phone) async {
    final accounts = await getSavedAccounts();
    final account = accounts.firstWhere(
      (account) => account['phone'] == phone,
      orElse: () => <String, String>{},
    );
    return account['password'];
  }

  // Remove specific account
  static Future<void> removeAccount(String phone) async {
    try {
      List<Map<String, String>> savedAccounts = await getSavedAccounts();
      savedAccounts.removeWhere((account) => account['phone'] == phone);

      await _storage.write(
        key: _savedAccountsKey,
        value: jsonEncode(savedAccounts),
      );
    } catch (e) {
      print('Error removing account: $e');
    }
  }

  // Clear all saved accounts
  static Future<void> clearAllAccounts() async {
    await _storage.delete(key: _savedAccountsKey);
  }

  static Future<void> removeAuth() async {
    await Future.wait([
      // _storage.delete(key: _phoneKey),
      _storage.delete(key: _tokenKey),
    ]);
  }

  // New method: Remove everything including credentials
  static Future<void> removeAll() async {
    await Future.wait([
      _storage.delete(key: _phoneKey),
      _storage.delete(key: _tokenKey),
      _storage.delete(key: _savedAccountsKey),
    ]);
  }

  static Future<String?> getPhone() async {
    final phone = await _storage.read(key: _phoneKey);

    return phone;
  }

  static Future<String?> getToken() async {
    final token = await _storage.read(key: _tokenKey);
    return token;
  }

  // Check if has any saved accounts
  static Future<bool> hasSavedAccounts() async {
    final accounts = await getSavedAccounts();
    return accounts.isNotEmpty;
  }

  // Get account count
  static Future<int> getAccountCount() async {
    final accounts = await getSavedAccounts();
    return accounts.length;
  }
}
