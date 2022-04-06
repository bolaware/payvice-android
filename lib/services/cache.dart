
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Cache {
  static final Cache _singleton = Cache._internal();

  Cache._internal();

  factory Cache() {
    return _singleton;
  }

  final tokenKey = "token_key";

  final firebaseTokenKey = "firebase_token_key";
  final deviceIdKey = "device_id";
  final identifierKey = "identifier";
  final customerDataKey = "customer_data";
  final payviceFriendsKey = "payvice_friends";
  final beneficiariesKey = "beneficiaries_key";
  final activitiesKey = "activities_key";
  final billCategoriesKey = "bill_categories_key";
  final contactListsLengthKey = "contact_lists_length";
  final isBiometricEnabled = "is_Password_encrypted_on_device";
  final shouldShowBalannce = "should_show_balance";
  final passswordEncryptedKey = "passsword_encrypted";
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final storage = new FlutterSecureStorage();

  Future<String> getToken() async {
    final prefs = await _prefs;
    return prefs.getString(tokenKey);
  }

  Future<bool> saveToken(String token) async {
    final prefs = await _prefs;
    return prefs.setString(tokenKey, token);
  }

  Future<int> getContactListLength() async {
    final prefs = await _prefs;
    return prefs.getInt(contactListsLengthKey);
  }

  Future<bool> saveContactListLength(int length) async {
    final prefs = await _prefs;
    return prefs.setInt(contactListsLengthKey, length);
  }

  Future<String> getFirebaseTokenKey() async {
    final prefs = await _prefs;
    return prefs.getString(firebaseTokenKey);
  }

  Future<bool> saveFirebaseTokenKey(String token) async {
    final prefs = await _prefs;
    return prefs.setString(firebaseTokenKey, token);
  }

  Future<String> getIdentifier() async {
    final prefs = await _prefs;
    return prefs.getString(identifierKey);
  }

  Future<bool> saveIdentifier(String identifier) async {
    final prefs = await _prefs;
    return prefs.setString(identifierKey, identifier);
  }

  Future<String> getDeviceId() async {
    final prefs = await _prefs;
    return prefs.getString(deviceIdKey);
  }

  Future<bool> saveDeviceId(String deviceId) async {
    final prefs = await _prefs;
    return prefs.setString(deviceIdKey, deviceId);
  }


  Future<bool> saveCustomerData(String data) async {
    final prefs = await _prefs;
    return prefs.setString(customerDataKey, data);
  }


  Future<String> getCustomerData() async {
    final prefs = await _prefs;
    return prefs.getString(customerDataKey);
  }


  Future<bool> savePayviceFriends(String data) async {
    final prefs = await _prefs;
    return prefs.setString(payviceFriendsKey, data);
  }


  Future<String> getPayviceFriends() async {
    final prefs = await _prefs;
    return prefs.getString(payviceFriendsKey);
  }

  Future<bool> saveBeneficiaries(String data) async {
    final prefs = await _prefs;
    return prefs.setString(beneficiariesKey, data);
  }


  Future<String> getBeneficiaries() async {
    final prefs = await _prefs;
    return prefs.getString(beneficiariesKey);
  }

  Future<bool> saveBillCategories(String data) async {
    final prefs = await _prefs;
    return prefs.setString(billCategoriesKey, data);
  }


  Future<String> getBillCategories() async {
    final prefs = await _prefs;
    return prefs.getString(billCategoriesKey);
  }

  Future<bool> saveActivities(String data) async {
    final prefs = await _prefs;
    return prefs.setString(activitiesKey, data);
  }


  Future<String> getActivities() async {
    final prefs = await _prefs;
    return prefs.getString(activitiesKey);
  }

  Future<bool> getBiometricEnrolled() async {
    final prefs = await _prefs;
    return prefs.getBool(isBiometricEnabled);
  }

  Future<bool> saveBiometricEnrolled(bool _isBiometricEnrolled) async {
    final prefs = await _prefs;
    return prefs.setBool(isBiometricEnabled, _isBiometricEnrolled);
  }


  Future<bool> sholdShowBalanceEnrolled() async {
    final prefs = await _prefs;
    return prefs.getBool(shouldShowBalannce) ?? true;
  }

  Future<bool> saveShouldShowBalanceEnrolled(bool _isBiometricEnrolled) async {
    final prefs = await _prefs;
    return prefs.setBool(shouldShowBalannce, _isBiometricEnrolled);
  }

  Future<String> getPass() async {
    return storage.read(key: passswordEncryptedKey);
  }

  Future<void> savePass(String pass) async {
    await saveBiometricEnrolled(true);
    return storage.write(key: passswordEncryptedKey, value: pass);
  }

  Future<void> clearBiometric() async {
    await saveBiometricEnrolled(false);
    return await storage.deleteAll();
  }


  Future<bool> nuke() async {
    final prefs = await _prefs;
    final identifier = await getIdentifier();
    final isBiometricEnabled = await getBiometricEnrolled();
    final clearValue = prefs.clear();
    await saveIdentifier(identifier);
    await saveBiometricEnrolled(isBiometricEnabled);
    return clearValue;
  }
}