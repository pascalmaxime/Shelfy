import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  bool _loading = false;
  String? _error;

  static SupabaseClient get _client => Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _tabs.addListener(() => setState(() => _error = null));
  }

  @override
  void dispose() {
    _tabs.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _client.auth.signInWithPassword(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
      if (mounted) Navigator.of(context).pop();
    } on AuthException catch (e) {
      setState(() => _error = _traduireErreur(e.message));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _register() async {
    if (_passwordCtrl.text != _confirmCtrl.text) {
      setState(() => _error = 'Les mots de passe ne correspondent pas.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _client.auth.signUp(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
      if (mounted) Navigator.of(context).pop();
    } on AuthException catch (e) {
      setState(() => _error = _traduireErreur(e.message));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Entrez votre e-mail pour réinitialiser.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'shelfy://reset-password',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('E-mail de réinitialisation envoyé !'),
        ));
        Navigator.of(context).pop();
      }
    } on AuthException catch (e) {
      setState(() => _error = _traduireErreur(e.message));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    setState(() => _loading = true);
    await _client.auth.signOut();
    if (mounted) Navigator.of(context).pop();
  }

  String _traduireErreur(String msg) {
    if (msg.contains('Invalid login')) return 'Email ou mot de passe incorrect.';
    if (msg.contains('already registered')) return 'Cet email est déjà utilisé.';
    if (msg.contains('password')) return 'Mot de passe trop court (min. 6 caractères).';
    return msg;
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final user = _client.auth.currentUser;
    return user != null ? _buildConnecte(context, user) : _buildForms(context);
  }

  // ── État connecté ──────────────────────────────────────────────────────────

  Widget _buildConnecte(BuildContext context, User user) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_circle),
              const SizedBox(width: 12),
              Text('Mon compte',
                  style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: cs.primaryContainer,
                  child: Icon(Icons.person, color: cs.onPrimaryContainer),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.email ?? '',
                          style: Theme.of(context).textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis),
                      Text('Connecté',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              )),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: _loading ? null : _logout,
            icon: _loading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.logout),
            label: const Text('Se déconnecter'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
          ),
        ],
      ),
    );
  }

  // ── Formulaires connexion / inscription ────────────────────────────────────

  Widget _buildForms(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
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
          tabs: const [Tab(text: 'Connexion'), Tab(text: 'Inscription')],
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Row(
              children: [
                Icon(Icons.error_outline, size: 16, color: cs.error),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _error!,
                    style: TextStyle(color: cs.error, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        SizedBox(
          height: 280,
          child: TabBarView(
            controller: _tabs,
            children: [_loginForm(), _registerForm()],
          ),
        ),
        SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
      ],
    );
  }

  // ── Champs réutilisables ───────────────────────────────────────────────────

  Widget _emailField() => TextField(
        controller: _emailCtrl,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          labelText: 'Adresse e-mail',
          prefixIcon: const Icon(Icons.email_outlined),
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
            icon: Icon(obscure
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined),
            onPressed: toggle,
          ),
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

  Widget _submitButton(String label, VoidCallback onPressed) => FilledButton(
        onPressed: _loading ? null : onPressed,
        style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(48)),
        child: _loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2,
                    color: Colors.white))
            : Text(label),
      );

  // ── Onglet Connexion ──────────────────────────────────────────────────────

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
                onPressed: _resetPassword,
                child: const Text('Mot de passe oublié ?'),
              ),
            ),
            const SizedBox(height: 4),
            _submitButton('Se connecter', _login),
          ],
        ),
      );

  // ── Onglet Inscription ────────────────────────────────────────────────────

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
            _submitButton("S'inscrire", _register),
          ],
        ),
      );
}
