import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'services/session_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController(); // Yeni: Şifre Tekrar Controller
  
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('${AppSession.baseUrl}/api/auth/register'),
        headers: AppSession.headers,
        body: jsonEncode({
          'fullName': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kayıt başarılı! Giriş yapabilirsiniz.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        final message = responseData['message'] ?? 'Kayıt sırasında bir hata oluştu.';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sunucu bağlantı hatası: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1D212F)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Yeni Hesap Oluştur",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1D212F)),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Bütçenizi akıllıca yönetmeye başlamak için bilgilerinizi girin.", 
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 32),

                  // 1. Ad Soyad Girişi
                  _buildInputField(
                    controller: _nameController,
                    hint: 'Ad Soyad',
                    icon: Icons.person_outline_rounded,
                    validator: (value) => (value == null || value.isEmpty) ? 'Ad soyad alanını doldurun' : null,
                  ),
                  const SizedBox(height: 16),

                  // 2. E-posta Girişi
                  _buildInputField(
                    controller: _emailController,
                    hint: 'E-posta Adresi',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => (value == null || !value.contains('@')) ? 'Geçerli bir e-posta giriniz' : null,
                  ),
                  const SizedBox(height: 16),

                  // 3. Telefon Girişi
                  _buildInputField(
                    controller: _phoneController,
                    hint: 'Telefon Numarası',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (value) => (value == null || value.length < 10) ? 'Geçerli bir telefon numarası giriniz' : null,
                  ),
                  const SizedBox(height: 16),

                  // 4. Şifre Girişi
                  _buildPasswordField(
                    controller: _passwordController,
                    hint: 'Şifre',
                    isVisible: _isPasswordVisible,
                    onToggle: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                    validator: (value) => (value == null || value.length < 6) ? 'Şifre en az 6 karakter olmalıdır' : null,
                  ),
                  const SizedBox(height: 16),

                  // 5. Şifre Tekrar Girişi (YENİ ALAN)
                  _buildPasswordField(
                    controller: _confirmPasswordController,
                    hint: 'Şifre Tekrar',
                    isVisible: _isConfirmPasswordVisible,
                    onToggle: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                    // Doğrulama mantığı: Password alanıyla confirm alanını karşılaştırıyoruz
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Şifreyi tekrar giriniz';
                      if (value != _passwordController.text) return 'Şifreler birbiriyle uyuşmuyor';
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // Hesap Oluştur Butonu
                  ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1D212F),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Hesap Oluştur', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Yardımcı Widget: Normal Inputlar için
  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 15),
        prefixIcon: Icon(icon, color: const Color(0xFF1D212F), size: 22),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFC0C0C0))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF1D212F), width: 2)),
        filled: true,
        fillColor: const Color(0xFFEEEEEE),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
      validator: validator,
    );
  }

  // Yardımcı Widget: Şifre Alanları için
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool isVisible,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !isVisible,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 15),
        prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF1D212F), size: 22),
        suffixIcon: IconButton(
          icon: Icon(isVisible ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF1D212F), size: 20),
          onPressed: onToggle,
        ),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFC0C0C0))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF1D212F), width: 2)),
        filled: true,
        fillColor: const Color(0xFFEEEEEE),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
      validator: validator,
    );
  }
}