import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gainers/core/widgets/custom_button.dart';
import 'package:gainers/core/widgets/custom_text_field.dart';
import 'package:gainers/features/auth/providers/auth_provider.dart';
import 'package:gainers/features/profile/ui/profile_setup_screen.dart';
import 'package:gainers/features/auth/ui/email_confirmation_screen.dart';
import 'package:gainers/layout/main_layout.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  bool _isLogin = true;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your email';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Please enter a valid email';
    return null;
  }

  String? _validateUsername(String? value) {
    if (_isLogin) return null;
    if (value == null || value.isEmpty) return 'Please enter a username';
    if (value.length < 3) return 'Username must be at least 3 characters';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your password';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final authNotifier = ref.read(authNotifierProvider.notifier);

    if (_isLogin) {
      await authNotifier.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
    } else {
      await authNotifier.register(
        _emailController.text.trim(),
        _passwordController.text,
        _usernameController.text.trim(),
      );
    }

    if (ref.read(authNotifierProvider).hasError) return;

    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            _isLogin ? 'Login successful!' : 'Registration successful!',
          ),
          backgroundColor: Colors.green,
        ),
      );

    if (!_isLogin) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              EmailConfirmationScreen(email: _emailController.text.trim()),
        ),
      );
    }
  }

  Future<void> _showForgotPasswordDialog() async {
    final emailController = TextEditingController();
    final dialogFormKey = GlobalKey<FormState>();
    bool isLoading = false;

    return showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Reset Password'),
          content: Form(
            key: dialogFormKey,
            child: CustomTextField(
              controller: emailController,
              label: 'Email',
              hint: 'Enter your email',
              prefixIcon: Icons.email_outlined,
              validator: _validateEmail,
              keyboardType: TextInputType.emailAddress,
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (dialogFormKey.currentState!.validate()) {
                        setState(() => isLoading = true);
                        try {
                          await ref
                              .read(authNotifierProvider.notifier)
                              .resetPasswordRequest(
                                emailController.text.trim(),
                              );

                          if (!mounted || !dialogContext.mounted) return;

                          Navigator.pop(dialogContext);
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              const SnackBar(
                                content: Text('Password reset email sent!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              SnackBar(
                                content: Text(e.toString()),
                                backgroundColor: Colors.red,
                              ),
                            );
                        } finally {
                          if (mounted) {
                            setState(() => isLoading = false);
                          }
                        }
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Send Reset Link'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authNotifierProvider, (previous, next) {
      if (next is AsyncError) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(next.error.toString()),
              backgroundColor: Colors.red,
            ),
          );
      }

      if (next is AsyncData && next.value?.isAuthenticated == true) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                _isLogin ? 'Login successful!' : 'Registration successful!',
              ),
              backgroundColor: Colors.green,
            ),
          );

        if (next.value?.isProfileComplete == true) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainLayout()),
          );
        } else if (_isLogin) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const ProfileSetupScreen()),
          );
        }
      }
    });

    final authState = ref.watch(authNotifierProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- Header ---
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SvgPicture.asset(
                      'images/Logo-Gainers.svg',
                      height: 40,
                      colorFilter: ColorFilter.mode(
                        Colors.grey,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _isLogin ? 'Welcome\nBack' : 'Create an\nAccount',
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // --- Inputs ---
                  if (!_isLogin) ...[
                    CustomTextField(
                      controller: _usernameController,
                      label: 'Username',
                      hint: 'Choose a username',
                      prefixIcon: Icons.person_outline,
                      validator: _validateUsername,
                      enabled: !authState.isLoading,
                    ),
                    const SizedBox(height: 16),
                  ],

                  CustomTextField(
                    controller: _emailController,
                    label: 'Email',
                    hint: 'Enter your email',
                    prefixIcon: Icons.email_outlined,
                    validator: _validateEmail,
                    keyboardType: TextInputType.emailAddress,
                    enabled: !authState.isLoading,
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: _passwordController,
                    label: 'Password',
                    hint: 'Enter your password',
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    validator: _validatePassword,
                    enabled: !authState.isLoading,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  if (_isLogin)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: authState.isLoading
                            ? null
                            : _showForgotPasswordDialog,
                        child: const Text('Forgot Password?'),
                      ),
                    ),

                  const SizedBox(height: 32),

                  // --- Buttons ---
                  PrimaryButton(
                    label: _isLogin ? 'Login' : 'Register',
                    isLoading: authState.isLoading,
                    onPressed: _handleSubmit,
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: isDark ? Colors.white24 : Colors.black12,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'or',
                          style: TextStyle(
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: isDark ? Colors.white24 : Colors.black12,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  GoogleSignInButton(
                    isLoading: authState.isLoading,
                    onPressed: () {
                      ref
                          .read(authNotifierProvider.notifier)
                          .signInWithGoogle();
                    },
                  ),

                  const SizedBox(height: 32),

                  // --- Toggle ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isLogin
                            ? "Don't have an account? "
                            : 'Already have an account? ',
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      GestureDetector(
                        onTap: authState.isLoading
                            ? null
                            : () {
                                setState(() {
                                  _isLogin = !_isLogin;
                                  _formKey.currentState?.reset();
                                });
                              },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : const Color(0xFFE0C9BC), // Light brown/beige
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _isLogin ? 'Register Here' : 'Login here',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF5D4037),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
