import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:guidera_app/theme/app_colors.dart';
import 'package:guidera_app/widgets/header.dart';
import 'package:guidera_app/services/api_service.dart';

/// A single chat message (user or bot).
class ChatMessage {
  String text;
  final bool isUser;
  bool isTyping;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.isTyping = false,
  });
}

/// Clipper for WhatsApp-like bubble with a tail.
class WhatsAppBubbleClipper extends CustomClipper<Path> {
  final bool isUser;
  WhatsAppBubbleClipper({required this.isUser});

  @override
  Path getClip(Size size) {
    final r = 10.0, tail = 6.0;
    final w = size.width, h = size.height;
    final path = Path();
    if (isUser) {
      path.moveTo(r, 0);
      path.lineTo(w - r, 0);
      path.quadraticBezierTo(w, 0, w, r);
      path.lineTo(w, h - tail);
      path.lineTo(w - 5, h);
      path.lineTo(w - 10, h - tail);
      path.lineTo(r, h - tail);
      path.quadraticBezierTo(0, h - tail, 0, h - r - tail);
      path.lineTo(0, r);
      path.quadraticBezierTo(0, 0, r, 0);
    } else {
      path.moveTo(r, 0);
      path.lineTo(w - r, 0);
      path.quadraticBezierTo(w, 0, w, r);
      path.lineTo(w, h - r - tail);
      path.quadraticBezierTo(w, h - tail, w - r, h - tail);
      path.lineTo(tail, h - tail);
      path.lineTo(5, h);
      path.lineTo(0, h - tail);
      path.lineTo(0, r);
      path.quadraticBezierTo(0, 0, r, 0);
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> old) => false;
}

/// Bubble widget.
class WhatsAppBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  const WhatsAppBubble({Key? key, required this.text, required this.isUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bg = isUser ? AppColors.darkBlue : AppColors.myWhite;
    final color = isUser ? AppColors.myWhite : AppColors.myBlack;
    return ClipPath(
      clipper: WhatsAppBubbleClipper(isUser: isUser),
      child: Container(
        color: bg,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        child: Text(text, style: TextStyle(color: color, fontSize: 16)),
      ),
    );
  }
}

/// Animated prompt when no messages present.
class CyclicTypewriterText extends StatefulWidget {
  final List<String> texts;
  final TextStyle style;
  const CyclicTypewriterText({Key? key, required this.texts, required this.style}) : super(key: key);

  @override
  _CyclicTypewriterTextState createState() => _CyclicTypewriterTextState();
}

class _CyclicTypewriterTextState extends State<CyclicTypewriterText> {
  String display = '';
  int idx = 0;

  @override
  void initState() {
    super.initState();
    _loop();
  }

  Future<void> _loop() async {
    while (mounted) {
      final text = widget.texts[idx];
      for (int i = 0; i <= text.length; i++) {
        setState(() => display = text.substring(0, i));
        await Future.delayed(const Duration(milliseconds: 100));
      }
      await Future.delayed(const Duration(milliseconds: 1000));
      for (int i = text.length; i >= 0; i--) {
        setState(() => display = text.substring(0, i));
        await Future.delayed(const Duration(milliseconds: 100));
      }
      idx = (idx + 1) % widget.texts.length;
    }
  }

  @override
  Widget build(BuildContext context) => Text(display, style: widget.style, textAlign: TextAlign.center);
}

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({Key? key}) : super(key: key);

  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final ApiService api = ApiService();
  final TextEditingController ctrl = TextEditingController();
  final ScrollController scrollCtrl = ScrollController();
  final FocusNode focusNode = FocusNode();
  final List<ChatMessage> messages = [];

  final List<String> prompts = [
    "What is Guidera?",
    "How does Guidera recommend degrees?",
    "Do you recommend universities or degrees?",
    "What university information does Guidera provide?",
    "How can I track my application process?",
    "Are my applications submitted automatically?",
    "How does entry test preparation work?",
    "What kind of notifications will I receive?",
    "Can I get help with career or academic questions?",
    "Is Guidera’s university data kept up to date?"
  ];
  List<String> suggestions = [];

  void _scrollDown() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollCtrl.hasClients) {
        scrollCtrl.animateTo(scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _send(String text) async {
    setState(() {
      suggestions.clear();
      messages.add(ChatMessage(text: text, isUser: true));
      messages.add(ChatMessage(text: 'Thinking...', isUser: false, isTyping: true));
    });
    _scrollDown();
    final idx = messages.length - 1;
    try {
      final resp = await api.sendMessage(text);
      _type(resp, idx);
    } catch (_) {
      setState(() {
        messages[idx].isTyping = false;
        messages[idx].text = 'Failed to load response.';
      });
    }
  }

  void _type(String full, int i) {
    int c = 0;
    Timer.periodic(const Duration(milliseconds: 30), (t) {
      if (c < full.length) {
        setState(() => messages[i].text = full.substring(0, c + 1));
        c++;
        _scrollDown();
      } else {
        t.cancel();
        setState(() => messages[i].isTyping = false);
      }
    });
  }

  void _onChanged(String text) {
    if (text.isEmpty) {
      setState(() => suggestions.clear());
    } else {
      final query = text.toLowerCase();
      setState(() {
        suggestions = prompts
            .where((p) => p.toLowerCase().contains(query))
            .toList();
      });
    }
  }

  void _onSend() {
    final text = ctrl.text.trim();
    if (text.isEmpty) return;
    ctrl.clear();
    _send(text);
  }

  @override
  void dispose() {
    ctrl.dispose();
    scrollCtrl.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.myBlack, AppColors.myBlack],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Stack(
              children: [
                const GuideraHeader(),
                Positioned(
                  left: 16,
                  top: 79,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: SvgPicture.asset(
                      'assets/images/back.svg',
                      height: 30,
                      color: AppColors.myWhite,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: messages.isEmpty
                  ? Center(
                child: CyclicTypewriterText(
                  texts: const [
                    'What can I help with?',
                    'How can I assist you?',
                    'Need any help?'
                  ],
                  style: const TextStyle(
                    color: AppColors.myWhite,
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
                  : ListView.builder(
                controller: scrollCtrl,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: msg.isUser
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        WhatsAppBubble(
                          text: msg.text,
                          isUser: msg.isUser,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Input & suggestions
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Suggestions dropdown
                if (suggestions.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.myWhite,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    constraints: BoxConstraints(maxHeight: 200),
                    child: Scrollbar(
                      child: ListView.separated(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: suggestions.length,
                        separatorBuilder: (_, __) => Divider(
                            color: AppColors.lightBlack, height: 1),
                        itemBuilder: (context, i) {
                          final s = suggestions[i];
                          return InkWell(
                            onTap: () {
                              ctrl.text = s;
                              setState(() => suggestions.clear());
                              _onSend();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text(s,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      color: AppColors.myBlack)),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.lightGray,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: TextField(
                            focusNode: focusNode,
                            controller: ctrl,
                            onChanged: _onChanged,
                            style: const TextStyle(
                                fontSize: 15, color: AppColors.myBlack),
                            decoration: InputDecoration(
                              hintText: 'Type your message...',
                              hintStyle: const TextStyle(
                                  color: AppColors.lightBlack),
                              contentPadding:
                              const EdgeInsets.symmetric(horizontal: 20),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: AppColors.lightBlue,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.lightBlue.withOpacity(0.5),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: SvgPicture.asset('assets/images/send.svg',
                              width: 24, color: AppColors.myWhite),
                          onPressed: _onSend,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
