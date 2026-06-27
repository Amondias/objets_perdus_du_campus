import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_config.dart';
import '../../providers/auth_provider.dart';

/// Minimal login screen required by [main.dart].
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _showSignup = false;

  // Signup fields
  final _nameCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppConfig.surfaceColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  Text(
                    'Objets Perdus du Campus',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Card(
                    elevation: 0,
                    color: AppConfig.cardColor,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (_showSignup)
                              TextFormField(
                                controller: _nameCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Nom',
                                  hintText: 'Votre nom',
                                ),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Nom requis.';
                                  }
                                  return null;
                                },
                              ),
                            if (_showSignup) const SizedBox(height: 12),
                            TextFormField(
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                hintText: 'email@exemple.com',
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Email requis.';
                                }
                                if (!v.contains('@')) {
                                  return 'Email invalide.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _passwordCtrl,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'Mot de passe',
                              ),
                              validator: (v) {
                                if (v == null || v.trim().length < 6) {
                                  return 'Min. 6 caractères.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            if (auth.error != null) ...[
                              Text(
                                auth.error!,
                                style: const TextStyle(color: Colors.redAccent),
                              ),
                              const SizedBox(height: 12),
                            ],

                            SizedBox(
                              height: 48,
                              child: ElevatedButton(
                                onPressed: auth.isLoading
                                    ? null
                                    : () async {
                                        auth.clearError();
                                        if (!_formKey.currentState!.validate()) {
                                          return;
                                        }

                                        final email = _emailCtrl.text.trim();
                                        final password = _passwordCtrl.text;

                                        final ok = _showSignup
                                            ? await auth.signUp(
                                                name: _nameCtrl.text.trim(),
                                                email: email,
                                                password: password,
                                              )
                                            : await auth.signIn(email, password);

                                        if (!ok && mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Connexion impossible.'),
                                            ),
                                          );
                                        }
                                      },
                                child: auth.isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      )
                                    : Text(_showSignup ? 'Créer un compte' : 'Se connecter'),
                              ),
                            ),

                            const SizedBox(height: 12),

                            TextButton(
                              onPressed: auth.isLoading
                                  ? null
                                  : () {
                                      setState(() => _showSignup = !_showSignup);
                                      auth.clearError();
                                    },
                              child: Text(
                                _showSignup
                                    ? 'J’ai déjà un compte'
                                    : 'Créer un compte',
                              ),
                            ),

                            TextButton(
                              onPressed: auth.isLoading
                                  ? null
                                  : () async {
                                      auth.clearError();
                                      final email = _emailCtrl.text.trim();
                                      if (email.isEmpty) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Renseignez votre email d’abord.')),
                                        );
                                        return;
                                      }
                                      final ok = await auth.resetPassword(email);
                                      if (!ok && mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Reset impossible.')),
                                        );
                                      }
                                    },
                              child: const Text('Mot de passe oublié ?'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Firebase requiert une config valide (google-services + Firestore).',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
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

