import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../screens/glucose_target_screen.dart';
import '../screens/help_screen.dart';
import '../screens/medical_history_screen.dart';
import '../screens/personal_data_screen.dart';
import '../screens/settings_screen.dart';
import '../services/supabase_service.dart';
import '../utils/theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String fullName = "Ali";
  String diabetesType = "Type 1 Diabetes";
  String weight = "75 kg";
  String height = "170 cm";
  String age = "30 yrs";
  String? profileImagePath;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final supabase = SupabaseService();
    final profile = await supabase.getUserProfile();

    setState(() {
      fullName = profile?['full_name'] ?? "User";
      diabetesType = profile?['diabetes_type'] ?? "Type 2 Diabetes";
      weight = profile?['weight'] ?? "75 kg";
      height = profile?['height'] ?? "170 cm";
      profileImagePath = profile?['profile_image_path'];

      // Calculate age if DOB is in personal_data
      String? dob = profile?['dob'];
      if (dob != null) {
        try {
          DateTime birthDate = DateTime.tryParse(dob) ?? DateTime(1990, 1, 15);
          int calculatedAge = DateTime.now().year - birthDate.year;
          age = "$calculatedAge yrs";
        } catch (e) {
          age = "30 yrs";
        }
      }
    });
  }

  Future<void> _pickProfileImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final supabase = SupabaseService();
      await supabase.updateProfileImage(image.path);
      setState(() {
        profileImagePath = image.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text('Profile'),
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.cardWhite,
      ),
      backgroundColor: AppTheme.backgroundLavender,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            _buildQuickStats(),
            _buildMenuSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 60, bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primary,
            AppTheme.primaryDark.withOpacity(0.9),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: AppTheme.cardWhite,
                backgroundImage: profileImagePath != null
                    ? FileImage(File(profileImagePath!))
                    : null,
                child: profileImagePath == null
                    ? Icon(Icons.person, size: 50, color: AppTheme.primary)
                    : null,
              ),
              GestureDetector(
                onTap: _pickProfileImage,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.cardWhite,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.primary, width: 2),
                  ),
                  child: Icon(Icons.edit, size: 20, color: AppTheme.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            fullName,
            style: const TextStyle(
              color: AppTheme.cardWhite,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.cardWhite.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              diabetesType,
              style: const TextStyle(color: AppTheme.cardWhite, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatCard('Weight', weight, Icons.monitor_weight),
          _buildStatCard('Height', height, Icons.height),
          _buildStatCard('Age', age, Icons.calendar_today),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.12),
            spreadRadius: 1,
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primary, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Column(
      children: [
        _buildMenuItem(
          context,
          'Personal Data',
          Icons.person_outline,
          'Manage your personal information',
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PersonalDataScreen()),
          ).then((_) => _loadProfileData()), // refresh after returning
        ),
        _buildMenuItem(
          context,
          'Medical History',
          Icons.history,
          'View your medical records',
          () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const MedicalHistoryScreen()),
          ),
        ),
        _buildMenuItem(
          context,
          'Glucose Targets',
          Icons.track_changes,
          'Set your blood glucose targets',
          () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const GlucoseTargetScreen()),
          ),
        ),
        _buildMenuItem(
          context,
          'Settings',
          Icons.settings,
          'Configure the app',
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SettingsScreen()),
          ),
        ),
        _buildMenuItem(
          context,
          'Help',
          Icons.help_outline,
          'Help center',
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HelpScreen()),
          ),
        ),
        const SizedBox(height: 20),
        _buildLogoutButton(context),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, IconData icon,
      String subtitle, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.12),
            spreadRadius: 1,
            blurRadius: 8,
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppTheme.primary),
        ),
        title: Text(title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary)),
        subtitle: Text(subtitle,
            style:
                const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        trailing: Icon(Icons.chevron_right, color: AppTheme.borderLight),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton.icon(
        onPressed: () async {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Logout'),
                content: const Text('Are you sure you want to logout?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () async {
                      try {
                        await SupabaseService().logout();
                        if (context.mounted) {
                          Navigator.pushNamedAndRemoveUntil(
                              context, '/login', (route) => false);
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Logout failed: $e')),
                          );
                        }
                      }
                    },
                    child: const Text('Logout',
                        style: TextStyle(color: Colors.red)),
                  ),
                ],
              );
            },
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.alert.withOpacity(0.15),
          foregroundColor: AppTheme.alert,
          padding: const EdgeInsets.symmetric(vertical: 15),
          minimumSize: const Size(double.infinity, 50),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        icon: const Icon(Icons.logout),
        label: const Text('Logout',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
