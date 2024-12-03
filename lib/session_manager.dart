import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionManager
{
  final storage = const FlutterSecureStorage();

  Future<bool> isLoggedIn() async //Checks if the user has a login token
  {
    String? token = await storage.read(key: 'auth_token'); //Try to read the session token from storage.
    return token != null; //If it exists, return true
  }

  Future<void> login(String token) async //When user logs in, add the session token to secure storage to remember them
  {
    await storage.write(key: 'auth_token', value: token);
  }

  Future<void> logout() async //Remove the users token on logout
  {
    await storage.delete(key: 'auth_token');
  }
}