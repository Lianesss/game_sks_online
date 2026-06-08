import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _phoneCtrl = TextEditingController(text: '+7 900 123 45 67');
  final _codeCtrl = TextEditingController(text: '1234');
  UserRole _selectedRole = UserRole.client;
  bool _codeSent = false;
  bool _loading = false;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _phoneCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  void _sendCode() {
    setState(() {
      _loading = true;
    });
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _loading = false;
          _codeSent = true;
        });
      }
    });
  }

  void _login() {
    setState(() {
      _loading = true;
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        context.read<AppProvider>().login(_phoneCtrl.text, _selectedRole);
        Navigator.of(context).pushReplacementNamed('/home');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: Container(
        color: AppTheme.bgLight,
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 26, vertical: 30),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBg,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.14),
                        blurRadius: 28,
                        offset: const Offset(0, 14),
                      ),
                    ],
                    border: Border.all(
                        color: AppTheme.textPrimary.withValues(alpha: 0.8)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        margin: const EdgeInsets.only(bottom: 18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [AppTheme.accentLight, AppTheme.primary],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                                color: AppTheme.primary.withValues(alpha: 0.25),
                                blurRadius: 16,
                                offset: const Offset(0, 10))
                          ],
                        ),
                        child: const Center(
                            child: Text('SKS',
                                style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary))),
                      ),
                      Text('SKS Quest',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(color: AppTheme.textPrimary)),
                      const SizedBox(height: 8),
                      Text('Геймификация СКС Онлайн',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 30),
                      _RoleSelector(
                          selected: _selectedRole,
                          onChanged: (r) => setState(() => _selectedRole = r)),
                      const SizedBox(height: 28),
                      _InputField(
                          controller: _phoneCtrl,
                          label: 'Номер телефона',
                          icon: Icons.phone,
                          enabled: !_codeSent),
                      if (_codeSent) ...[
                        const SizedBox(height: 16),
                        _InputField(
                            controller: _codeCtrl,
                            label: 'Код из SMS',
                            icon: Icons.lock_outline),
                      ],
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _loading
                              ? null
                              : (_codeSent ? _login : _sendCode),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accent,
                            foregroundColor: AppTheme.textPrimary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18)),
                            elevation: 8,
                            shadowColor: Colors.black26,
                          ),
                          child: _loading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppTheme.textPrimary))
                              : Text(_codeSent ? 'Войти' : 'Получить код',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge
                                      ?.copyWith(color: AppTheme.textPrimary)),
                        ),
                      ),
                      const SizedBox(height: 18),
                      if (!_codeSent)
                        Text('Демо-вход: любой телефон, код 1234',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleSelector extends StatelessWidget {
  final UserRole selected;
  final ValueChanged<UserRole> onChanged;
  const _RoleSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final roles = [
      (UserRole.client, '👤', 'Клиент'),
      (UserRole.marketing, '📊', 'Маркетинг'),
      (UserRole.admin, '🛡️', 'Админ'),
      (UserRole.marketingAnalyst, '📈', 'Аналитик'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Роль (демо)',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        const SizedBox(height: 8),
        Row(
          children: roles.map((r) {
            final (role, emoji, label) = r;
            final isSelected = selected == role;
            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(role),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.accent.withValues(alpha: 0.14)
                        : AppTheme.surface,
                    border: Border.all(
                        color:
                            isSelected ? AppTheme.accent : Colors.transparent,
                        width: 1.5),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                                color: AppTheme.accent.withValues(alpha: 0.1),
                                blurRadius: 12,
                                offset: const Offset(0, 8))
                          ]
                        : [
                            BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 6))
                          ],
                  ),
                  child: Column(
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 2),
                      Text(label,
                          style: TextStyle(
                              fontSize: 9,
                              color: isSelected
                                  ? AppTheme.accent
                                  : AppTheme.textSecondary)),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool enabled;
  const _InputField(
      {required this.controller,
      required this.label,
      required this.icon,
      this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.phone,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: Theme.of(context).textTheme.bodyMedium,
        prefixIcon: Icon(icon, color: AppTheme.accent, size: 20),
        filled: true,
        fillColor: AppTheme.surface,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppTheme.border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppTheme.accent, width: 1.5)),
      ),
    );
  }
}
