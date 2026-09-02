import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'main.dart'; // Çoklu dil sözlüğünü (getText) kullanabilmek için eklendi!

class ApiService {
  static const String baseUrl = 'http://10.138.231.170:5000/api';
  static const String hubUrl = 'http://10.138.231.170:5000/izmirimhub';

  HubConnection? _hubConnection;
  static String? loggedInCardId;

  Future<void> _initSignalR() async {
    if (_hubConnection != null && _hubConnection!.state == HubConnectionState.Connected) {
      return;
    }
    _hubConnection = HubConnectionBuilder().withUrl(hubUrl).build();
    await _hubConnection?.start();
  }

  void listenForKickOut(Function onForceLogout) {
    _hubConnection?.on("ForceLogout", (arguments) {
      onForceLogout();
    });
  }

  Future<Map<String, String>> _getHeaders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${token ?? ""}',
    };
  }

  Future<bool> register(String cardId, String userType, String firstName, String lastName, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'cardId': cardId,
          'userType': userType,
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'password': password
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        loggedInCardId = cardId;
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      await _initSignalR();
      String connectionId = _hubConnection?.connectionId ?? "";

      final response = await http.post(
        Uri.parse('$baseUrl/Auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'connectionId': connectionId,
        }),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        String token = data['token'] ?? data['Token'] ?? '';
        String cardId = data['cardId'] ?? data['CardId'] ?? '';
        String userType = data['userType'] ?? data['UserType'] ?? 'Tam';

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);

        loggedInCardId = cardId;

        return {
          'userType': userType,
          'cardId': cardId
        };
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<String> changePassword(String oldPassword, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Auth/change-password'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'oldPassword': oldPassword,
          'newPassword': newPassword
        }),
      );

      if (response.statusCode == 200) {
        return getText('success_msg');
      } else {
        return getText('err_pass_change');
      }
    } catch (e) {
      return getText('err_connection');
    }
  }

  // YAPAY ZEKA (GEMINI) SOHBET METODU
  Future<String> askAiAssistant(String message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Ai/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': message}),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return data['reply'] ?? getText('err_ai_understand');
      } else {
        return getText('err_ai_busy');
      }
    } catch (e) {
      return getText('err_ai_connection');
    }
  }

  // ==========================================
  // PROFİL FOTOĞRAFI YÜKLEME METODU
  // ==========================================
  Future<String?> uploadProfileImage(String cardId, File imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/User/upload-profile-image'));

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('jwt_token');
      request.headers['Authorization'] = 'Bearer ${token ?? ""}';

      request.fields['cardId'] = cardId;
      var pic = await http.MultipartFile.fromPath('image', imageFile.path);
      request.files.add(pic);

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(responseData);
        return jsonResponse['profileImageUrl'];
      } else {
        return "${getText('error_msg')} ${response.statusCode}: $responseData";
      }
    } catch (e) {
      return "${getText('err_server_unreachable')} ($e)";
    }
  }

  Future<double> getBalance() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/Wallet/balance'), headers: await _getHeaders());
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return (data['balance'] ?? data['Balance'] ?? 0).toDouble();
      }
      return 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  Future<String> topUp(double amount) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('jwt_token');

      if (token == null || token.isEmpty) return getText('err_session_expired');

      final response = await http.post(
        Uri.parse('$baseUrl/Wallet/topup'),
        headers: await _getHeaders(),
        body: jsonEncode({'amount': amount}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) return getText('success_msg');
      else return "${getText('error_msg')} ${response.statusCode}: ${getText('err_api_rejected')}";
    } catch (e) {
      return getText('err_server_unreachable');
    }
  }

  Future<Map<String, dynamic>> passTurnstile() async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/Wallet/pass'), headers: await _getHeaders());
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return {'success': true, 'amount': (data['deductedAmount'] ?? data['DeductedAmount'] ?? 0).toDouble()};
      } else if (response.statusCode == 400) {
        var data = jsonDecode(response.body);
        return {'success': false, 'amount': (data['requiredAmount'] ?? data['RequiredAmount'] ?? 0).toDouble()};
      }
      return {'success': false, 'amount': 0.0};
    } catch (e) {
      return {'success': false, 'amount': 0.0};
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String cardId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/User/profile?cardId=$cardId'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          "isError": true,
          "message": "${getText('code_msg')}: ${response.statusCode} | ${getText('response_msg')}: ${response.body}"
        };
      }
    } catch (e) {
      return {
        "isError": true,
        "message": "${getText('err_server_unreachable')}: $e"
      };
    }
  }

  Future<List<dynamic>> getHistory() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/Wallet/history'), headers: await _getHeaders());
      if (response.statusCode == 200) return jsonDecode(response.body);
      return [];
    } catch (e) {
      return [];
    }
  }

  // =======================================================
  // GÜVENLİK FONKSİYONLARI
  // =======================================================

  // 1. E-Posta Doğrulama
  Future<String> verifyEmail(String email, String otpCode) async {
    try {
      final String hedefAdres = '$baseUrl/Auth/verify-email';
      print("İSTEK ATILAN ADRES: $hedefAdres");

      final response = await http.post(
          Uri.parse(hedefAdres),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'otpCode': otpCode})
      );

      if (response.statusCode == 200) return getText('success_msg');

      return "${getText('err_server')} ${getText('code_msg')}: ${response.statusCode} - ${getText('err_not_found')}";
    } catch (e) {
      return "${getText('err_connection')} $e";
    }
  }

  // 2. Yeni Kod Gönder (Resend)
  Future<String> resendVerification(String email) async {
    try {
      final response = await http.post(
          Uri.parse('$baseUrl/Auth/resend-verification'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email})
      );
      if (response.statusCode == 200) return getText('success_msg');
      return response.body;
    } catch (e) { return getText('err_connection'); }
  }

  // 3. Şifremi Unuttum İsteği
  Future<String> forgotPassword(String email) async {
    try {
      final response = await http.post(
          Uri.parse('$baseUrl/Auth/forgot-password'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email})
      );
      if (response.statusCode == 200) return getText('success_msg');
      return response.body;
    } catch (e) { return getText('err_connection'); }
  }

  // 4. Şifreyi Sıfırla (Yeni Şifre Belirleme)
  Future<String> resetPassword(String email, String otpCode, String newPassword) async {
    try {
      final response = await http.post(
          Uri.parse('$baseUrl/Auth/reset-password'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'otpCode': otpCode, 'newPassword': newPassword})
      );
      if (response.statusCode == 200) return getText('success_msg');
      return response.body;
    } catch (e) { return getText('err_connection'); }
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    loggedInCardId = null;
    await _hubConnection?.stop();
  }
}