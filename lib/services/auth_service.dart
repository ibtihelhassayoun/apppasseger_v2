import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Sign up user with email, password, CIN, and other details
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String cin,
    required String fullName,
    required String phone,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'cin': cin,
        'phone': phone,
      },
    );

    // After signup, we need to create the profile entry
    if (response.user != null) {
      await _client.from('profiles').insert({
        'id': response.user!.id,
        'cin': cin,
        'email': email,
        'full_name': fullName,
        'phone': phone,
      });
    }

    return response;
  }

  /// Sign in user using CIN and password
  Future<AuthResponse> signInWithCin({
    required String cin,
    required String password,
  }) async {
    final data = await _client
        .from('profiles')
        .select('email')
        .eq('cin', cin)
        .maybeSingle();

    if (data == null) {
      throw Exception('Aucun compte trouvé avec ce CIN.');
    }

    final email = data['email'] as String;

    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Get email by CIN
  Future<String?> getEmailByCin(String cin) async {
    final data = await _client
        .from('profiles')
        .select('email')
        .eq('cin', cin)
        .maybeSingle();
    
    return data?['email'] as String?;
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  /// Sign out
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Get current user profile data
  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = currentUser;
    if (user == null) return null;

    final data = await _client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();
    
    return data;
  }

  /// Get current user session
  Session? get currentSession => _client.auth.currentSession;
  User? get currentUser => _client.auth.currentUser;
}
