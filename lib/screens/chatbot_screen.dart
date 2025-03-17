import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Replace these with your actual imports.
import 'package:guidera_app/theme/app_colors.dart';
import 'package:guidera_app/widgets/header.dart';
import 'package:guidera_app/screens/profile_dashboard_screen.dart'; // Make sure this is the correct path

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

/// Clipper for a WhatsApp-like bubble with a tail.
/// The tail side does NOT have a curved corner, making it look naturally attached.
class WhatsAppBubbleClipper extends CustomClipper<Path> {
  final bool isUser; // If true => tail on bottom-right, else bottom-left.

  WhatsAppBubbleClipper({required this.isUser});

  @override
  Path getClip(Size size) {
    final double r = 10; // Corner radius
    final double tailSize = 6; // Size of the tail
    final double w = size.width;
    final double h = size.height;

    final path = Path();

    if (isUser) {
      // Bubble with tail on the bottom-right.
      path.moveTo(r, 0);
      path.lineTo(w - r, 0);
      path.quadraticBezierTo(w, 0, w, r);
      path.lineTo(w, h - tailSize);
      // Draw tail (attached, not curved).
      path.lineTo(w - 5, h);
      path.lineTo(w - 10, h - tailSize);
      path.lineTo(r, h - tailSize);
      path.quadraticBezierTo(0, h - tailSize, 0, h - r - tailSize);
      path.lineTo(0, r);
      path.quadraticBezierTo(0, 0, r, 0);
      path.close();
    } else {
      // Bubble with tail on the bottom-left.
      path.moveTo(r, 0);
      path.lineTo(w - r, 0);
      path.quadraticBezierTo(w, 0, w, r);
      path.lineTo(w, h - r - tailSize);
      path.quadraticBezierTo(w, h - tailSize, w - r, h - tailSize);
      path.lineTo(tailSize, h - tailSize);
      // Draw tail (attached, not curved).
      path.lineTo(5, h);
      path.lineTo(0, h - tailSize);
      path.lineTo(0, r);
      path.quadraticBezierTo(0, 0, r, 0);
      path.close();
    }
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

/// A widget that clips text into a WhatsApp-like bubble with a connected tail.
class WhatsAppBubble extends StatelessWidget {
  final String text;
  final bool isUser;

  const WhatsAppBubble({
    Key? key,
    required this.text,
    required this.isUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isUser ? AppColors.darkBlue : AppColors.myWhite;
    final textColor = isUser ? AppColors.myWhite : AppColors.myBlack;

    return ClipPath(
      clipper: WhatsAppBubbleClipper(isUser: isUser),
      child: Container(
        color: bubbleColor,
        // Symmetrical padding so text doesn't stick to edges.
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        // Constrain max width so bubble grows vertically for long text.
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

/// A custom widget that continuously cycles through a list of messages using a typewriter animation.
/// It types the message letter-by-letter, pauses, then removes the text before moving to the next message.
class CyclicTypewriterText extends StatefulWidget {
  final List<String> texts;
  final TextStyle style;
  final Duration letterDuration;
  final Duration initialDelay;
  final Duration pauseDuration;

  const CyclicTypewriterText({
    Key? key,
    required this.texts,
    required this.style,
    this.letterDuration = const Duration(milliseconds: 100),
    this.initialDelay = const Duration(milliseconds: 500),
    this.pauseDuration = const Duration(milliseconds: 1000),
  }) : super(key: key);

  @override
  _CyclicTypewriterTextState createState() => _CyclicTypewriterTextState();
}

class _CyclicTypewriterTextState extends State<CyclicTypewriterText> {
  String _currentDisplay = "";
  int _currentTextIndex = 0;

  @override
  void initState() {
    super.initState();
    _startTypingLoop();
  }

  Future<void> _startTypingLoop() async {
    const typingDuration = Duration(milliseconds: 100);
    while (mounted) {
      final text = widget.texts[_currentTextIndex];
      // Phase 1: Clear text.
      setState(() {
        _currentDisplay = "";
      });
      await Future.delayed(widget.initialDelay);
      // Phase 2: Type out text letter-by-letter.
      for (int i = 1; i <= text.length; i++) {
        if (!mounted) return;
        setState(() {
          _currentDisplay = text.substring(0, i);
        });
        await Future.delayed(typingDuration);
      }
      // Phase 3: Pause with full text visible.
      await Future.delayed(widget.pauseDuration);
      // Phase 4: Delete text letter-by-letter.
      for (int i = text.length; i >= 0; i--) {
        if (!mounted) return;
        setState(() {
          _currentDisplay = text.substring(0, i);
        });
        await Future.delayed(typingDuration);
      }
      // Phase 5: Pause before next text.
      await Future.delayed(widget.initialDelay);
      _currentTextIndex = (_currentTextIndex + 1) % widget.texts.length;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(_currentDisplay, style: widget.style);
  }
}

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({Key? key}) : super(key: key);

  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];

  // Sample FAQ list.
  final List<Map<String, String>> _faqs = [
    {
      'question': 'How does Guidera recommend universities?',
      'answer':
      'Guidera uses your academic scores, preferences, and personality insights to generate personalized recommendations.'
    },
    {
      'question': 'Can Guidera help me with deadlines?',
      'answer':
      'Yes, Guidera provides automated alerts for all important admission deadlines.'
    },
    {
      'question': 'What data does Guidera provide?',
      'answer': 'You get details like fee structure, admission dates, courses, and more.'
    },
    {
      'question': 'How does Guidera help with test preparation?',
      'answer':
      'Guidera offers mock tests and visualizes your results to help you prepare effectively.'
    },
  ];

  /// Scrolls the chat list to the bottom.
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

  /// Hides the animated text by triggering a rebuild.
  void _hideAnimatedText() {
    if (_messages.isNotEmpty) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Dark background gradient.
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
            // Header area: Stack with GuideraHeader, back button (using back.svg) & profile (right).
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
                Positioned(
                  left: 339,
                  top: 70,
                  //padding: const EdgeInsets.only(right: 16.0),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UserProfileScreen(),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(25),
                    child: CircleAvatar(
                      radius: 25,
                      backgroundImage: NetworkImage(
                          "https://avatars.githubusercontent.com/u/168419532?v=4"
                      ),
                      backgroundColor: AppColors.darkBlue,
                    ),
                  ),
                ),
              ],
            ),

            // Main conversation area with a Stack overlay.
            Expanded(
              child: Stack(
                children: [
                  // List of FAQs and chat messages.
                  ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    itemCount: _messages.length + 1, // Extra for FAQ section.
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _buildFAQSection();
                      }
                      final msgIndex = index - 1;
                      final message = _messages[msgIndex];
                      return _buildMessageRow(message);
                    },
                  ),
                  // Animated cyclic typewriter text overlay (shown only when there are no messages).
                  if (_messages.isEmpty)
                    Center(
                      child: CyclicTypewriterText(
                        texts: const [
                          "What can I help with?",
                          "How can I assist you?",
                          "Need any help?"
                        ],
                        style: const TextStyle(
                          color: AppColors.myWhite,
                          fontSize: 27,
                          fontWeight: FontWeight.bold,
                        ),
                        letterDuration: const Duration(milliseconds: 100),
                        initialDelay: const Duration(milliseconds: 500),
                        pauseDuration: const Duration(milliseconds: 1000),
                      ),
                    ),
                ],
              ),
            ),

            // Bottom input container with curved top corners.
            Container(
              decoration: const BoxDecoration(
                color: AppColors.myBlack,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 55,
                      decoration: BoxDecoration(
                        color: AppColors.lightGray,
                        borderRadius: BorderRadius.circular(70),
                      ),
                      child: Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          TextField(
                            controller: _messageController,
                            textAlign: TextAlign.justify,
                            textAlignVertical: TextAlignVertical.center,
                            style: const TextStyle(
                              fontFamily: 'Product Sans',
                              fontSize: 15,
                              color: AppColors.myBlack,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(left: 15, top: 4, bottom: 8),
                              hintText: 'Type your message...',
                              hintStyle: TextStyle(
                                fontFamily: 'Product Sans',
                                fontWeight: FontWeight.normal,
                                color: AppColors.lightBlack,
                                fontSize: 15,
                              ),
                            ),
                            onChanged: (text) {
                              if (text.trim().isNotEmpty) _hideAnimatedText();
                            },
                          ),
                          Positioned(
                            right: 0,
                            child: Container(
                              height: 35,
                              margin: const EdgeInsets.only(right: 14),
                              decoration: BoxDecoration(
                                color: AppColors.lightBlue,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: IconButton(
                                icon: SvgPicture.asset(
                                  'assets/images/send.svg',
                                  width: 20,
                                  color: AppColors.myWhite,
                                ),
                                onPressed: _handleSend,
                              ),
                            ),
                          ),
                        ],
                      ),
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

  /// Builds the FAQ section at the top.
  Widget _buildFAQSection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Text(
              "FAQs",
              style: TextStyle(
                color: AppColors.myWhite,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 106,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              itemCount: _faqs.length,
              itemBuilder: (context, index) {
                final faq = _faqs[index];
                return GestureDetector(
                  onTap: () => _handleFaqTap(faq['question']!, faq['answer']!),
                  child: Card(
                    color: AppColors.lightGray,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    margin: const EdgeInsets.only(right: 10),
                    child: Container(
                      width: 200,
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Text(
                          faq['question']!,
                          style: const TextStyle(
                            color: AppColors.darkBlack,
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a chat message row with a WhatsApp-style bubble.
  Widget _buildMessageRow(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
        message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          WhatsAppBubble(
            text: message.text,
            isUser: message.isUser,
          ),
        ],
      ),
    );
  }

  /// Handles FAQ tap: adds the user's question and then simulates a bot response.
  void _handleFaqTap(String question, String answer) {
    setState(() {
      _messages.add(ChatMessage(text: question, isUser: true));
      _messages.add(ChatMessage(text: "Thinking...", isUser: false, isTyping: true));
    });
    _scrollToBottom();
    final int botMessageIndex = _messages.length - 1;
    Future.delayed(const Duration(seconds: 1), () {
      _simulateTyping(answer, botMessageIndex);
    });
  }

  /// Handles the send button press: adds the user's message and simulates a bot response.
  void _handleSend() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _messageController.clear();
      _messages.add(ChatMessage(text: "Thinking...", isUser: false, isTyping: true));
    });
    _scrollToBottom();
    final int botMessageIndex = _messages.length - 1;
    Future.delayed(const Duration(seconds: 1), () {
      _simulateTyping("I'm processing your query...", botMessageIndex);
    });
  }

  /// Simulates the bot typing letter-by-letter.
  void _simulateTyping(String fullResponse, int messageIndex) {
    int currentIndex = 0;
    Timer.periodic(const Duration(milliseconds: 40), (timer) {
      if (currentIndex < fullResponse.length) {
        setState(() {
          _messages[messageIndex].text = fullResponse.substring(0, currentIndex + 1);
        });
        currentIndex++;
        _scrollToBottom();
      } else {
        timer.cancel();
        setState(() {
          _messages[messageIndex].isTyping = false;
        });
        _scrollToBottom();
      }
    });
  }
}
