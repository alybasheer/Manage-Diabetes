import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();

  SupabaseService._internal();

  factory SupabaseService() {
    return _instance;
  }

  SupabaseClient get _client => Supabase.instance.client;

  // ==================== AUTHENTICATION ====================

  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    try {
      print('📝 Signing up user: $email');
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );
      print('✅ Sign up successful!');
      return response;
    } catch (e) {
      print('❌ Error signing up: $e');
      rethrow;
    }
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      print('🔐 Attempting login with email: $email');
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      print('✅ Login successful! User: ${response.user?.id}');
      return response;
    } on AuthException catch (e) {
      print('❌ Auth error: ${e.message}');

      // Check if error is email_not_confirmed
      if (e.message.contains('Email not confirmed')) {
        print('⚠️ Email not confirmed');
        print(
            '📌 Please confirm your email or manually confirm in Supabase dashboard');
      }
      rethrow;
    } catch (e) {
      print('❌ Error logging in: $e');
      print('📌 Error type: ${e.runtimeType}');
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      print('Error logging out: $e');
      rethrow;
    }
  }

  bool isLoggedIn() {
    return _client.auth.currentUser != null;
  }

  User? getCurrentUser() {
    return _client.auth.currentUser;
  }

  // ==================== USER PROFILE ====================

  Future<void> saveUserProfile({
    required String fullName,
    required String email,
    required String? profileImagePath,
    required String diabetesType,
    required String weight,
    required String height,
    required String gender,
    required String phone,
    required String address,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id ?? 'default_user';

      await _client.from('user_profiles').upsert({
        'user_id': userId,
        'full_name': fullName,
        'email': email,
        'profile_image_path': profileImagePath,
        'diabetes_type': diabetesType,
        'weight': weight,
        'height': height,
        'gender': gender,
        'phone': phone,
        'address': address,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error saving user profile: $e');
    }
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final userId = _client.auth.currentUser?.id ?? 'default_user';

      final response = await _client
          .from('user_profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      return response;
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  Future<void> updateProfileImage(String imagePath) async {
    try {
      final userId = _client.auth.currentUser?.id ?? 'default_user';

      await _client.from('user_profiles').update({
        'profile_image_path': imagePath,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('user_id', userId);
    } catch (e) {
      print('Error updating profile image: $e');
    }
  }

  // ==================== PERSONAL DATA ====================

  Future<void> savePersonalData({
    required String fullName,
    required String dob,
    required String gender,
    required String email,
    required String phone,
    required String address,
    required String diabetesType,
    required String diagnosedSince,
    required String bloodType,
    required String weight,
    required String height,
    required String allergies,
    required String emergencyName,
    required String relationship,
    required String emergencyPhone,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id ?? 'default_user';

      await _client.from('personal_data').upsert({
        'user_id': userId,
        'full_name': fullName,
        'dob': dob,
        'gender': gender,
        'email': email,
        'phone': phone,
        'address': address,
        'diabetes_type': diabetesType,
        'diagnosed_since': diagnosedSince,
        'blood_type': bloodType,
        'weight': weight,
        'height': height,
        'allergies': allergies,
        'emergency_name': emergencyName,
        'relationship': relationship,
        'emergency_phone': emergencyPhone,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error saving personal data: $e');
    }
  }

  Future<Map<String, dynamic>?> getPersonalData() async {
    try {
      final userId = _client.auth.currentUser?.id ?? 'default_user';

      final response = await _client
          .from('personal_data')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      return response;
    } catch (e) {
      print('Error fetching personal data: $e');
      return null;
    }
  }

  // ==================== GLUCOSE READINGS ====================

  Future<void> addGlucoseReading({
    required double value,
    required String timeOfDay,
    required String date,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id ?? 'default_user';

      await _client.from('glucose_readings').insert({
        'user_id': userId,
        'value': value,
        'time_of_day': timeOfDay,
        'date': date,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error adding glucose reading: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getGlucoseReadings() async {
    try {
      final userId = _client.auth.currentUser?.id ?? 'default_user';

      final response = await _client
          .from('glucose_readings')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching glucose readings: $e');
      return [];
    }
  }

  Future<void> deleteGlucoseReading(int id) async {
    try {
      await _client.from('glucose_readings').delete().eq('id', id);
    } catch (e) {
      print('Error deleting glucose reading: $e');
    }
  }

  // ==================== DIET/MEALS ====================

  Future<void> addMeal({
    required String title,
    required String time,
    required String description,
    required String calories,
    required String date,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id ?? 'default_user';
      print('🔍 Adding meal with user_id: $userId');

      await _client.from('diet_meals').insert({
        'user_id': userId,
        'title': title,
        'time': time,
        'description': description,
        'calories': calories,
        'date': date,
        'created_at': DateTime.now().toIso8601String(),
      });

      print('✅ Meal inserted successfully');
    } catch (e) {
      print('❌ Error adding meal: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getMeals() async {
    try {
      final userId = _client.auth.currentUser?.id ?? 'default_user';
      print('🔍 Fetching meals for user_id: $userId');

      final response = await _client
          .from('diet_meals')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      print('✅ Fetched ${response.length} meals: $response');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error fetching meals: $e');
      return [];
    }
  }

  Future<void> deleteMeal(int id) async {
    try {
      await _client.from('diet_meals').delete().eq('id', id);
    } catch (e) {
      print('Error deleting meal: $e');
    }
  }

  // ==================== MEDICATIONS ====================

  Future<void> addMedication({
    required String name,
    required String dosage,
    required String instruction,
    required String time,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id ?? 'default_user';

      await _client.from('medications').insert({
        'user_id': userId,
        'name': name,
        'dosage': dosage,
        'instruction': instruction,
        'time': time,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error adding medication: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getMedications() async {
    try {
      final userId = _client.auth.currentUser?.id ?? 'default_user';

      final response = await _client
          .from('medications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching medications: $e');
      return [];
    }
  }

  Future<void> deleteMedication(int id) async {
    try {
      await _client.from('medications').delete().eq('id', id);
    } catch (e) {
      print('Error deleting medication: $e');
    }
  }

  // ==================== GLUCOSE TARGETS ====================

  Future<void> saveGlucoseTargets({
    required double fastingTarget,
    required double postMealTarget,
    required double hba1cTarget,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id ?? 'default_user';

      await _client.from('glucose_targets').upsert({
        'user_id': userId,
        'fasting_target': fastingTarget,
        'post_meal_target': postMealTarget,
        'hba1c_target': hba1cTarget,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error saving glucose targets: $e');
    }
  }

  Future<Map<String, dynamic>?> getGlucoseTargets() async {
    try {
      final userId = _client.auth.currentUser?.id ?? 'default_user';

      final response = await _client
          .from('glucose_targets')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      return response;
    } catch (e) {
      print('Error fetching glucose targets: $e');
      return null;
    }
  }

  // ==================== MEDICAL HISTORY ====================

  Future<void> saveMedicalHistory({
    required String condition,
    required String diagnosis,
    required String treatment,
    required String date,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id ?? 'default_user';

      await _client.from('medical_history').insert({
        'user_id': userId,
        'condition': condition,
        'diagnosis': diagnosis,
        'treatment': treatment,
        'date': date,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error saving medical history: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getMedicalHistory() async {
    try {
      final userId = _client.auth.currentUser?.id ?? 'default_user';

      final response = await _client
          .from('medical_history')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching medical history: $e');
      return [];
    }
  }

  Future<void> deleteMedicalHistory(int id) async {
    try {
      await _client.from('medical_history').delete().eq('id', id);
    } catch (e) {
      print('Error deleting medical history: $e');
    }
  }
}
