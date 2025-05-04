import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ChatbotService {
  final String _baseUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro:generateContent";
  final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

  final List<String> _itKeywords = [
    "lập trình", "coding", "flutter", "java", "python", "framework",
    "backend", "frontend", "developer", "AI", "machine learning",
    "công nghệ thông tin", "IT", "database", "SQL", "API", "software",
    "hardware", "devops", "cloud", "web", "mobile", "app", "website",
    "network", "cybersecurity", "data science", "big data", "algorithm",
    "data structure", "programming language", "html", "css", "javascript",
    "typescript", "react", "angular", "vue", "nodejs", "express",
    "mongodb", "firebase", "docker", "kubernetes", "git", "github",
    "gitlab", "bitbucket", "agile", "scrum", "kanban", "ux/ui",
    "design", "architecture", "testing", "quality assurance", "qa",
    "performance", "optimization", "scalability", "security",
    "vulnerability", "penetration testing", "ethical hacking",
    "penetration", "malware", "ransomware", "phishing", "firewall",
    "vpn", "proxy", "encryption", "decryption", "hashing",
    "ssl", "tls", "http", "https", "tcp", "udp", "ip", "dns",
    "domain", "hosting", "server", "client", "request", "response",
    "protocol", "api", "rest", "soap", "graphql", "websocket",
    "json", "xml", "yaml", "csv", "excel", "spreadsheet",
    "data visualization", "dashboard", "reporting", "business intelligence",

  ];

  /// Prompt cố định định hướng Gemini
  final String _systemPrompt = '''
Bạn là một trợ lý AI chuyên hỗ trợ các câu hỏi liên quan đến Công Nghệ Thông Tin (IT).
Chỉ trả lời các câu hỏi nằm trong phạm vi CNTT như lập trình, framework, backend, frontend, cơ sở dữ liệu, công nghệ AI, machine learning...
Nếu câu hỏi không thuộc lĩnh vực IT, hãy trả lời: "Tôi chỉ hỗ trợ các câu hỏi liên quan đến Công Nghệ Thông Tin (IT)."
Trả lời ngắn gọn, rõ ràng, và dễ hiểu cho người học hoặc người đi làm trong ngành CNTT.
''';

  Future<String> sendMessage(String message) async {
    if (_apiKey.isEmpty) {
      return "API key chưa được cấu hình!";
    }

    // Kiểm tra liên quan IT (bảo vệ trước)
    if (!_isITRelated(message)) {
      return "Tôi chỉ hỗ trợ các câu hỏi liên quan đến Công Nghệ Thông Tin (IT).";
    }

    final url = Uri.parse("$_baseUrl?key=$_apiKey");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": _systemPrompt},
              {"text": message}
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'] ??
          "Không có phản hồi.";
    } else {
      return "Lỗi API: ${response.body}";
    }
  }

  bool _isITRelated(String message) {
    final lowerMessage = message.toLowerCase();
    return _itKeywords.any((keyword) => lowerMessage.contains(keyword));
  }
}
