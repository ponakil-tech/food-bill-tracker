import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_bill_tracker/app/providers/auth_provider.dart';
import 'package:food_bill_tracker/src/core/theme/app_colors.dart';
import 'package:food_bill_tracker/src/models/user_model.dart';
import 'package:food_bill_tracker/src/providers/login_controller.dart';
import 'package:food_bill_tracker/src/view/screens/food_list_screen.dart';
import 'package:food_bill_tracker/src/view/screens/signup_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    ref.read(loginControllerProvider.notifier).submit(
          phone: _phoneController.text.trim(),
          password: _passwordController.text,
        );
  }

  void _showSnack(String message, {required bool isError}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: isError ? AppColors.error : AppColors.success,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginControllerProvider);
    final loading = state.isLoading;
    final textTheme = Theme.of(context).textTheme;

    // React to login success / failure exactly once per transition.
    ref.listen<AsyncValue<UserModel?>>(loginControllerProvider,
        (previous, next) {
      next.whenOrNull(
        data: (user) {
          if (user == null) return; // idle
          ref.read(authProvider.notifier).login(user);
          _showSnack('Login successful', isError: false);
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const FoodListScreen()),
          );
        },
        error: (error, _) {
          _showSnack(
            ref.read(loginErrorProvider) ?? 'Login failed',
            isError: true,
          );
        },
      );
    });

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Food Note App",
                    textAlign: TextAlign.center,
                    style: textTheme.headlineMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Container(
                      height: 88,
                      width: 88,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.restaurant,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Track your daily food\nin one place",
                    textAlign: TextAlign.center,
                    style: textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              "Login",
                              style: textTheme.titleLarge?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // ---- Phone ----
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.next,
                              enabled: !loading,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                              decoration: const InputDecoration(
                                hintText: "Enter Phone Number",
                                prefixIcon: Icon(Icons.phone_outlined),
                              ),
                              validator: (value) {
                                final text = value?.trim() ?? '';
                                if (text.isEmpty) return "Enter phone number";
                                if (text.length != 10) {
                                  return "Enter a valid 10-digit number";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // ---- Password ----
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscure,
                              enabled: !loading,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _login(),
                              decoration: InputDecoration(
                                hintText: "Enter Password",
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscure
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () =>
                                      setState(() => _obscure = !_obscure),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Enter password";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              height: 52,
                              child: ElevatedButton.icon(
                                onPressed: loading ? null : _login,
                                icon: loading
                                    ? const SizedBox.shrink()
                                    : const Icon(Icons.login, size: 20),
                                label: loading
                                    ? const SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        "LOGIN",
                                        style: textTheme.labelLarge?.copyWith(
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ---- Create account ----
                  TextButton(
                    onPressed: loading
                        ? null
                        : () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const SignupScreen(),
                              ),
                            );
                          },
                    child:
                        const Text("Don't have an account?  Create Account"),
                  ),
                  const SizedBox(height: 16),

                  // ---- Privacy note ----
                  const Icon(
                    Icons.verified_user,
                    color: AppColors.primary,
                    size: 22,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "All your data is saved\non this device only.",
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
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
