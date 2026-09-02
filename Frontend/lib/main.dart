import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'dart:ui';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:nfc/splash_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'api_service.dart';
import 'chat_screen.dart';

// ==========================================
// TEMA VE DİL YÖNETİCİLERİ
// ==========================================
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);
final ValueNotifier<String> languageNotifier = ValueNotifier(
  'tr',
); // Varsayılan dil Türkçe

String getText(String key) {
  const Map<String, Map<String, String>> localizedValues = {
    'tr': {
      'login_title': 'İZMİRİM KART',
      'login_subtitle': 'Şehrin Dijital Anahtarı',
      'email': 'E-Posta Adresi',
      'password': 'Şifre',
      'login_btn': 'GİRİŞ YAP',
      'forgot_pass': 'Şifremi Unuttum',
      'no_account': 'Hesabın yok mu? Kayıt Ol',
      'new_register': 'Yeni Kayıt Oluştur',
      'name': 'İsim',
      'surname': 'Soyisim',
      'card_type': 'Tarife Tipi',
      'pass_confirm': 'Şifre (Tekrar)',
      'create_account': 'HESABI OLUŞTUR',
      'scan_nfc': 'NFC ile Kartınızı Tarayın',
      'cancel': 'İptal',
      'verify': 'Doğrula',
      'resend': 'Tekrar Gönder',
      'send_code': 'Kod Gönder',
      'reset_pass': 'Şifreyi Yenile',
      'digital_assistant': 'Dijital Ulaşım Asistanı',
      'card_type_label': 'KART TİPİ',
      'nfc_active': 'NFC Aktif',
      'available_balance': 'Kullanılabilir Bakiye',
      'top_up': 'Bakiye Yükle',
      'tourist_places': 'Turistik Yerler',
      'history': 'Geçmiş İşlemler',
      'beaches': 'Plaj Konumları',
      'culture_art': 'Kültür & Sanat',
      'ai_assistant': 'Akıllı Şehir Asistanı',
      'ai_hint': 'Örn: Şirince\'ye en ucuz nasıl giderim?',
      'profile': 'Profilim',
      'edit_photo': 'Fotoğrafı Düzenle',
      'card_number': 'Kart Numarası:',
      'dark_mode': 'Karanlık Mod',
      'language': 'Dil / Language',
      'change_pass': 'Şifre Değiştir',
      'logout': 'Çıkış Yap',
      'home': 'Ana Sayfa',
      'old_pass': 'Eski Şifre',
      'new_pass': 'Yeni Şifre',
      'save': 'Kaydet',
      'recent_transactions': 'Son İşlemler',
      'no_history': 'İşlem geçmişi bulunamadı.',
      'turnstile_pass': 'Turnike Geçişi',
      'get_directions': 'Yol Tarifi Al',
      'free_pass': 'Ücretsiz geçiş hakkınız bulunmaktadır.',
      // YAPAY ZEKA SOHBET EKRANI İÇİN(TÜRKÇE)
      'assistant_title': 'İzmirim Asistan (Efe)',
      'ai_thinking': 'Asistan düşünüyor...',
      'ai_hint_chat': 'Asistana bir şey sor...',
      // HATA MESAJLARI
      'success_msg': 'BAŞARILI',
      'error_msg': 'HATA',
      'code_msg': 'Kod',
      'response_msg': 'Cevap',
      'err_connection': 'Bağlantı hatası.',
      'err_pass_change':
          'Şifre değiştirilemedi. Lütfen bilgileri kontrol edin.',
      'err_ai_understand': 'Cevap anlaşılamadı.',
      'err_ai_busy': 'Asistan şu an yoğun, lütfen tekrar deneyin.',
      'err_ai_connection': 'Bağlantı hatası: Asistana ulaşılamıyor.',
      'err_session_expired':
          'Oturum süresi dolmuş. Lütfen çıkış yapıp tekrar giriş yapın.',
      'err_server_unreachable': 'BAĞLANTI HATASI: Sunucuya ulaşılamıyor.',
      'err_api_rejected': 'API İşlemi Reddetti.',
      'err_server': 'Sunucu Hatası!',
      'err_not_found': 'Adres bulunamadı.',
    },
    'en': {
      'login_title': 'IZMIRIM CARD',
      'login_subtitle': 'Digital Key of the City',
      'email': 'Email Address',
      'password': 'Password',
      'login_btn': 'LOGIN',
      'forgot_pass': 'Forgot Password',
      'no_account': 'Don\'t have an account? Register',
      'new_register': 'Create New Account',
      'name': 'Name',
      'surname': 'Surname',
      'card_type': 'Card Type',
      'pass_confirm': 'Password (Confirm)',
      'create_account': 'CREATE ACCOUNT',
      'scan_nfc': 'Scan Your Card with NFC',
      'cancel': 'Cancel',
      'verify': 'Verify',
      'resend': 'Resend',
      'send_code': 'Send Code',
      'reset_pass': 'Reset Password',
      'digital_assistant': 'Digital Transit Assistant',
      'card_type_label': 'CARD TYPE',
      'nfc_active': 'NFC Active',
      'available_balance': 'Available Balance',
      'top_up': 'Top Up Balance',
      'tourist_places': 'Tourist Places',
      'history': 'Transactions',
      'beaches': 'Beach Locations',
      'culture_art': 'Culture & Art',
      'ai_assistant': 'Smart City Assistant',
      'ai_hint': 'Ex: What\'s the cheapest way to Sirince?',
      'profile': 'My Profile',
      'edit_photo': 'Edit Photo',
      'card_number': 'Card Number:',
      'dark_mode': 'Dark Mode',
      'language': 'Language / Dil',
      'change_pass': 'Change Password',
      'logout': 'Logout',
      'home': 'Home',
      'old_pass': 'Old Password',
      'new_pass': 'New Password',
      'save': 'Save',
      'recent_transactions': 'Recent Transactions',
      'no_history': 'No transaction history found.',
      'turnstile_pass': 'Turnstile Pass',
      'get_directions': 'Get Directions',
      'free_pass': 'You have a free pass.',
      // YAPAY ZEKA SOHBET EKRANI İÇİN(İNGİLİZCE)
      'assistant_title': 'Izmirim Assistant (Efe)',
      'ai_thinking': 'Assistant is typing...',
      'ai_hint_chat': 'Ask the assistant something...',
      // HATA MESAJLARI
      'success_msg': 'SUCCESS',
      'error_msg': 'ERROR',
      'code_msg': 'Code',
      'response_msg': 'Response',
      'err_connection': 'Connection error.',
      'err_pass_change':
          'Password could not be changed. Please check your details.',
      'err_ai_understand': 'Could not understand the response.',
      'err_ai_busy': 'The assistant is currently busy, please try again.',
      'err_ai_connection': 'Connection error: Cannot reach the assistant.',
      'err_session_expired':
          'Session expired. Please log out and log in again.',
      'err_server_unreachable': 'CONNECTION ERROR: Cannot reach the server.',
      'err_api_rejected': 'API Rejected the Request.',
      'err_server': 'Server Error!',
      'err_not_found': 'Address not found.',
    },
  };
  return localizedValues[languageNotifier.value]?[key] ?? key;
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) => true;
  }
}

