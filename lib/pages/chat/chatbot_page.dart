import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/message_model.dart';
import '../../services/chatbot_service.dart';

class Chatbot extends StatefulWidget {
  @override
  _ChatbotState createState() => _ChatbotState();
}

class _ChatbotState extends State<Chatbot> {
  final TextEditingController _controller = TextEditingController();
  final List<Message> messages = [];
  final ChatbotService _chatbotService = ChatbotService();
  final ScrollController _scrollController = ScrollController();
  PlatformFile? _selectedCV;

  List<String> suggestedTopics = [
    "Flutter là gì?",
    "Sự khác nhau giữa frontend và backend?",
    "AI và Machine Learning khác nhau như thế nào?",
    "Cách sử dụng API trong mobile app?",
    "Học DevOps bắt đầu từ đâu?",
    "SQL là gì?",
    "Làm sao để học lập trình nhanh?",
    "Python có khó không?",
    "Framework phổ biến cho backend?",
    "Tại sao nên học công nghệ thông tin?"
  ];

  Future<void> _sendMessage() async {
    if (_controller.text.isEmpty && _selectedCV == null) return;

    String userMessage = _controller.text;
    _controller.clear();

    setState(() {
      messages.add(Message(
        text: _selectedCV != null ? '[Đã gửi CV: ${_selectedCV!.name}]' : userMessage,
        isUser: true,
      ));
    });

    _scrollToBottom();

    // Gửi đến ChatbotService
    String botReply;
    if (_selectedCV != null) {
      botReply = await _chatbotService.analyzeCV(_selectedCV!);
      _selectedCV = null;
    } else {
      botReply = await _chatbotService.sendMessage(userMessage);
    }

    setState(() {
      messages.add(Message(text: botReply, isUser: false));
    });

    _scrollToBottom();
  }

  Future<void> _pickCVFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedCV = result.files.first;
      });
    }
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 300), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  List<Widget> _buildSuggestedTopics() {
    return suggestedTopics.map((topic) {
      return Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: ActionChip(
          label: Text(topic),
          backgroundColor: Colors.green.shade100,
          labelStyle: TextStyle(color: Colors.green.shade800),
          onPressed: () {
            _controller.text = topic;
            _sendMessage();
          },
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "ChatBot AI",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green.shade600,
        elevation: 4,
        iconTheme: IconThemeData(color: Colors.white),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 10),
              children: _buildSuggestedTopics(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(10),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                bool isUser = messages[index].isUser;
                return _buildMessageBubble(messages[index].text, isUser);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser)
            CircleAvatar(
              backgroundColor: Colors.green,
              child: Icon(Icons.smart_toy, color: Colors.white),
            ),
          Flexible(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
              padding: const EdgeInsets.all(12),
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75),
              decoration: BoxDecoration(
                color: isUser ? Colors.green : Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: isUser ? Colors.white : Colors.black87,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          if (isUser)
            CircleAvatar(
              backgroundColor: Colors.green,
              child: Icon(Icons.person, color: Colors.white),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_selectedCV != null)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade300),
            ),
            child: Row(
              children: [
                const Icon(Icons.description, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _selectedCV!.name,
                    style: const TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _selectedCV = null;
                    });
                  },
                )
              ],
            ),
          ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.upload_file, color: Colors.green),
                onPressed: _pickCVFile,
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: "type a message or upload CV...",
                    border: InputBorder.none,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: Colors.green, size: 28),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
