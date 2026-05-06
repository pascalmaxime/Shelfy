import 'package:flutter/material.dart';

class AuthSheet extends StatefulWidget {
  const AuthSheet({super.key});

  @override
  State<AuthSheet> createState() => _AuthSheetState();
}

class _AuthSheetState extends State<AuthSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Widget _emailField() => TextField(
        controller: _emailCtrl,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          labelText: 'Adresse e-mail',
          prefixIcon: const Icon(Icons.email_outlined),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

  Widget _passwordField(
    TextEditingController ctrl,
    bool obscure,
    VoidCallback toggle, {
    String label = 'Mot de passe',
  }) =>
      TextField(
        controller: ctrl,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.lock_outlined),
          suffixIcon: IconButton(
            icon: Icon(
              obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            ),
            onPressed: toggle,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

  Widget _loginForm() => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 8),
            _emailField(),
            const SizedBox(height: 12),
            _passwordField(
              _passwordCtrl,
              _obscurePass,
              () => setState(() => _obscurePass = !_obscurePass),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: const Text('Mot de passe oublié ?'),
              ),
            ),
            const SizedBox(height: 4),
            FilledButton(
              onPressed: () {},
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('Se connecter'),
            ),
          ],
        ),
      );

  Widget _registerForm() => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 8),
            _emailField(),
            const SizedBox(height: 12),
            _passwordField(
              _passwordCtrl,
              _obscurePass,
              () => setState(() => _obscurePass = !_obscurePass),
            ),
            const SizedBox(height: 12),
            _passwordField(
              _confirmCtrl,
              _obscureConfirm,
              () => setState(() => _obscureConfirm = !_obscureConfirm),
              label: 'Confirmer le mot de passe',
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {},
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text("S'inscrire"),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Row(
            children: [
              const Icon(Icons.account_circle_outlined),
              const SizedBox(width: 12),
              Text('Mon compte',
                  style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
        ),
        const SizedBox(height: 12),
        TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'Connexion'),
            Tab(text: 'Inscription'),
          ],
        ),
        SizedBox(
          height: 300,
          child: TabBarView(
            controller: _tabs,
            children: [_loginForm(), _registerForm()],
          ),
        ),
        SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
      ],
    );
  }
}