void main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
  runApp(const IzmirimApp());
}

class IzmirimApp extends StatelessWidget {
  const IzmirimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        // YENİ EKLENEN: Dil değişimi anında tüm UI güncellenir
        return ValueListenableBuilder<String>(
          valueListenable: languageNotifier,
          builder: (_, String currentLang, __) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'İzmirim Kart',
              themeMode: currentMode,
              theme: ThemeData(
                brightness: Brightness.light,
                primaryColor: const Color(0xFF00838F),
                fontFamily: 'Roboto',
                scaffoldBackgroundColor: Colors.transparent,
              ),
              darkTheme: ThemeData(
                brightness: Brightness.dark,
                primaryColor: const Color(0xFF00E5FF),
                fontFamily: 'Roboto',
                scaffoldBackgroundColor: Colors.transparent,
              ),
              home: const FullScreenSplash(),
            );
          },
        );
      },
    );
  }
}

// ==========================================
// ORTAK BİLEŞEN: CAM EFEKTİ (GLASSMORPHISM)
// ==========================================
Widget _buildGlassBox({
  required Widget child,
  EdgeInsetsGeometry? padding,
  double? height,
  double? width,
  Color? glowColor,
  bool isDark = true,
  double borderRadius = 25,
}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(borderRadius),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
      child: Container(
        width: width,
        height: height,
        padding: padding,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.white.withOpacity(0.45),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.25)
                : Colors.white.withOpacity(0.8),
            width: 1.2,
          ),
          boxShadow: [
            if (glowColor != null)
              BoxShadow(
                color: glowColor.withOpacity(isDark ? 0.3 : 0.15),
                blurRadius: 25,
                spreadRadius: -5,
              ),
          ],
        ),
        child: child,
      ),
    ),
  );
}

