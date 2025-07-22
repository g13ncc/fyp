import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'firebase_service.dart';
import 'auth_page.dart';

// Conditional imports
import 'mobile_chatbot.dart' if (dart.library.html) 'web_chatbot.dart';
import 'all_posts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'gensecure',
      theme: ThemeData(
        primarySwatch: MaterialColor(0xFFB91C1C, {
          50: Color(0xFFFEF2F2),
          100: Color(0xFFFEE2E2),
          200: Color(0xFFFECACA),
          300: Color(0xFFFCA5A5),
          400: Color(0xFFF87171),
          500: Color(0xFFEF4444),
          600: Color(0xFFDC2626),
          700: Color(0xFFB91C1C),
          800: Color(0xFF991B1B),
          900: Color(0xFF7F1D1D),
        }),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFFB91C1C),
          brightness: Brightness.light,
        ).copyWith(
          primary: Color(0xFFB91C1C),
          secondary: Color(0xFFFFFFFF),
          surface: Color(0xFFF5F5F5),
        ),
        useMaterial3: true,
        fontFamily: kIsWeb ? 'Roboto' : null,
        textTheme: TextTheme(
          headlineLarge: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFB91C1C),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            elevation: 2,
          ),
        ),
      ),
      home: StreamBuilder(
        stream: FirebaseService.authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          
          if (snapshot.hasData) {
            // User is logged in
            return AllPostsPage();
          } else {
            // User is not logged in
            return AuthPage();
          }
        },
      ),
    );
  }
}

// Chatbot Page
class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  _ChatbotPageState createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final String chatbotUrl = 'https://cdn.botpress.cloud/webchat/v3.1/shareable.html?configUrl=https://files.bpcontent.cloud/2025/07/18/03/20250718032958-GW87XLAX.json';
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    // Simulate loading time for better UX
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text('🤖 Chat with Agent'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: Colors.black),
            onPressed: () {
              setState(() {
                isLoading = true;
                errorMessage = null;
              });
              Future.delayed(Duration(seconds: 1), () {
                if (mounted) {
                  setState(() {
                    isLoading = false;
                  });
                }
              });
            },
            tooltip: 'Refresh Chat',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xFFF5F5F5),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB91C1C)),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Loading AI Assistant...',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 48,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Failed to load chatbot',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                errorMessage!,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    isLoading = true;
                                    errorMessage = null;
                                  });
                                  Future.delayed(Duration(seconds: 1), () {
                                    if (mounted) {
                                      setState(() {
                                        isLoading = false;
                                      });
                                    }
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFFB91C1C),
                                ),
                                child: Text('Retry', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        )
                      : ChatbotWidget(chatbotUrl: chatbotUrl),
            ),
          ),
        ),
      ),
    );
  }
}
