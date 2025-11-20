import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// REMOVED: import 'package:gainers/features/auth/providers/auth_provider.dart'; 
import 'package:gainers/features/dashboard/ui/dashboard_screen.dart';
import 'package:gainers/features/profile/domain/entities/profile.dart';
import 'package:gainers/features/profile/providers/profile_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _pageController = PageController();
  final _formKeys = List.generate(6, (_) => GlobalKey<FormState>());

  final _displayNameController = TextEditingController();
  final _genderController = TextEditingController();
  final _dobController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  String? _selectedActivityGoal;
  final List<String> _activityGoals = [
    'Lose Weight',
    'Maintain Weight',
    'Gain Muscle'
  ];

  int _pageIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    _displayNameController.dispose();
    _genderController.dispose();
    _dobController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> _handleSubmit() async {
    // 1. Validate the current page (Goal selection)
    if (!_formKeys[_pageIndex].currentState!.validate()) {
      return;
    }

    final user = Supabase.instance.client.auth.currentUser;
    
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No authenticated user found')),
      );
      return;
    }

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      // 2. Create Profile
      // NOTE: We retrieve 'username' from metadata so it doesn't get saved as NULL
      final username = user.userMetadata?['username'] as String?;

      final profile = Profile(
        id: user.id,
        username: username, // Include this to preserve the username
        displayName: _displayNameController.text,
        gender: _genderController.text,
        dateOfBirth: DateTime.parse(_dobController.text), // Will crash if empty (fixed by disabling swipe)
        heightCm: int.parse(_heightController.text),      // Will crash if empty (fixed by disabling swipe)
        weightKg: double.parse(_weightController.text),   // Will crash if empty (fixed by disabling swipe)
        activityGoal: _selectedActivityGoal,
        unitPreference: 'metric',
      );

      await ref.read(createProfileProvider)(profile);

      if (!mounted) return;
      
      navigator.pushReplacement(
        MaterialPageRoute(
          builder: (context) => const DashboardScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Error saving profile: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Your Profile'),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              // FIX: Disable swiping so users MUST use buttons and pass validation
              physics: const NeverScrollableScrollPhysics(), 
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _pageIndex = index;
                });
              },
              children: [
                _ProfilePage(
                  title: "What's your name?",
                  formKey: _formKeys[0],
                  child: TextFormField(
                    controller: _displayNameController,
                    decoration:
                        const InputDecoration(labelText: 'Display Name'),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter your display name' : null,
                  ),
                ),
                _ProfilePage(
                  title: 'What are you?',
                  formKey: _formKeys[1],
                  child: TextFormField(
                    controller: _genderController,
                    decoration: const InputDecoration(labelText: 'Gender'),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter your gender' : null,
                  ),
                ),
                _ProfilePage(
                  title: 'When were you born?',
                  formKey: _formKeys[2],
                  child: TextFormField(
                    controller: _dobController,
                    decoration: const InputDecoration(
                      labelText: 'Date of Birth',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: _selectDate,
                    validator: (value) => value!.isEmpty
                        ? 'Please enter your date of birth'
                        : null,
                  ),
                ),
                _ProfilePage(
                  title: 'How tall are you?',
                  formKey: _formKeys[3],
                  child: TextFormField(
                    controller: _heightController,
                    decoration: const InputDecoration(labelText: 'Height (cm)'),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter your height' : null,
                  ),
                ),
                _ProfilePage(
                  title: 'What is your current weight?',
                  formKey: _formKeys[4],
                  child: TextFormField(
                    controller: _weightController,
                    decoration: const InputDecoration(labelText: 'Weight (kg)'),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter your weight' : null,
                  ),
                ),
                _ProfilePage(
                  title: 'What is your primary goal?',
                  formKey: _formKeys[5],
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedActivityGoal,
                    items: _activityGoals
                        .map((goal) =>
                            DropdownMenuItem(value: goal, child: Text(goal)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedActivityGoal = value;
                      });
                    },
                    decoration:
                        const InputDecoration(labelText: 'Primary Goal'),
                    validator: (value) =>
                        value == null ? 'Please select a goal' : null,
                  ),
                ),
              ],
            ),
          ),
          _buildNavigation(),
        ],
      ),
    );
  }

  Widget _buildNavigation() {
    final isLastPage = _pageIndex == 5;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_pageIndex > 0)
            TextButton.icon(
              onPressed: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.ease,
                );
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Previous'),
            )
          else
            const SizedBox(width: 80),
          if (!isLastPage)
            TextButton.icon(
              onPressed: () {
                if (_formKeys[_pageIndex].currentState!.validate()) {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.ease,
                  );
                }
              },
              label: const Text('Next'),
              icon: const Icon(Icons.arrow_forward),
            ),
          if (isLastPage)
            ElevatedButton(
              onPressed: _handleSubmit,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text('Start Journey'),
            ),
        ],
      ),
    );
  }
}

class _ProfilePage extends StatefulWidget {
  final String title;
  final GlobalKey<FormState> formKey;
  final Widget child;

  const _ProfilePage({
    required this.title,
    required this.formKey,
    required this.child,
  });

  @override
  State<_ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<_ProfilePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Form(
      key: widget.formKey,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 32),
            widget.child,
          ],
        ),
      ),
    );
  }
}