// ==========================================
// ARKA PLAN
// ==========================================
class IzmirGlassBackground extends StatelessWidget {
  final Widget child;
  const IzmirGlassBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Container(
          color: isDark ? const Color(0xFF070B14) : const Color(0xFFE2E8F0),
        ),
        Positioned.fill(child: Image.asset('assets/bg.jpg', fit: BoxFit.cover)),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        const Color(0xFF070B14).withOpacity(0.6),
                        const Color(0xFF0B172A).withOpacity(0.9),
                      ]
                    : [
                        Colors.white.withOpacity(0.4),
                        const Color(0xFFE2E8F0).withOpacity(0.85),
                      ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

// ==========================================
// 1. GİRİŞ EKRANI
// ==========================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  final ApiService _apiService = ApiService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) return;

    setState(() => _isLoading = true);
    Map<String, dynamic>? result = await _apiService.login(email, password);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result != null && (result['cardId'] ?? '').isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainDashboard(
            userType: result['userType'] ?? 'Tam',
            cardId: result['cardId'],
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'E-Posta veya Şifre Hatalı! Veya hesabınız onaylanmamış olabilir.',
            style: TextStyle(fontSize: 14),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _showForgotPasswordDialog() {
    final TextEditingController _emailResetController = TextEditingController();
    final TextEditingController _otpResetController = TextEditingController();
    final TextEditingController _newPassController = TextEditingController();

    int step = 1;
    bool isSubmitting = false;
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color accentColor = isDark
        ? const Color(0xFF00E5FF)
        : const Color(0xFF00838F);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              title: Text(
                getText('forgot_pass'),
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (step == 1) ...[
                    Text(
                      "Kayıtlı e-posta adresinizi girin. Size bir sıfırlama kodu göndereceğiz.",
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _emailResetController,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      decoration: InputDecoration(
                        labelText: getText('email'),
                        filled: true,
                        fillColor: isDark
                            ? Colors.black26
                            : Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ] else ...[
                    Text(
                      "${_emailResetController.text} adresine gönderilen kodu girin.",
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _otpResetController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        letterSpacing: 5,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        counterText: "",
                        hintText: "000000",
                        filled: true,
                        fillColor: isDark
                            ? Colors.black26
                            : Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _newPassController,
                      obscureText: true,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      decoration: InputDecoration(
                        labelText: getText('new_pass'),
                        filled: true,
                        fillColor: isDark
                            ? Colors.black26
                            : Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    getText('cancel'),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: accentColor),
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (step == 1) {
                            if (_emailResetController.text.isEmpty) return;
                            setStateDialog(() => isSubmitting = true);
                            String res = await _apiService.forgotPassword(
                              _emailResetController.text,
                            );
                            setStateDialog(() {
                              isSubmitting = false;
                              step = 2;
                            });
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text(res)));
                          } else {
                            if (_otpResetController.text.length != 6 ||
                                _newPassController.text.isEmpty)
                              return;
                            setStateDialog(() => isSubmitting = true);
                            String res = await _apiService.resetPassword(
                              _emailResetController.text,
                              _otpResetController.text,
                              _newPassController.text,
                            );
                            setStateDialog(() => isSubmitting = false);

                            if (res == "BAŞARILI") {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Şifreniz başarıyla değiştirildi.',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(res),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            }
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          width: 15,
                          height: 15,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          step == 1
                              ? getText('send_code')
                              : getText('reset_pass'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    Color accentColor = isDark
        ? const Color(0xFF00E5FF)
        : const Color(0xFF00838F);

    return IzmirGlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildGlassBox(
                  isDark: isDark,
                  padding: const EdgeInsets.all(3),
                  borderRadius: 22,
                  glowColor: accentColor,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: SizedBox(
                      width: 85,
                      height: 85,
                      child: Image.asset(
                        'assets/logo.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.directions_bus,
                          size: 50,
                          color: accentColor,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  getText('login_title'),
                  style: TextStyle(
                    color: textColor,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  getText('login_subtitle'),
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 40),

                _buildGlassBox(
                  isDark: isDark,
                  padding: const EdgeInsets.all(30),
                  glowColor: accentColor,
                  child: Column(
                    children: [
                      TextField(
                        controller: _emailController,
                        style: TextStyle(color: textColor, fontSize: 16),
                        keyboardType: TextInputType.emailAddress,
                        decoration: _inputDeco(
                          isDark,
                          getText('email'),
                          Icons.email_outlined,
                          accentColor,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        style: TextStyle(color: textColor, fontSize: 16),
                        decoration: _inputDeco(
                          isDark,
                          getText('password'),
                          Icons.lock_outline,
                          accentColor,
                        ),
                      ),
                      const SizedBox(height: 35),
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor.withOpacity(
                              isDark ? 0.8 : 1.0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: _isLoading ? null : _login,
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Text(
                                  getText('login_btn'),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      TextButton(
                        onPressed: _showForgotPasswordDialog,
                        child: Text(
                          getText('forgot_pass'),
                          style: TextStyle(
                            color: isDark ? Colors.white54 : Colors.black54,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        ),
                        child: Text(
                          getText('no_account'),
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(
    bool isDark,
    String label,
    IconData icon,
    Color accentColor,
  ) => InputDecoration(
    labelText: label,
    labelStyle: TextStyle(
      color: isDark ? Colors.white54 : Colors.black54,
      fontSize: 16,
    ),
    prefixIcon: Icon(icon, color: accentColor, size: 26),
    filled: true,
    fillColor: isDark ? Colors.black26 : Colors.white.withOpacity(0.5),
    contentPadding: const EdgeInsets.symmetric(vertical: 20),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.black12),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: accentColor, width: 1.5),
    ),
  );
}

// ==========================================
// 2. KAYIT EKRANI
// ==========================================
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  final TextEditingController _cardIdController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();
  String _selectedUserType = 'Tam';
  final List<String> _userTypes = ['Tam', 'Öğrenci', 'Öğretmen', 'Emekli'];

  void _startNfcReader() async {
    var availability = await FlutterNfcKit.nfcAvailability;
    if (availability != NFCAvailability.available) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Cihazınızda NFC bulunmuyor veya kapalı!',
            style: TextStyle(fontSize: 15),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color accentColor = isDark
        ? const Color(0xFF00E5FF)
        : const Color(0xFF00838F);

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Column(
          children: [
            Icon(Icons.contactless, size: 60, color: accentColor),
            const SizedBox(height: 15),
            Text(
              "NFC Bekleniyor",
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          "Lütfen İzmirim Kart'ınızı telefonun arkasına yaklaştırın.",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black87,
            fontSize: 16,
          ),
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () async {
                await FlutterNfcKit.finish();
                if (mounted) Navigator.pop(context);
              },
              child: Text(
                getText('cancel'),
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    try {
      NFCTag tag = await FlutterNfcKit.poll();
      String idHex = tag.id.toUpperCase();
      if (!idHex.contains(':') && idHex.isNotEmpty) {
        idHex = idHex.replaceAllMapped(
          RegExp(r".{2}"),
          (match) => "${match.group(0)}:",
        );
        idHex = idHex.substring(0, idHex.length - 1);
      }
      await FlutterNfcKit.finish();
      if (mounted) {
        setState(() => _cardIdController.text = idHex);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Kart başarıyla okundu: $idHex',
              style: const TextStyle(fontSize: 15),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      await FlutterNfcKit.finish();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Kart okunamadı, tekrar deneyin!',
              style: TextStyle(fontSize: 15),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _showOtpDialog(String email) {
    final TextEditingController _otpController = TextEditingController();
    bool isSubmitting = false;
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color accentColor = isDark
        ? const Color(0xFF00E5FF)
        : const Color(0xFF00838F);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              title: Text(
                "E-Posta Doğrulama",
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "$email adresine 6 haneli bir kod gönderdik. Lütfen spam kutunuzu da kontrol edin.",
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 24,
                      letterSpacing: 8,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      counterText: "",
                      hintText: "000000",
                      filled: true,
                      fillColor: isDark ? Colors.black26 : Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    String res = await _apiService.resendVerification(email);
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(res)));
                  },
                  child: Text(
                    getText('resend'),
                    style: TextStyle(
                      color: accentColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (_otpController.text.length != 6) return;
                          setStateDialog(() => isSubmitting = true);

                          String result = await _apiService.verifyEmail(
                            email,
                            _otpController.text,
                          );

                          setStateDialog(() => isSubmitting = false);
                          if (result == "BAŞARILI") {
                            Navigator.pop(context);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Hesabınız onaylandı! Giriş yapabilirsiniz.',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(result),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          width: 15,
                          height: 15,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          getText('verify'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _submitRegister() async {
    RegExp regex = RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}$');
    if (!regex.hasMatch(_passwordController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Şifre en az 8 karakter, 1 büyük harf, 1 küçük harf ve 1 rakam içermelidir!',
          ),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    if (_cardIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Lütfen NFC butonuna basarak kartınızı okutun!',
            style: TextStyle(fontSize: 15),
          ),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }
    if (_passwordController.text != _passwordConfirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Şifreler eşleşmiyor!', style: TextStyle(fontSize: 15)),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    String emailText = _emailController.text.trim();
    bool success = await _apiService.register(
      _cardIdController.text.trim(),
      _selectedUserType,
      _nameController.text.trim(),
      _surnameController.text.trim(),
      emailText,
      _passwordController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      _showOtpDialog(emailText);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Kayıt oluşturulamadı veya e-posta kullanılıyor.',
            style: TextStyle(fontSize: 15),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    Color accentColor = isDark
        ? const Color(0xFF00E5FF)
        : const Color(0xFF00838F);

    return IzmirGlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            getText('new_register'),
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: textColor),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: _buildGlassBox(
            isDark: isDark,
            padding: const EdgeInsets.all(25),
            glowColor: accentColor,
            child: Column(
              children: [
                TextField(
                  controller: _cardIdController,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  readOnly: true,
                  decoration:
                      _inputDeco(
                        isDark,
                        getText('scan_nfc'),
                        Icons.credit_card,
                        accentColor,
                      ).copyWith(
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: IconButton(
                            style: IconButton.styleFrom(
                              backgroundColor: accentColor.withOpacity(0.2),
                            ),
                            icon: Icon(Icons.nfc, color: accentColor, size: 30),
                            onPressed: _startNfcReader,
                          ),
                        ),
                      ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _nameController,
                  style: TextStyle(color: textColor, fontSize: 16),
                  decoration: _inputDeco(
                    isDark,
                    getText('name'),
                    Icons.person_outline,
                    accentColor,
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _surnameController,
                  style: TextStyle(color: textColor, fontSize: 16),
                  decoration: _inputDeco(
                    isDark,
                    getText('surname'),
                    Icons.badge_outlined,
                    accentColor,
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _emailController,
                  style: TextStyle(color: textColor, fontSize: 16),
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDeco(
                    isDark,
                    getText('email'),
                    Icons.email_outlined,
                    accentColor,
                  ),
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  dropdownColor: isDark
                      ? const Color(0xFF1E293B)
                      : Colors.white,
                  value: _selectedUserType,
                  style: TextStyle(color: textColor, fontSize: 16),
                  items: _userTypes
                      .map(
                        (type) =>
                            DropdownMenuItem(value: type, child: Text(type)),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => _selectedUserType = val!),
                  decoration: _inputDeco(
                    isDark,
                    getText('card_type'),
                    Icons.confirmation_number_outlined,
                    accentColor,
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: TextStyle(color: textColor, fontSize: 16),
                  decoration: _inputDeco(
                    isDark,
                    getText('password'),
                    Icons.lock_outline,
                    accentColor,
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _passwordConfirmController,
                  obscureText: true,
                  style: TextStyle(color: textColor, fontSize: 16),
                  decoration: _inputDeco(
                    isDark,
                    getText('pass_confirm'),
                    Icons.lock_reset,
                    accentColor,
                  ),
                ),
                const SizedBox(height: 35),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor.withOpacity(
                        isDark ? 0.8 : 1.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: _isLoading ? null : _submitRegister,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            getText('create_account'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              letterSpacing: 1,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(
    bool isDark,
    String label,
    IconData icon,
    Color accentColor,
  ) => InputDecoration(
    labelText: label,
    labelStyle: TextStyle(
      color: isDark ? Colors.white54 : Colors.black54,
      fontSize: 16,
    ),
    prefixIcon: Icon(icon, color: accentColor, size: 26),
    filled: true,
    fillColor: isDark ? Colors.black26 : Colors.white.withOpacity(0.5),
    contentPadding: const EdgeInsets.symmetric(vertical: 20),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.black12),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: accentColor, width: 1.5),
    ),
  );
}

// ==========================================
// 3. ANA MENÜ (DASHBOARD)
// ==========================================
class MainDashboard extends StatefulWidget {
  final String userType;
  final String cardId;
  const MainDashboard({
    super.key,
    required this.userType,
    required this.cardId,
  });

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _currentIndex = 0;
  final ApiService _apiService = ApiService();
  InAppWebViewController? _webViewController;
  bool _isProcessing = false;
  double bakiye = 0.0;
  String durumMesaji = "NFC Aktif: Turnikeye Yaklaştırın";
  List<dynamic> gecisGecmisi = [];
  String htmlContent = "";
  bool _isWebViewGosterildi = false;

  String adSoyad = "Yükleniyor...";
  String userEmail = "";
  String profileImageUrl = "";
  File? _secilenProfilFotosu;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _rotaController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  static const platform = MethodChannel('com.example.nfc/channel');

  @override
  void initState() {
    super.initState();
    _initApp();
    _setupHceListener();
    _loadUserProfile();
  }

  void _loadUserProfile() async {
    try {
      Map<String, dynamic>? userInfo = await _apiService.getUserProfile(
        widget.cardId,
      );
      if (mounted && userInfo != null) {
        setState(() {
          String ad = userInfo['firstName'] ?? userInfo['name'] ?? "Kullanıcı";
          String soyad = userInfo['lastName'] ?? userInfo['surname'] ?? "";
          adSoyad = "$ad $soyad".trim();
          userEmail = userInfo['email'] ?? userInfo['Email'] ?? "";
          profileImageUrl =
              userInfo['profileImageUrl'] ?? userInfo['photo'] ?? "";
        });
      }
    } catch (e) {
      if (mounted) setState(() => adSoyad = "Bağlantı Hatası");
    }
  }

  Future<void> _galeridenFotoSec() async {
    final XFile? secilenDosya = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (secilenDosya != null) {
      File resimDosyasi = File(secilenDosya.path);
      setState(() {
        _secilenProfilFotosu = resimDosyasi;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fotoğraf sunucuya yükleniyor...'),
          backgroundColor: Colors.orange,
        ),
      );

      String? sonuc = await _apiService.uploadProfileImage(
        widget.cardId,
        resimDosyasi,
      );

      if (sonuc != null && sonuc.startsWith('http')) {
        setState(() {
          profileImageUrl = sonuc;
        });
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profil fotoğrafı kalıcı olarak güncellendi!'),
              backgroundColor: Colors.green,
            ),
          );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(sonuc ?? "Bilinmeyen Hata"),
              backgroundColor: Colors.redAccent,
              duration: const Duration(seconds: 8),
            ),
          );
        }
      }
    }
  }

  void _showChangePasswordDialog() {
    _oldPasswordController.clear();
    _newPasswordController.clear();
    showDialog(
      context: context,
      builder: (context) {
        bool isSubmitting = false;
        bool isDark = Theme.of(context).brightness == Brightness.dark;
        Color accentColor = isDark
            ? const Color(0xFF00E5FF)
            : const Color(0xFF00838F);
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              title: Text(
                getText('change_pass'),
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _oldPasswordController,
                    obscureText: true,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      labelText: getText('old_pass'),
                      filled: true,
                      fillColor: isDark ? Colors.black26 : Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _newPasswordController,
                    obscureText: true,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      labelText: getText('new_pass'),
                      filled: true,
                      fillColor: isDark ? Colors.black26 : Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    getText('cancel'),
                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (_oldPasswordController.text.isEmpty ||
                              _newPasswordController.text.isEmpty)
                            return;
                          setStateDialog(() => isSubmitting = true);
                          String result = await _apiService.changePassword(
                            _oldPasswordController.text,
                            _newPasswordController.text,
                          );
                          setStateDialog(() => isSubmitting = false);
                          if (result == "BAŞARILI") {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Şifreniz değiştirildi!",
                                  style: TextStyle(fontSize: 16),
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  result,
                                  style: const TextStyle(fontSize: 16),
                                ),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          height: 15,
                          width: 15,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          getText('save'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _cikisYap() async {
    await _apiService.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _setupHceListener() {
    platform.setMethodCallHandler((call) async {
      if (call.method == "transaction_success" && !_isProcessing && mounted) {
        if (_currentIndex != 1)
          setState(() {
            _currentIndex = 1;
            _isWebViewGosterildi = true;
          });
        await _gecisIstegiAt();
      }
    });
  }

  Future<void> _initApp() async {
    String html = await rootBundle.loadString('assets/turnike_sahnesi.html');
    setState(() => htmlContent = html);
    await _refreshData();
  }

  Future<void> _refreshData() async {
    final currentBalance = await _apiService.getBalance();
    final history = await _apiService.getHistory();
    if (mounted)
      setState(() {
        bakiye = currentBalance;
        gecisGecmisi = history;
      });
  }

  Future<void> _gecisIstegiAt() async {
    setState(() => _isProcessing = true);
    try {
      Map<String, dynamic> result = await _apiService.passTurnstile();
      bool basarili = result['success'];
      double cekilenTutar = (result['amount'] ?? 0).toDouble();
      _webViewController?.evaluateJavascript(
        source: "gecisAnimasyonunuBaslat($basarili);",
      );
      if (mounted)
        setState(
          () => durumMesaji = basarili
              ? (widget.userType == 'Emekli'
                    ? "Geçiş Başarılı!\nÜcretsiz Geçiş"
                    : "Geçiş Başarılı!\n-$cekilenTutar TL Çekildi")
              : "Yetersiz Bakiye!\nTarife: $cekilenTutar TL",
        );
      await _refreshData();
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted)
          setState(() => durumMesaji = "NFC Aktif: Turnikeye Yaklaştırın");
      });
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _yukeBakiye(double miktar) async {
    setState(() => _isProcessing = true);
    String sonuc = await _apiService.topUp(miktar);
    if (sonuc == "BAŞARILI") {
      await _refreshData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$miktar TL Yüklendi!',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.green,
          ),
        );
        setState(() => _currentIndex = 0);
      }
    }
    setState(() => _isProcessing = false);
  }

  Widget _buildAnaSayfa(bool isDark, Color textColor, Color accentColor) {
    double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    bool isKeyboardOpen = keyboardHeight > 0;

    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(25, 20, 25, 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            getText('login_title'),
                            style: TextStyle(
                              color: textColor,
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            getText('digital_assistant'),
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black54,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      _buildGlassBox(
                        isDark: isDark,
                        padding: const EdgeInsets.all(5),
                        borderRadius: 50,
                        child: IconButton(
                          icon: Icon(
                            Icons.settings_outlined,
                            color: textColor,
                            size: 28,
                          ),
                          onPressed: () => setState(() => _currentIndex = 3),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildGlassBox(
                    isDark: isDark,
                    glowColor: accentColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 25,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${getText('card_type_label')}: ${widget.userType.toUpperCase()}",
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black87,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: accentColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: accentColor.withOpacity(0.5),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.nfc, color: accentColor, size: 16),
                                  const SizedBox(width: 5),
                                  Text(
                                    getText('nfc_active'),
                                    style: TextStyle(
                                      color: accentColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),
                        Text(
                          getText('available_balance'),
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "${bakiye.toStringAsFixed(2)} ₺",
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 52,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1,
                            shadows: [
                              Shadow(
                                color: accentColor.withOpacity(
                                  isDark ? 0.5 : 0.3,
                                ),
                                blurRadius: 15,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildGlassServiceCard(
                          isDark,
                          getText('top_up').replaceAll(" ", "\n"),
                          Icons.account_balance_wallet,
                          const Color(0xFF81C784),
                          () => setState(() => _currentIndex = 2),
                          fontSize: 13,
                          iconSize: 26,
                        ),
                      ),
                      const SizedBox(width: 10),

                      Expanded(
                        child: _buildGlassServiceCard(
                          isDark,
                          getText('tourist_places').replaceAll(" ", "\n"),
                          Icons.camera_alt,
                          const Color(0xFF64FFDA),
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TuristikYerlerScreen(),
                            ),
                          ),
                          fontSize: 13,
                          iconSize: 26,
                        ),
                      ),
                      const SizedBox(width: 10),

                      Expanded(
                        child: _buildGlassServiceCard(
                          isDark,
                          getText('history').replaceAll(" ", "\n"),
                          Icons.receipt_long,
                          const Color(0xFF90CAF9),
                          _showGecmisBottomSheet,
                          fontSize: 13,
                          iconSize: 26,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildGlassServiceCard(
                          isDark,
                          getText('beaches').replaceAll(" ", "\n"),
                          Icons.beach_access,
                          const Color(0xFFFFB74D),
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PlajlarScreen(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildGlassServiceCard(
                          isDark,
                          getText('culture_art').replaceAll(" ", "\n"),
                          Icons.theater_comedy,
                          const Color(0xFFF06292),
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EtkinliklerScreen(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        AnimatedPositioned(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutQuad,
          bottom: isKeyboardOpen ? keyboardHeight + 15 : 135,
          left: 20,
          right: 20,
          child: _buildGlassBox(
            isDark: isDark,
            glowColor: const Color(0xFFB388FF),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      color: Color(0xFFB388FF),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      getText('ai_assistant'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: textColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _rotaController,
                        style: TextStyle(color: textColor, fontSize: 15),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 15,
                          ),
                          hintText: getText('ai_hint'),
                          hintStyle: TextStyle(
                            color: isDark ? Colors.white54 : Colors.black45,
                            fontSize: 13,
                          ),
                          filled: true,
                          fillColor: isDark
                              ? Colors.black26
                              : Colors.white.withOpacity(0.5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFB388FF).withOpacity(0.4),
                            blurRadius: 15,
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB388FF),
                          padding: const EdgeInsets.all(16),
                          shape: const CircleBorder(),
                        ),
                        onPressed: () {
                          String soru = _rotaController.text.trim();
                          if (soru.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ChatScreen(initialMessage: soru),
                              ),
                            );
                          }
                        },
                        child: const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGlassServiceCard(
    bool isDark,
    String title,
    IconData icon,
    Color glowColor,
    VoidCallback onTap, {
    double fontSize = 16,
    double iconSize = 30,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: _buildGlassBox(
        isDark: isDark,
        height: 110,
        glowColor: glowColor,
        child: Stack(
          children: [
            Positioned(
              right: -15,
              bottom: -15,
              child: Icon(
                icon,
                size: 85,
                color: glowColor.withOpacity(isDark ? 0.3 : 0.15),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: glowColor, size: iconSize),
                  Text(
                    title,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w900,
                      fontSize: fontSize,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYuklemeEkrani(bool isDark, Color textColor, Color accentColor) {
    if (widget.userType == 'Emekli') return Scaffold(backgroundColor: Colors.transparent, body: Center(child: Text(getText('free_pass'), style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold))));
    final List<double> tutarlar = [50.0, 100.0, 200.0, 500.0];

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(getText('top_up'), style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 24)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,

        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor),
          onPressed: () {
            setState(() {
              _currentIndex = 0;
            });
          },
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(25),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 20, mainAxisSpacing: 20),
        itemCount: tutarlar.length,
        itemBuilder: (context, index) {
          return InkWell(
              onTap: _isProcessing ? null : () => _yukeBakiye(tutarlar[index]),
              borderRadius: BorderRadius.circular(30),
              child: _buildGlassBox(
                  isDark: isDark,
                  glowColor: accentColor,
                  child: Center(
                      child: Text(
                          "₺${tutarlar[index].toInt()}",
                          style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: accentColor, shadows: [Shadow(color: accentColor.withOpacity(0.5), blurRadius: 10)])
                      )
                  )
              )
          );
        },
      ),
    );
  }

  Widget _buildProfilEkrani(bool isDark, Color textColor, Color accentColor) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          getText('profile'),
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 25, right: 25, top: 25, bottom: 160), // Alt kısıma 130px boşluk eklendi
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildGlassBox(
              isDark: isDark,
              glowColor: accentColor,
              padding: const EdgeInsets.all(25),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _galeridenFotoSec,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: accentColor, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: accentColor.withOpacity(0.3),
                                blurRadius: 15,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: _secilenProfilFotosu != null
                                ? Image.file(
                                    _secilenProfilFotosu!,
                                    fit: BoxFit.cover,
                                  )
                                : (profileImageUrl.isNotEmpty
                                      ? Image.network(
                                          profileImageUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (c, e, s) => Container(
                                            color: accentColor,
                                            child: const Icon(
                                              Icons.person,
                                              size: 55,
                                              color: Colors.white,
                                            ),
                                          ),
                                        )
                                      : Container(
                                          color: accentColor,
                                          child: const Icon(
                                            Icons.person,
                                            size: 55,
                                            color: Colors.white,
                                          ),
                                        )),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: accentColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF1E293B)
                                  : Colors.white,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.black87,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextButton.icon(
                    onPressed: _galeridenFotoSec,
                    icon: Icon(Icons.edit, size: 18, color: accentColor),
                    label: Text(
                      getText('edit_photo'),
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: accentColor.withOpacity(0.15),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    adSoyad,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    userEmail,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      widget.userType.toUpperCase(),
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Divider(
                      height: 1,
                      color: isDark ? Colors.white24 : Colors.black12,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        getText('card_number'),
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black54,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        widget.cardId,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 35),
            _buildGlassBox(
              isDark: isDark,
              child: Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 5,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orangeAccent.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isDark ? Icons.dark_mode : Icons.light_mode,
                        color: Colors.orangeAccent,
                        size: 28,
                      ),
                    ),
                    title: Text(
                      getText('dark_mode'),
                      style: TextStyle(
                        color: textColor,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: Switch(
                      value: isDark,
                      activeColor: accentColor,
                      onChanged: (val) => themeNotifier.value = val
                          ? ThemeMode.dark
                          : ThemeMode.light,
                    ),
                  ),
                  Divider(
                    height: 0,
                    color: isDark ? Colors.white12 : Colors.black12,
                  ),
                  // YENİ EKLENEN: DİL SEÇİM MENÜSÜ
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 5,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.language,
                        color: Colors.green,
                        size: 28,
                      ),
                    ),
                    title: Text(
                      getText('language'),
                      style: TextStyle(
                        color: textColor,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: DropdownButton<String>(
                      value: languageNotifier.value,
                      dropdownColor: isDark
                          ? const Color(0xFF1E293B)
                          : Colors.white,
                      underline: const SizedBox(),
                      icon: Icon(
                        Icons.keyboard_arrow_down,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      items: const [
                        DropdownMenuItem(value: 'tr', child: Text("Türkçe")),
                        DropdownMenuItem(value: 'en', child: Text("English")),
                      ],
                      onChanged: (val) {
                        if (val != null) languageNotifier.value = val;
                      },
                    ),
                  ),
                  Divider(
                    height: 0,
                    color: isDark ? Colors.white12 : Colors.black12,
                  ),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 5,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock_outline,
                        color: Colors.blueAccent,
                        size: 28,
                      ),
                    ),
                    title: Text(
                      getText('change_pass'),
                      style: TextStyle(
                        color: textColor,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                    onTap: _showChangePasswordDialog,
                  ),
                  Divider(
                    height: 0,
                    color: isDark ? Colors.white12 : Colors.black12,
                  ),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 5,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.logout,
                        color: Colors.redAccent,
                        size: 28,
                      ),
                    ),
                    title: Text(
                      getText('logout'),
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    onTap: _cikisYap,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGecmisBottomSheet() {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return _buildGlassBox(
          isDark: isDark,
          height: MediaQuery.of(context).size.height * 0.6,
          padding: const EdgeInsets.all(25),
          borderRadius: 30,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white54 : Colors.black26,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                getText('recent_transactions'),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: gecisGecmisi.isEmpty
                    ? Center(
                        child: Text(
                          getText('no_history'),
                          style: TextStyle(
                            color: isDark ? Colors.white54 : Colors.black54,
                            fontSize: 16,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: gecisGecmisi.length,
                        separatorBuilder: (context, index) => Divider(
                          color: isDark ? Colors.white12 : Colors.black12,
                        ),
                        itemBuilder: (context, index) {
                          final item = gecisGecmisi[index];
                          final date = DateTime.parse(item['date']).toLocal();
                          final formattedDate =
                              "${date.day}/${date.month}/${date.year} - ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
                          final isTopUp = item['transactionType'] == 'TOPUP';
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 5,
                            ),
                            leading: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isTopUp
                                    ? Colors.green.withOpacity(0.15)
                                    : Colors.red.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isTopUp
                                    ? Icons.arrow_downward
                                    : Icons.arrow_upward,
                                color: isTopUp
                                    ? Colors.greenAccent
                                    : Colors.redAccent,
                                size: 24,
                              ),
                            ),
                            title: Text(
                              isTopUp
                                  ? getText('top_up')
                                  : getText('turnstile_pass'),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            subtitle: Text(
                              formattedDate,
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black54,
                                fontSize: 14,
                              ),
                            ),
                            trailing: Text(
                              isTopUp
                                  ? "+${item['amount']} ₺"
                                  : "-${item['amount']} ₺",
                              style: TextStyle(
                                color: isTopUp
                                    ? Colors.greenAccent
                                    : Colors.redAccent,
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                                shadows: [
                                  Shadow(
                                    color: isTopUp
                                        ? Colors.greenAccent.withOpacity(0.5)
                                        : Colors.redAccent.withOpacity(0.5),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGecisEkrani(Color accentColor) {
    if (!_isWebViewGosterildi)
      return Center(child: CircularProgressIndicator(color: accentColor));
    return Stack(
      children: [
        Container(color: Colors.transparent),
        htmlContent.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : InAppWebView(
                initialData: InAppWebViewInitialData(data: htmlContent),
                initialSettings: InAppWebViewSettings(
                  transparentBackground: true,
                  javaScriptEnabled: true,
                ),
                onWebViewCreated: (controller) =>
                    _webViewController = controller,
              ),
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            margin: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 30,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.85),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: accentColor, width: 2),
              boxShadow: [
                BoxShadow(color: accentColor.withOpacity(0.5), blurRadius: 20),
              ],
            ),
            child: Text(
              durumMesaji,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: accentColor,
                letterSpacing: 1,
                shadows: [Shadow(color: accentColor, blurRadius: 10)],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    Color accentColor = isDark
        ? const Color(0xFF00E5FF)
        : const Color(0xFF00838F);

    return IzmirGlassBackground(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        extendBody: true,
        backgroundColor: Colors.transparent,
        body: IndexedStack(
          index: _currentIndex,
          children: [
            _buildAnaSayfa(isDark, textColor, accentColor),
            _buildGecisEkrani(accentColor),
            _buildYuklemeEkrani(isDark, textColor, accentColor),
            _buildProfilEkrani(isDark, textColor, accentColor),
          ],
        ),
        floatingActionButton: Container(
          height: 85,
          width: 85,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.85),
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(isDark ? 0.6 : 0.8),
                blurRadius: 30,
                spreadRadius: 2,
              ),
            ],
            border: Border.all(color: accentColor.withOpacity(0.8), width: 2),
          ),
          child: FloatingActionButton(
            onPressed: () => setState(() {
              _currentIndex = 1;
              _isWebViewGosterildi = true;
            }),
            backgroundColor: Colors.transparent,
            elevation: 0,
            highlightElevation: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "İZM",
                  style: TextStyle(
                    color: accentColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    letterSpacing: 2,
                    shadows: [Shadow(color: accentColor, blurRadius: 10)],
                  ),
                ),
                const SizedBox(height: 2),
                Icon(Icons.contactless, color: accentColor, size: 20),
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: BottomAppBar(
              color: isDark
                  ? Colors.black.withOpacity(0.4)
                  : Colors.white.withOpacity(0.6),
              shape: const CircularNotchedRectangle(),
              notchMargin: 12.0,
              elevation: 0,
              child: SizedBox(
                height: 75,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildBottomIcon(
                      0,
                      Icons.home_outlined,
                      Icons.home,
                      getText('home'),
                      isDark,
                      accentColor,
                    ),
                    const SizedBox(width: 60),
                    _buildBottomIcon(
                      3,
                      Icons.person_outline,
                      Icons.person,
                      getText('profile'),
                      isDark,
                      accentColor,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomIcon(
    int index,
    IconData outlineIcon,
    IconData solidIcon,
    String label,
    bool isDark,
    Color accentColor,
  ) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSelected ? solidIcon : outlineIcon,
            color: isSelected
                ? accentColor
                : (isDark ? Colors.white54 : Colors.black54),
            size: 32,
            shadows: [
              if (isSelected) Shadow(color: accentColor, blurRadius: 15),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? accentColor
                  : (isDark ? Colors.white54 : Colors.black54),
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 4. İZMİR AÇIK VERİ - PLAJLAR
// ==========================================
class PlajlarScreen extends StatefulWidget {
  const PlajlarScreen({super.key});
  @override
  State<PlajlarScreen> createState() => _PlajlarScreenState();
}

class _PlajlarScreenState extends State<PlajlarScreen> {
  List<dynamic> plajlar = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPlajlar();
  }

  Future<void> _fetchPlajlar() async {
    try {
      final response = await http.get(
        Uri.parse('https://openapi.izmir.bel.tr/api/ibb/cbs/plajlar'),
      );
      if (response.statusCode == 200) {
        setState(() {
          plajlar = jsonDecode(response.body)['onemliyer'] ?? [];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _googleMapsYolTarifiAc(double lat, double lng) async {
    final Uri url = Uri.parse(
      "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng",
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _showPlajBilgiBottomSheet(Map<dynamic, dynamic> plaj) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    String plajAdi = plaj['ADI'] ?? plaj['adi'] ?? "Bilinmeyen Plaj";
    String ilce = plaj['ILCE'] ?? plaj['ilce'] ?? "İzmir";
    double lat = (plaj['ENLEM'] as num).toDouble();
    double lng = (plaj['BOYLAM'] as num).toDouble();

    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(15),
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1E293B).withOpacity(0.95)
                : Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: const Color(0xFFFFB74D).withOpacity(0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFB74D).withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white54 : Colors.black26,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB74D).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.beach_access,
                      color: Color(0xFFFFB74D),
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plajAdi,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.orangeAccent,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              ilce,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB74D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 5,
                    shadowColor: const Color(0xFFFFB74D).withOpacity(0.5),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _googleMapsYolTarifiAc(lat, lng);
                  },
                  icon: const Icon(
                    Icons.directions,
                    color: Colors.black87,
                    size: 24,
                  ),
                  label: Text(
                    getText('get_directions'),
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return IzmirGlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            getText('beaches'),
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFFFB74D)),
              )
            : _buildGlassBox(
                isDark: isDark,
                glowColor: const Color(0xFFFFB74D),
                child: FlutterMap(
                  options: const MapOptions(
                    initialCenter: LatLng(38.4237, 27.1428),
                    initialZoom: 8.5,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.izmirimkart.app',
                    ),
                    MarkerLayer(
                      markers: plajlar
                          .map(
                            (plaj) => Marker(
                              point: LatLng(
                                (plaj['ENLEM'] as num).toDouble(),
                                (plaj['BOYLAM'] as num).toDouble(),
                              ),
                              width: 55,
                              height: 55,
                              child: GestureDetector(
                                onTap: () => _showPlajBilgiBottomSheet(plaj),
                                child: const Icon(
                                  Icons.location_on,
                                  color: Color(0xFFFFB74D),
                                  size: 55,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black45,
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

// ==========================================
// 5. İZMİR AÇIK VERİ - KÜLTÜR SANAT
// ==========================================
class EtkinliklerScreen extends StatefulWidget {
  const EtkinliklerScreen({super.key});
  @override
  State<EtkinliklerScreen> createState() => _EtkinliklerScreenState();
}

class _EtkinliklerScreenState extends State<EtkinliklerScreen> {
  List<dynamic> etkinlikler = [];
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    _fetchEtkinlikler();
  }

  Future<void> _fetchEtkinlikler() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://openapi.izmir.bel.tr/api/ibb/kultursanat/etkinlikler',
        ),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        setState(() {
          etkinlikler = decoded is List
              ? decoded
              : (decoded['KulturSanatEtkinlikleri'] ??
                    decoded['etkinlikler'] ??
                    decoded['data'] ??
                    []);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  String _findValue(Map<dynamic, dynamic> item, List<String> keywords) {
    for (var key in item.keys) {
      String k = key.toString().toLowerCase();
      for (var word in keywords) {
        if (k.contains(word)) return item[key].toString();
      }
    }
    return "Bilgi Bulunamadı";
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    return IzmirGlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            getText('culture_art'),
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: textColor),
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFF06292)),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: etkinlikler.length,
                itemBuilder: (context, index) {
                  var e = etkinlikler[index];
                  if (e is! Map) return const SizedBox();
                  String tarih = _findValue(e, [
                    'tarih',
                    'baslangic',
                    'gun',
                    'zaman',
                  ]);
                  String yer = _findValue(e, [
                    'mekan',
                    'yer',
                    'salon',
                    'konum',
                    'fabrikasi',
                  ]);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: _buildGlassBox(
                      isDark: isDark,
                      glowColor: const Color(0xFFF06292),
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF06292).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.theater_comedy,
                              color: Color(0xFFF06292),
                              size: 40,
                              shadows: [
                                Shadow(
                                  color: Color(0xFFF06292),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  e['EtkinlikAdi'] ??
                                      e['Adi'] ??
                                      e['Ad'] ??
                                      "İsimsiz Etkinlik",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: textColor,
                                    fontSize: 17,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        tarih,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      size: 16,
                                      color: Colors.orangeAccent,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        yer,
                                        style: const TextStyle(
                                          color: Colors.orangeAccent,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
// ==========================================
// 6. İZMİR AÇIK VERİ - TURİSTİK YERLER VE MÜZELER
// ==========================================
class TuristikYerlerScreen extends StatefulWidget {
  const TuristikYerlerScreen({super.key});
  @override
  State<TuristikYerlerScreen> createState() => _TuristikYerlerScreenState();
}

class _TuristikYerlerScreenState extends State<TuristikYerlerScreen> {
  List<dynamic> turistikYerler = [];
  List<String> _ilceler = ["TÜM İLÇELER"];
  String _seciliIlce = "TÜM İLÇELER";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTuristikYerler();
  }

  Future<void> _fetchTuristikYerler() async {
    try {
      final response = await http.get(
        Uri.parse('https://openapi.izmir.bel.tr/api/ibb/cbs/muzeler'),
      );
      if (response.statusCode == 200) {
        var decoded = jsonDecode(response.body);
        var veriler = decoded['muzeler'] ?? decoded['onemliyer'] ?? decoded['data'] ?? [];

        // İlçe listesini dinamik olarak çıkar, tekrarları engelle ve sırala
        Set<String> ilceSet = {};
        for (var yer in veriler) {
          String ilce = yer['ILCE'] ?? yer['ilce'] ?? "DİĞER";
          ilceSet.add(ilce.toUpperCase().trim());
        }
        List<String> siraliIlceler = ilceSet.toList()..sort();

        setState(() {
          turistikYerler = veriler;
          _ilceler = ["TÜM İLÇELER", ...siraliIlceler];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _googleMapsYolTarifiAc(double lat, double lng) async {
    final Uri url = Uri.parse(
      "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng",
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _showYerBilgiBottomSheet(Map<dynamic, dynamic> yer) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    String ad = yer['ADI'] ?? yer['adi'] ?? "Bilinmeyen Turistik Yer";
    String ilce = yer['ILCE'] ?? yer['ilce'] ?? "İzmir";
    String tamAciklama = yer['ACIKLAMA'] ?? yer['aciklama'] ?? "Tarihi ve turistik bir mekan.";

    // --- ÇALIŞMA SAATLERİNİ AYRIŞTIRMA MANTIĞI ---
    String calismaSaatleri = "Belirtilmemiş / Sürekli Açık";
    String gosterilecekAciklama = tamAciklama;

    // Metnin içindeki "Hafta içi" veya "Randevu alınması" gibi kalıpları bulup metni ikiye bölüyoruz
    int bolmeNoktasi = tamAciklama.toLowerCase().lastIndexOf("hafta içi");
    if(bolmeNoktasi == -1) bolmeNoktasi = tamAciklama.toLowerCase().lastIndexOf("randevu alınması");

    if (bolmeNoktasi != -1) {
      calismaSaatleri = tamAciklama.substring(bolmeNoktasi).trim();
      gosterilecekAciklama = tamAciklama.substring(0, bolmeNoktasi).trim();
    }

    double lat = (yer['ENLEM'] as num?)?.toDouble() ?? 38.4237;
    double lng = (yer['BOYLAM'] as num?)?.toDouble() ?? 27.1428;

    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(15),
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1E293B).withOpacity(0.95)
                : Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: const Color(0xFF64FFDA).withOpacity(0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF64FFDA).withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white54 : Colors.black26,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF64FFDA).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.account_balance,
                      color: Color(0xFF64FFDA),
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ad,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.orangeAccent,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              ilce,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // --- YENİ EKLENEN ÇALIŞMA SAATLERİ KUTUSU ---
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12)
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.access_time, color: Color(0xFF64FFDA), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Çalışma Saatleri:\n$calismaSaatleri",
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black87,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),

              // --- GÜNCELLENMİŞ KISA AÇIKLAMA METNİ ---
              if(gosterilecekAciklama.isNotEmpty)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        gosterilecekAciklama,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF64FFDA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 5,
                    shadowColor: const Color(0xFF64FFDA).withOpacity(0.5),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _googleMapsYolTarifiAc(lat, lng);
                  },
                  icon: const Icon(
                    Icons.directions,
                    color: Colors.black87,
                    size: 24,
                  ),
                  label: Text(
                    getText('get_directions'),
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    // HARİTAYA BASILMADAN ÖNCE İLÇE FİLTRELEMESİ UYGULANIYOR
    var filtrelenmisYerler = turistikYerler.where((yer) {
      if (_seciliIlce == "TÜM İLÇELER") return true;
      String ilce = yer['ILCE'] ?? yer['ilce'] ?? "";
      return ilce.toUpperCase().trim() == _seciliIlce;
    }).toList();

    return IzmirGlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            getText('tourist_places').replaceAll("\n", " "),
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(
            color: isDark ? Colors.white : Colors.black87,
          ),
          // --- EKRANIN SAĞ ÜSTÜNE EKLENEN İLÇE FİLTRESİ ---
          actions: [
            if (!isLoading)
              Padding(
                padding: const EdgeInsets.only(right: 15),
                child: DropdownButton<String>(
                  value: _seciliIlce,
                  icon: Icon(Icons.filter_list, color: isDark ? Colors.white : Colors.black87),
                  dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                  underline: const SizedBox(),
                  style: TextStyle(
                    color: isDark ? const Color(0xFF64FFDA) : const Color(0xFF00838F),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _seciliIlce = newValue;
                      });
                    }
                  },
                  items: _ilceler.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              )
          ],
        ),
        body: isLoading
            ? const Center(
          child: CircularProgressIndicator(color: Color(0xFF64FFDA)),
        )
            : _buildGlassBox(
          isDark: isDark,
          glowColor: const Color(0xFF64FFDA),
          child: FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(38.4237, 27.1428),
              initialZoom: 11.0, // Zoom biraz yaklaştırıldı
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.izmirimkart.app',
              ),
              MarkerLayer(
                markers: filtrelenmisYerler.map((yer) {
                  double lat = (yer['ENLEM'] as num?)?.toDouble() ?? 38.4237;
                  double lng = (yer['BOYLAM'] as num?)?.toDouble() ?? 27.1428;
                  return Marker(
                    point: LatLng(lat, lng),
                    width: 40, // Pinpoint ikonlarına uygun küçük boyut
                    height: 40,
                    child: GestureDetector(
                      onTap: () => _showYerBilgiBottomSheet(yer),
                      child: const Icon(
                        Icons.location_pin, // BÜYÜK BİNA İKONU PINPOINT İLE DEĞİŞTİRİLDİ
                        color: Colors.deepOrange,
                        size: 40,
                        shadows: [
                          Shadow(color: Colors.black87, blurRadius: 8),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
