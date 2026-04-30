import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'design_preset.dart';

/// Modern, responsive, monochrome profile page.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.preset});

  final DesignPreset preset;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _currentPasswordController;
  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmPasswordController;
  bool _isEditing = false;
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _biometricLogin = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Esma Kocabas');
    _emailController = TextEditingController(text: 'esma@akillifinans.app');
    _phoneController = TextEditingController(text: '905551112233');
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    const surface = Colors.white;
    const background = Color(0xFFF5F5F5);
    const titleColor = Colors.black;
    const subtitleColor = Color(0xFF616161);

    return Container(
      color: background,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;
            final sidePadding = isWide ? 28.0 : 16.0;

            return ListView(
              padding: EdgeInsets.fromLTRB(sidePadding, 16, sidePadding, 28),
              children: [
                const Text(
                  'Kullanıcı Profili',
                  style: TextStyle(
                    color: titleColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Hesap bilgilerini yönet, güvenlik ve bildirim ayarlarını güncelle.',
                  style: TextStyle(color: subtitleColor),
                ),
                const SizedBox(height: 16),
                _buildProfileHeader(colors),
                const SizedBox(height: 16),
                isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildAccountCard(colors)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildPreferencesCard(colors)),
                        ],
                      )
                    : Column(
                        children: [
                          _buildAccountCard(colors),
                          const SizedBox(height: 12),
                          _buildPreferencesCard(colors),
                        ],
                      ),
                const SizedBox(height: 12),
                _buildActionsCard(colors),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.black,
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _nameController.text,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _emailController.text,
                  style: const TextStyle(color: Color(0xFF616161)),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: const [
                    _MetricChip(label: 'Tamamlanan hedef', value: '9'),
                    _MetricChip(label: 'Aylık tasarruf', value: '42%'),
                    _MetricChip(label: 'Risk puanı', value: 'Düşük'),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
            tooltip: _isEditing ? 'Düzenlemeyi kapat' : 'Düzenle',
            icon: Icon(_isEditing ? Icons.close : Icons.edit_outlined),
            color: colors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCard(ColorScheme colors) {
    return _SectionCard(
      title: 'Hesap Bilgileri',
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildTextField(
              label: 'Ad Soyad',
              controller: _nameController,
              enabled: _isEditing,
              icon: Icons.badge_outlined,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r"[a-zA-ZA-Z\u00C0-\u024F\u1E00-\u1EFF\s]")),
              ],
              validator: _validateName,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              label: 'E-posta',
              controller: _emailController,
              enabled: _isEditing,
              keyboardType: TextInputType.emailAddress,
              icon: Icons.alternate_email_outlined,
              validator: _validateEmail,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              label: 'Telefon',
              controller: _phoneController,
              enabled: _isEditing,
              keyboardType: TextInputType.phone,
              icon: Icons.call_outlined,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(13),
              ],
              validator: _validatePhone,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _isEditing ? _saveProfile : null,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Degisiklikleri Kaydet'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesCard(ColorScheme colors) {
    return _SectionCard(
      title: 'Tercihler',
      child: Column(
        children: [
          SwitchListTile.adaptive(
            value: _pushNotifications,
            onChanged: (value) => setState(() => _pushNotifications = value),
            title: const Text('Push Bildirimleri'),
            subtitle: const Text('Anlık bütçe ve harcama hareketleri'),
            activeColor: Colors.black,
            contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile.adaptive(
            value: _emailNotifications,
            onChanged: (value) => setState(() => _emailNotifications = value),
            title: const Text('E-posta Özeti'),
            subtitle: const Text('Haftalık finans raporu'),
            activeColor: Colors.black,
            contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile.adaptive(
            value: _biometricLogin,
            onChanged: (value) => setState(() => _biometricLogin = value),
            title: const Text('Biyometrik Giriş'),
            subtitle: const Text('Parmak izi veya yüz ile giriş'),
            activeColor: Colors.black,
            contentPadding: EdgeInsets.zero,
          ),
          const Divider(height: 22),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black,
                side: const BorderSide(color: Colors.black26),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _showPasswordUpdateModal,
              icon: const Icon(Icons.lock_reset),
              label: const Text('Şifreyi Güncelle'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsCard(ColorScheme colors) {
    return _SectionCard(
      title: 'Hızlı İşlemler',
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _ActionButton(
            icon: Icons.logout,
            label: 'Çıkış Yap',
            danger: true,
            onTap: () => _showMessage('Hesaptan çıkış yapıldı (demo).'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required bool enabled,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: enabled ? Colors.white : const Color(0xFFF1F1F1),
      ),
    );
  }

  void _saveProfile() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      _showMessage('Lütfen alanları kurallara uygun doldurun.');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _isEditing = false;
    });
    _showMessage('Profil bilgileri güncellendi.');
  }

  String? _validateName(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) {
      return 'Ad Soyad boş olamaz.';
    }
    if (!RegExp(r"^[a-zA-ZA-Z\u00C0-\u024F\u1E00-\u1EFF\s]+$").hasMatch(input)) {
      return 'Ad Soyad alanında sayı veya noktalama kullanılamaz.';
    }
    if (input.replaceAll(' ', '').length < 2) {
      return 'Ad Soyad en az 2 harf olmalı.';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) {
      return 'E-posta boş olamaz.';
    }
    final emailRegex = RegExp(r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');
    if (!emailRegex.hasMatch(input)) {
      return 'Geçerli bir e-posta girin (ör. ad@alan.com).';
    }
    if (input.contains('..')) {
      return 'E-posta ard arda nokta içeremez.';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) {
      return 'Telefon boş olamaz.';
    }
    if (input.length < 8 || input.length > 13) {
      return 'Telefon 8 ile 13 karakter arasında olmalı.';
    }
    if (!RegExp(r'^\d+$').hasMatch(input)) {
      return 'Telefon sadece rakamlardan oluşmalı.';
    }
    return null;
  }

  Future<void> _showPasswordUpdateModal() async {
    final passwordFormKey = GlobalKey<FormState>();
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Şifre Güncelle'),
          content: Form(
            key: passwordFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _currentPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Mevcut Şifre',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final input = value?.trim() ?? '';
                    if (input.isEmpty) {
                      return 'Mevcut şifre boş olamaz.';
                    }
                    if (input.length < 8) {
                      return 'Mevcut şifre en az 8 karakter olmalı.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Yeni Şifre',
                    border: OutlineInputBorder(),
                    helperText: '8-32 karakter, büyük-küçük harf, sayı ve sembol içermeli.',
                  ),
                  validator: _validateNewPassword,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Yeni Şifre (Tekrar)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if ((value ?? '').isEmpty) {
                      return 'Şifre tekrarı boş olamaz.';
                    }
                    if (value != _newPasswordController.text) {
                      return 'Yeni şifreler eşleşmiyor.';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('İptal'),
            ),
            FilledButton(
              onPressed: () {
                final isValid = passwordFormKey.currentState?.validate() ?? false;
                if (!isValid) {
                  return;
                }
                Navigator.of(context).pop();
                _showMessage('Şifreniz başarıyla güncellendi.');
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              child: const Text('Güncelle'),
            ),
          ],
        );
      },
    );
  }

  String? _validateNewPassword(String? value) {
    final input = value ?? '';
    if (input.isEmpty) {
      return 'Yeni şifre boş olamaz.';
    }
    if (input.length < 8 || input.length > 32) {
      return 'Yeni şifre 8 ile 32 karakter arasında olmalı.';
    }
    if (!RegExp(r'[A-Z]').hasMatch(input)) {
      return 'En az bir büyük harf içermeli.';
    }
    if (!RegExp(r'[a-z]').hasMatch(input)) {
      return 'En az bir küçük harf içermeli.';
    }
    if (!RegExp(r'\d').hasMatch(input)) {
      return 'En az bir rakam içermeli.';
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=/\\\[\]~`]').hasMatch(input)) {
      return 'En az bir özel karakter içermeli.';
    }
    return null;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 17,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Color(0xFF616161))),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final foreground = danger ? Colors.red.shade700 : Colors.black;
    return SizedBox(
      width: 168,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: danger ? Colors.red.shade200 : Colors.black26),
          foregroundColor: foreground,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(
          label,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
