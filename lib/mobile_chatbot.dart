// Mobile-specific implementation
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ChatbotWidget extends StatefulWidget {
  final String chatbotUrl;
  
  const ChatbotWidget({super.key, required this.chatbotUrl});

  @override
  State<ChatbotWidget> createState() => _ChatbotWidgetState();
}

class _ChatbotWidgetState extends State<ChatbotWidget> {
  late final WebViewController _controller;

  @override
  @override
  void initState() {
    super.initState();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..clearCache()
      ..clearLocalStorage()
      ..loadRequest(Uri.parse('${widget.chatbotUrl}&t=$timestamp'));
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
  
  void refresh() {
    _controller.reload();
  }
}
