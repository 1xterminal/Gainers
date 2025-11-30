import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gainers/features/dashboard/ui/dashboard_screen.dart';
import 'package:gainers/features/profile/domain/entities/profile.dart';
import 'package:gainers/features/profile/providers/profile_provider.dart';
import 'package:gainers/core/widgets/custom_text_field.dart';
import 'package:gainers/core/widgets/custom_button.dart';
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
    'Gain Muscle',
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> _handleSubmit() async {
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
      final username = user.userMetadata?['username'] as String?;

      final profile = Profile(
        id: user.id,
        username: username,
        displayName: _displayNameController.text,
        gender: _genderController.text,
        dateOfBirth: DateTime.parse(_dobController.text),
        heightCm: int.parse(_heightController.text),
        weightKg: double.parse(_weightController.text),
        activityGoal: _selectedActivityGoal,
        unitPreference: 'metric',
      );

      await ref.read(createProfileProvider)(profile);

      if (!mounted) return;

      navigator.pushReplacement(
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
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
    final theme = Theme.of(context);
    final progress = (_pageIndex + 1) / 6;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: theme.scaffoldBackgroundColor),
        child: SafeArea(
          child: Column(
            children: [
              // --- Header with Progress ---
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: Row(
                  children: [
                    if (_pageIndex > 0)
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: theme.primaryColor,
                        ),
                        onPressed: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.ease,
                          );
                        },
                      )
                    else
                      const SizedBox(width: 48), // Spacer
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: theme.primaryColor.withValues(
                            alpha: 0.2,
                          ),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.primaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '${_pageIndex + 1}/6',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: PageView(
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
                      subtitle: "Let us know what to call you.",
                      formKey: _formKeys[0],
                      child: CustomTextField(
                        controller: _displayNameController,
                        label: 'Display Name',
                        prefixIcon: Icons.person_outline,
                        validator: (value) => value!.isEmpty
                            ? 'Please enter your display name'
                            : null,
                      ),
                    ),
                    _ProfilePage(
                      title: 'What is your gender?',
                      subtitle: "This helps us calculate your metabolic rate.",
                      formKey: _formKeys[1],
                      child: CustomTextField(
                        controller: _genderController,
                        label: 'Gender',
                        prefixIcon: Icons.wc,
                        validator: (value) =>
                            value!.isEmpty ? 'Please enter your gender' : null,
                      ),
                    ),
                    _ProfilePage(
                      title: 'When were you born?',
                      subtitle: "We use this to calculate your age.",
                      formKey: _formKeys[2],
                      child: GestureDetector(
                        onTap: _selectDate,
                        child: AbsorbPointer(
                          child: CustomTextField(
                            controller: _dobController,
                            label: 'Date of Birth',
                            prefixIcon: Icons.calendar_today,
                            validator: (value) => value!.isEmpty
                                ? 'Please enter your date of birth'
                                : null,
                          ),
                        ),
                      ),
                    ),
                    _ProfilePage(
                      title: 'How tall are you?',
                      subtitle: "Height is a key factor in your BMR.",
                      formKey: _formKeys[3],
                      child: CustomTextField(
                        controller: _heightController,
                        label: 'Height (cm)',
                        prefixIcon: Icons.height,
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value!.isEmpty ? 'Please enter your height' : null,
                      ),
                    ),
                    _ProfilePage(
                      title: 'Current weight?',
                      subtitle: "We'll track your progress from here.",
                      formKey: _formKeys[4],
                      child: CustomTextField(
                        controller: _weightController,
                        label: 'Weight (kg)',
                        prefixIcon: Icons.monitor_weight_outlined,
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value!.isEmpty ? 'Please enter your weight' : null,
                      ),
                    ),
                    _ProfilePage(
                      title: 'Primary Goal',
                      subtitle: "What do you want to achieve?",
                      formKey: _formKeys[5],
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedActivityGoal,
                        items: _activityGoals
                            .map(
                              (goal) => DropdownMenuItem(
                                value: goal,
                                child: Text(goal),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedActivityGoal = value;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Select Goal',
                          prefixIcon: Icon(
                            Icons.flag_outlined,
                            color: theme.primaryColor,
                          ),
                          filled: true,
                          fillColor: theme.cardColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: theme.primaryColor,
                              width: 2,
                            ),
                          ),
                        ),
                        validator: (value) =>
                            value == null ? 'Please select a goal' : null,
                      ),
                    ),
                  ],
                ),
              ),

              // --- Bottom Action Button ---
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: PrimaryButton(
                  label: _pageIndex == 5 ? 'COMPLETE SETUP' : 'CONTINUE',
                  onPressed: () {
                    if (_pageIndex < 5) {
                      if (_formKeys[_pageIndex].currentState!.validate()) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.ease,
                        );
                      }
                    } else {
                      _handleSubmit();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfilePage extends StatefulWidget {
  final String title;
  final String subtitle;
  final GlobalKey<FormState> formKey;
  final Widget child;

  const _ProfilePage({
    required this.title,
    required this.subtitle,
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
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.subtitle,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 48),
            widget.child,
          ],
        ),
      ),
    );
  }
}
