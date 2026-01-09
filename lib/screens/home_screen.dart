import 'dart:io';

import 'package:flutter/material.dart';

import '../services/supabase_service.dart';
import '../utils/theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String fullName = "User";
  String? profileImagePath;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final supabase = SupabaseService();
    final profile = await supabase.getUserProfile();

    setState(() {
      fullName = profile?['full_name'] ?? "User";
      profileImagePath = profile?['profile_image_path'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.pastelBlue.withOpacity(0.4),
              AppTheme.backgroundLavender.withOpacity(0.5),
              AppTheme.lavenderMuted.withOpacity(0.6),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Column(
          children: [
            // Enhanced App Bar with Profile Section - Elevated Card with Gradient
            Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              padding: const EdgeInsets.only(
                  top: 24, left: 20, right: 20, bottom: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primary,
                    AppTheme.primaryDark.withOpacity(0.1),
                  ],
                ),
                borderRadius: const BorderRadius.all(Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 500),
                            opacity: 1.0,
                            child: Text(
                              'Welcome,',
                              style: TextStyle(
                                color: AppTheme.primaryLight,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.1),
                                    offset: const Offset(0, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Text(
                            fullName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/profile')
                            .then((_) => _loadUserData()),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 28,
                            backgroundColor: AppTheme.cardWhite,
                            backgroundImage: profileImagePath != null
                                ? FileImage(File(profileImagePath!))
                                : null,
                            child: profileImagePath == null
                                ? Icon(Icons.person,
                                    color: AppTheme.primary, size: 32)
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 18, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.cardWhite,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildQuickStat(
                            'Blood Sugar', '120 mg/dL', AppTheme.alert),
                        _buildDivider(),
                        _buildQuickStat('HbA1c', '6.5%', AppTheme.primary),
                        _buildDivider(),
                        _buildQuickStat('BMI', '22.5', AppTheme.success),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Enhanced Main Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Main Features',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                      children: [
                        _buildFeatureCard(
                          'Glucose',
                          Icons.speed,
                          'Monitor blood sugar',
                          AppTheme.alert,
                          () => Navigator.pushNamed(context, '/glucose'),
                        ),
                        _buildFeatureCard(
                          'Diet',
                          Icons.restaurant,
                          'Meal planner',
                          AppTheme.success,
                          () => Navigator.pushNamed(context, '/diet'),
                        ),
                        _buildFeatureCard(
                          'Medication',
                          Icons.medication,
                          'Medication reminders',
                          AppTheme.primary,
                          () => Navigator.pushNamed(context, '/medication'),
                        ),
                        _buildFeatureCard(
                          'Reports',
                          Icons.insert_chart,
                          'Health analysis',
                          AppTheme.primaryLight,
                          () => Navigator.pushNamed(context, '/reports'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    _buildTipsSection(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey.withOpacity(0.2),
    );
  }

  Widget _buildQuickStat(String label, String value, Color accentColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: accentColor.withOpacity(0.2), width: 1.5),
          borderRadius: BorderRadius.circular(12),
          color: accentColor.withOpacity(0.05),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: accentColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(String title, IconData icon, String description,
      Color accentColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.cardWhite,
              AppTheme.cardOffWhite,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.borderLight, width: 1),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.12),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: accentColor),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsSection(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/tips'),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primary.withOpacity(0.12),
              AppTheme.primary.withOpacity(0.06),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.primary.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.lightbulb_outline,
                  color: AppTheme.primary, size: 24),
            ),
            const SizedBox(width: 15),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tips & Articles',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    'Read the latest health articles',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.primary),
          ],
        ),
      ),
    );
  }
}
