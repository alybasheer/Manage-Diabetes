import 'package:flutter/material.dart';

import '../services/supabase_service.dart';
import '../utils/theme.dart';

class PersonalDataScreen extends StatefulWidget {
  const PersonalDataScreen({super.key});

  @override
  State<PersonalDataScreen> createState() => _PersonalDataScreenState();
}

class _PersonalDataScreenState extends State<PersonalDataScreen> {
  // Controllers for form fields
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  final TextEditingController _diabetesTypeController = TextEditingController();
  final TextEditingController _diagnosedSinceController =
      TextEditingController();
  final TextEditingController _bloodTypeController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _allergiesController = TextEditingController();

  final TextEditingController _emergencyNameController =
      TextEditingController();
  final TextEditingController _relationshipController = TextEditingController();
  final TextEditingController _emergencyPhoneController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDataFromPrefs();
  }

  Future<void> _loadDataFromPrefs() async {
    final supabase = SupabaseService();
    final personalData = await supabase.getPersonalData();

    if (personalData != null) {
      _fullNameController.text = personalData['full_name'] ?? "User";
      _dobController.text = personalData['dob'] ?? "January 15, 1990";
      _genderController.text = personalData['gender'] ?? "Male";
      _emailController.text = personalData['email'] ?? "User@email.com";
      _phoneController.text = personalData['phone'] ?? "+62 812-3456-7890";
      _addressController.text = personalData['address'] ?? "Jl. Sudirman No.";

      _diabetesTypeController.text = personalData['diabetes_type'] ?? "Type 2";
      _diagnosedSinceController.text =
          personalData['diagnosed_since'] ?? "January 2020";
      _bloodTypeController.text = personalData['blood_type'] ?? "B+";
      _weightController.text = personalData['weight'] ?? "75 kg";
      _heightController.text = personalData['height'] ?? "175 cm";
      _allergiesController.text = personalData['allergies'] ?? "None";

      _emergencyNameController.text =
          personalData['emergency_name'] ?? "Sarah Wijaya";
      _relationshipController.text = personalData['relationship'] ?? "Wife";
      _emergencyPhoneController.text =
          personalData['emergency_phone'] ?? "+62 812-9876-5432";
    }

    setState(() {});
  }

  Future<void> _saveDataToPrefs() async {
    final supabase = SupabaseService();

    await supabase.savePersonalData(
      fullName: _fullNameController.text,
      dob: _dobController.text,
      gender: _genderController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      address: _addressController.text,
      diabetesType: _diabetesTypeController.text,
      diagnosedSince: _diagnosedSinceController.text,
      bloodType: _bloodTypeController.text,
      weight: _weightController.text,
      height: _heightController.text,
      allergies: _allergiesController.text,
      emergencyName: _emergencyNameController.text,
      relationship: _relationshipController.text,
      emergencyPhone: _emergencyPhoneController.text,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Data saved successfully")),
    );

    setState(() {});
  }

  void _showEditForm() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text("Edit Personal Data",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),

                // Personal Info
                TextField(
                    controller: _fullNameController,
                    decoration: const InputDecoration(labelText: "Full Name")),
                TextField(
                    controller: _dobController,
                    decoration:
                        const InputDecoration(labelText: "Date of Birth")),
                TextField(
                    controller: _genderController,
                    decoration: const InputDecoration(labelText: "Gender")),
                TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: "Email")),
                TextField(
                    controller: _phoneController,
                    decoration:
                        const InputDecoration(labelText: "Phone Number")),
                TextField(
                    controller: _addressController,
                    decoration: const InputDecoration(labelText: "Address")),

                const SizedBox(height: 10),

                // Medical Info
                TextField(
                    controller: _diabetesTypeController,
                    decoration:
                        const InputDecoration(labelText: "Diabetes Type")),
                TextField(
                    controller: _diagnosedSinceController,
                    decoration:
                        const InputDecoration(labelText: "Diagnosed Since")),
                TextField(
                    controller: _bloodTypeController,
                    decoration: const InputDecoration(labelText: "Blood Type")),
                TextField(
                    controller: _weightController,
                    decoration: const InputDecoration(labelText: "Weight")),
                TextField(
                    controller: _heightController,
                    decoration: const InputDecoration(labelText: "Height")),
                TextField(
                    controller: _allergiesController,
                    decoration: const InputDecoration(labelText: "Allergies")),

                const SizedBox(height: 10),

                // Emergency Contact
                TextField(
                    controller: _emergencyNameController,
                    decoration:
                        const InputDecoration(labelText: "Emergency Name")),
                TextField(
                    controller: _relationshipController,
                    decoration:
                        const InputDecoration(labelText: "Relationship")),
                TextField(
                    controller: _emergencyPhoneController,
                    decoration:
                        const InputDecoration(labelText: "Emergency Phone")),

                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _saveDataToPrefs();
                    Navigator.pop(context);
                  },
                  child: const Text("Save"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Personal Data",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: AppTheme.primaryRed),
            onPressed: _showEditForm,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            _buildPersonalInfoSection(),
            _buildMedicalInfoSection(),
            _buildEmergencyContactSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppTheme.primaryRed.withOpacity(0.1),
            child: Icon(Icons.person, size: 50, color: AppTheme.primaryRed),
          ),
          const SizedBox(height: 15),
          Text(
            _fullNameController.text,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "ID: DM-2024-001",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return _buildSection("Personal Information", [
      _buildInfoItem("Full Name", _fullNameController.text),
      _buildInfoItem("Date of Birth", _dobController.text),
      _buildInfoItem("Gender", _genderController.text),
      _buildInfoItem("Email", _emailController.text),
      _buildInfoItem("Phone Number", _phoneController.text),
      _buildInfoItem("Address", _addressController.text),
    ]);
  }

  Widget _buildMedicalInfoSection() {
    return _buildSection("Medical Information", [
      _buildInfoItem("Diabetes Type", _diabetesTypeController.text),
      _buildInfoItem("Diagnosed Since", _diagnosedSinceController.text),
      _buildInfoItem("Blood Type", _bloodTypeController.text),
      _buildInfoItem("Weight", _weightController.text),
      _buildInfoItem("Height", _heightController.text),
      _buildInfoItem("Allergies", _allergiesController.text),
    ]);
  }

  Widget _buildEmergencyContactSection() {
    return _buildSection("Emergency Contact", [
      _buildInfoItem("Name", _emergencyNameController.text),
      _buildInfoItem("Relationship", _relationshipController.text),
      _buildInfoItem("Phone Number", _emergencyPhoneController.text),
    ]);
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[600], fontSize: 16)),
          Text(value,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
