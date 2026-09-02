import 'package:flutter/material.dart';
import 'api_service.dart';
import 'main.dart'; // getText fonksiyonunu kullanabilmek için eklendi!

class ChatScreen extends StatefulWidget {
  final String initialMessage;
  const ChatScreen({super.key, required this.initialMessage});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ApiService _apiService = ApiService();
  final List<Map<String, String>> _messages = [];
  bool _isTyping = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Ekrana girer girmez, kullanıcının ana sayfada yazdığı soruyu gönder
    if (widget.initialMessage.isNotEmpty) {
      _msgController.text = widget.initialMessage;
      _sendMessage();
    }
  }

  void _sendMessage() async {
    String text = _msgController.text.trim();
    if (text.isEmpty) return;

    // Kullanıcının mesajını ekrana ekle
    setState(() {
      _messages.add({"sender": "user", "text": text});
      _isTyping = true;
    });
    _msgController.clear();
    _scrollToBottom();

    // API'ye (C# -> Gemini) soruyu gönder
    String aiReply = await _apiService.askAiAssistant(text);

    // Gelen cevabı ekrana ekle
    if (mounted) {
      setState(() {
        _messages.add({"sender": "ai", "text": aiReply});
        _isTyping = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color aiColor = const Color(0xFFB388FF); // Yapay zeka mor rengi

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF070B14) : const Color(0xFFE2E8F0),
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.auto_awesome, color: aiColor),
            const SizedBox(width: 10),
            Text(getText('assistant_title'), style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
      ),
      body: Column(
        children: [
          // MESAJLARIN LİSTELENDİĞİ ALAN
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(15),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                bool isMe = _messages[index]["sender"] == "user";
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    padding: const EdgeInsets.all(15),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isMe ? const Color(0xFF00838F).withOpacity(0.8) : (isDark ? Colors.white12 : Colors.black12),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: isMe ? const Radius.circular(20) : const Radius.circular(0),
                        bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(20),
                      ),
                    ),
                    child: Text(
                      _messages[index]["text"]!,
                      style: TextStyle(color: isMe ? Colors.white : (isDark ? Colors.white70 : Colors.black87), fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          ),

          // YAZIYOR ANİMASYONU
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(getText('ai_thinking'), style: TextStyle(color: aiColor, fontStyle: FontStyle.italic)),
              ),
            ),

          // MESAJ YAZMA KUTUSU (EN ALT)
          Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      hintText: getText('ai_hint_chat'),
                      filled: true,
                      fillColor: isDark ? Colors.white12 : Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                    onSubmitted: (value) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 10),
                CircleAvatar(
                  radius: 25,
                  backgroundColor: aiColor,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}