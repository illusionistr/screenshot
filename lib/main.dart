import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:ui' as ui;
import 'dart:ui_web' as ui_web;
import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Modern Web App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  bool _isPhoneHovered = false;
  bool _isTemplateHovered = false;

  late AnimationController _typewriterController;
  late Animation<int> _typewriterAnimation;
  final String _fullText = "Empty Slate,\nYours to fill.";
  bool _showCursor = true;

  @override
  void initState() {
    super.initState();

    // Initialize typewriter animation
    _typewriterController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _typewriterAnimation = IntTween(
      begin: 0,
      end: _fullText.length,
    ).animate(CurvedAnimation(
      parent: _typewriterController,
      curve: Curves.easeInOut,
    ));

    // Start the typewriter animation
    _typewriterController.forward();

    // Cursor blinking animation
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          _showCursor = !_showCursor;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _typewriterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Navigation Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              color: Colors.grey[100],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Colors.blue, Colors.purple],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: const Text(
                      'screensht',
                      style: TextStyle(
                        fontFamily: 'Darlington',
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2.0,
                        shadows: [
                          Shadow(
                            offset: Offset(2.0, 2.0),
                            blurRadius: 4.0,
                            color: Colors.black26,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                  Row(
                    children: [
                      // Phones Dropdown
                      MouseRegion(
                        onEnter: (_) => setState(() => _isPhoneHovered = true),
                        onExit: (_) => setState(() => _isPhoneHovered = false),
                        child: PopupMenuButton<String>(
                          position: PopupMenuPosition.under,
                          onSelected: (value) {
                            print('Selected phone: $value');
                          },
                          itemBuilder: (BuildContext context) => [
                            PopupMenuItem(
                              value: 'iphone15pro',
                              child: Container(
                                width: 280,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'iPhone 15 Pro',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Latest iPhone with titanium design',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            PopupMenuItem(
                              value: 'iphone14',
                              child: Container(
                                width: 280,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'iPhone 14',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Powerful dual-camera system',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            PopupMenuItem(
                              value: 'galaxys24',
                              child: Container(
                                width: 280,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Samsung Galaxy S24',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'AI-powered Android flagship',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            PopupMenuItem(
                              value: 'pixel8',
                              child: Container(
                                width: 280,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Google Pixel 8',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Pure Android with best camera',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: _isPhoneHovered
                                  ? Colors.blue.withOpacity(0.1)
                                  : Colors.transparent,
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Phones',
                                    style: TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Templates Dropdown
                      MouseRegion(
                        onEnter: (_) =>
                            setState(() => _isTemplateHovered = true),
                        onExit: (_) =>
                            setState(() => _isTemplateHovered = false),
                        child: PopupMenuButton<String>(
                          position: PopupMenuPosition.under,
                          onSelected: (value) {
                            print('Selected template: $value');
                          },
                          itemBuilder: (BuildContext context) => [
                            PopupMenuItem(
                              value: 'fitness',
                              child: Container(
                                width: 280,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Fitness App',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Workout tracking and health metrics',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            PopupMenuItem(
                              value: 'sports',
                              child: Container(
                                width: 280,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Sports App',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Team management and live scores',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            PopupMenuItem(
                              value: 'business',
                              child: Container(
                                width: 280,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Business App',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Professional tools and analytics',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            PopupMenuItem(
                              value: 'social',
                              child: Container(
                                width: 280,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Social App',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Connect and share with friends',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            PopupMenuItem(
                              value: 'ecommerce',
                              child: Container(
                                width: 280,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'E-commerce App',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Online store with payment gateway',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: _isTemplateHovered
                                  ? Colors.blue.withOpacity(0.1)
                                  : Colors.transparent,
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Templates',
                                    style: TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Test Button (for screenshot generator)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.transparent,
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const TestPage()),
                            );
                          },
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Test',
                                  style: TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Tutorials Button
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.transparent,
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const TutorialPage()),
                            );
                          },
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Tutorials',
                                  style: TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Hero Section
            Container(
              height: 700,
              width: double.infinity,
              color: Colors.grey[100],
              child: Row(
                children: [
                  // Left side - Image
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: 700,
                      margin: const EdgeInsets.all(10),
                      child: Image.asset(
                        'bgimage.png',
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ),
                  // Right side - Text
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: 700,
                      padding: const EdgeInsets.all(80),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedBuilder(
                            animation: _typewriterAnimation,
                            builder: (context, child) {
                              String displayText = _fullText.substring(
                                  0, _typewriterAnimation.value);
                              return RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: displayText,
                                      style: const TextStyle(
                                        fontSize: 60,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                        height: 1.2,
                                      ),
                                    ),
                                    if (_showCursor &&
                                        _typewriterAnimation.value <
                                            _fullText.length)
                                      const TextSpan(
                                        text: '|',
                                        style: TextStyle(
                                          fontSize: 60,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                          height: 1.2,
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
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
}

class TutorialPage extends StatefulWidget {
  const TutorialPage({super.key});

  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  String? _playingVideoId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Navigation Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              color: Colors.transparent,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button and logo
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon:
                            const Icon(Icons.arrow_back, color: Colors.black87),
                      ),
                      const SizedBox(width: 10),
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Colors.blue, Colors.purple],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: const Text(
                          'screensht',
                          style: TextStyle(
                            fontFamily: 'Darlington',
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    'Tutorials',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            // Main content
            Container(
              padding: const EdgeInsets.all(40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Learn Flutter & App Development',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Master mobile app development with our comprehensive video tutorials',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Tutorial videos grid
                  Column(
                    children: [
                      _buildTutorialCard(
                        'Flutter Basics - Getting Started',
                        'Learn the fundamentals of Flutter development, from setup to your first app. Perfect for beginners who want to start their mobile development journey.',
                        '15:32',
                        '127K views',
                        '2 weeks ago',
                        'WMuCZ5Ukdkc', // YouTube video ID from the provided link
                      ),
                      const SizedBox(height: 20),
                      _buildTutorialCard(
                        'Building Beautiful UIs with Flutter Widgets',
                        'Discover how to create stunning user interfaces using Flutter\'s powerful widget system. Learn about layouts, styling, and animations.',
                        '22:18',
                        '89K views',
                        '1 week ago',
                        'WMuCZ5Ukdkc', // Using the same video ID for demo
                      ),
                      const SizedBox(height: 20),
                      _buildTutorialCard(
                        'State Management in Flutter - Complete Guide',
                        'Master state management techniques including setState, Provider, Bloc, and Riverpod. Build scalable and maintainable Flutter apps.',
                        '31:45',
                        '156K views',
                        '3 weeks ago',
                        'WMuCZ5Ukdkc', // Using the same video ID for demo
                      ),
                      const SizedBox(height: 20),
                      _buildTutorialCard(
                        'Flutter Navigation & Routing',
                        'Learn how to navigate between screens, pass data, and implement advanced routing patterns in your Flutter applications.',
                        '18:27',
                        '73K views',
                        '4 days ago',
                        'WMuCZ5Ukdkc', // Using the same video ID for demo
                      ),
                      const SizedBox(height: 20),
                      _buildTutorialCard(
                        'Connecting Flutter to APIs & Databases',
                        'Integrate your Flutter app with REST APIs, Firebase, and local databases. Learn data fetching, caching, and offline capabilities.',
                        '26:54',
                        '94K views',
                        '1 week ago',
                        'WMuCZ5Ukdkc', // Using the same video ID for demo
                      ),
                      const SizedBox(height: 20),
                      _buildTutorialCard(
                        'Publishing Your Flutter App to App Stores',
                        'Complete guide to preparing, building, and publishing your Flutter app to Google Play Store and Apple App Store.',
                        '24:16',
                        '112K views',
                        '5 days ago',
                        'WMuCZ5Ukdkc', // Using the same video ID for demo
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
  }

  Widget _buildTutorialCard(
    String title,
    String description,
    String duration,
    String views,
    String timeAgo,
    String youtubeVideoId,
  ) {
    final bool isPlaying = _playingVideoId == youtubeVideoId;
    final String iframeId = 'youtube-$youtubeVideoId';

    if (isPlaying) {
      // Register the iframe for this video if not already registered
      final String videoUrl =
          'https://www.youtube.com/embed/$youtubeVideoId?autoplay=1&rel=0';
      ui_web.platformViewRegistry.registerViewFactory(
        iframeId,
        (int viewId) => html.IFrameElement()
          ..src = videoUrl
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%'
          ..allowFullscreen = true,
      );
    }
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Video thumbnail or player (left side)
          Container(
            width: 300,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              color: Colors.grey[300],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: isPlaying
                  ? HtmlElementView(
                      viewType: iframeId,
                    )
                  : GestureDetector(
                      onTap: () {
                        setState(() {
                          _playingVideoId = youtubeVideoId;
                        });
                      },
                      child: Stack(
                        children: [
                          // Placeholder for video thumbnail
                          Container(
                            width: double.infinity,
                            height: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.blue.withOpacity(0.8),
                                  Colors.purple.withOpacity(0.8),
                                ],
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.play_circle_filled,
                                color: Colors.white,
                                size: 60,
                              ),
                            ),
                          ),
                          // Duration badge
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                duration,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),

          // Content (right side)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.visibility, color: Colors.grey[600], size: 16),
                      const SizedBox(width: 4),
                      Text(
                        views,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.access_time,
                          color: Colors.grey[600], size: 16),
                      const SizedBox(width: 4),
                      Text(
                        timeAgo,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _playingVideoId = isPlaying ? null : youtubeVideoId;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isPlaying ? Colors.grey : Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(isPlaying ? Icons.stop : Icons.play_arrow,
                            size: 16),
                        const SizedBox(width: 4),
                        Text(isPlaying ? 'Stop Video' : 'Watch Now'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  List<PlatformFile> uploadedFiles = [];
  Uint8List? selectedImageBytes;
  String? selectedDevice = 'iPhone 15 Pro';
  String selectedBackground = 'gradient';

  // Text controller for proper state management
  late TextEditingController mainTextController;

  // Draggable positions
  Offset phonePosition = const Offset(0, 0);
  Offset textPosition = const Offset(20, 50);

  @override
  void initState() {
    super.initState();
    mainTextController = TextEditingController(text: 'Your App Name');
  }

  @override
  void dispose() {
    mainTextController.dispose();
    super.dispose();
  }

  // Map device names to their asset paths
  String getDeviceFramePath(String deviceName) {
    switch (deviceName) {
      case 'iPhone 15 Pro':
        return 'apple-iphone-15-black-mockup/portrait.png';
      case 'Google Pixel 8':
        return 'google-pixel-8-obsidian-mockup/portrait.png';
      case 'Samsung Galaxy S24 Ultra':
        return 'galaxy-s24ultra-mockup/portrait.png';
      case 'iPad Pro 13':
        return 'apple-ipadpro13-spacegrey-mockup/portrait.png';
      default:
        return 'apple-iphone-15-black-mockup/portrait.png';
    }
  }

  // Get screen width for each device (approximate dimensions to fit within the frame)
  double _getScreenWidth(String deviceName) {
    switch (deviceName) {
      case 'iPhone 15 Pro':
        return 185;
      case 'Google Pixel 8':
        return 195; // Increased from 180
      case 'Samsung Galaxy S24 Ultra':
        return 170; // Decreased from 190
      case 'iPad Pro 13':
        return 250; // Increased from 220
      default:
        return 185;
    }
  }

  // Get screen height for each device (approximate dimensions to fit within the frame)
  double _getScreenHeight(String deviceName) {
    switch (deviceName) {
      case 'iPhone 15 Pro':
        return 400;
      case 'Google Pixel 8':
        return 410; // Increased from 380
      case 'Samsung Galaxy S24 Ultra':
        return 370; // Decreased from 410
      case 'iPad Pro 13':
        return 340; // Increased from 290
      default:
        return 400;
    }
  }

  // Get border radius for each device screen
  double _getScreenBorderRadius(String deviceName) {
    switch (deviceName) {
      case 'iPhone 15 Pro':
        return 25;
      case 'Google Pixel 8':
        return 20;
      case 'Samsung Galaxy S24 Ultra':
        return 22;
      case 'iPad Pro 13':
        return 15;
      default:
        return 25;
    }
  }

  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true,
    );

    if (result != null) {
      setState(() {
        uploadedFiles.addAll(result.files);
        if (uploadedFiles.isNotEmpty && selectedImageBytes == null) {
          selectedImageBytes = uploadedFiles.first.bytes;
        }
      });
    }
  }

  void _selectImage(PlatformFile file) {
    setState(() {
      selectedImageBytes = file.bytes;
    });
  }

  void _removeImage(int index) {
    setState(() {
      if (uploadedFiles[index].bytes == selectedImageBytes &&
          uploadedFiles.length > 1) {
        selectedImageBytes =
            uploadedFiles.where((f) => f != uploadedFiles[index]).first.bytes;
      } else if (uploadedFiles.length == 1) {
        selectedImageBytes = null;
      }
      uploadedFiles.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Navigation Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              color: Colors.grey[100],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button and logo
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon:
                            const Icon(Icons.arrow_back, color: Colors.black87),
                      ),
                      const SizedBox(width: 10),
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Colors.blue, Colors.purple],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: const Text(
                          'screensht',
                          style: TextStyle(
                            fontFamily: 'Darlington',
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    'Screenshot Generator',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            // Main Content
            Padding(
              padding: const EdgeInsets.all(40),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Panel - Controls
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Upload Screenshots',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Upload Area
                          GestureDetector(
                            onTap: _pickFiles,
                            child: Container(
                              width: double.infinity,
                              height: uploadedFiles.isEmpty ? 200 : 150,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.blue.withOpacity(0.3),
                                  width: 2,
                                  style: BorderStyle.solid,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.blue.withOpacity(0.05),
                              ),
                              child: uploadedFiles.isEmpty
                                  ? const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.cloud_upload,
                                          size: 48,
                                          color: Colors.blue,
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          'Drag & drop your screenshots',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'or click to browse files',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                '${uploadedFiles.length} file(s) uploaded',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: _pickFiles,
                                                child: const Text('Add More'),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: ListView.builder(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8),
                                            itemCount: uploadedFiles.length,
                                            itemBuilder: (context, index) {
                                              final file = uploadedFiles[index];
                                              final isSelected = file.bytes ==
                                                  selectedImageBytes;
                                              return Container(
                                                margin: const EdgeInsets.only(
                                                    bottom: 4),
                                                decoration: BoxDecoration(
                                                  color: isSelected
                                                      ? Colors.blue
                                                          .withOpacity(0.1)
                                                      : Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  border: isSelected
                                                      ? Border.all(
                                                          color: Colors.blue,
                                                          width: 2)
                                                      : null,
                                                ),
                                                child: ListTile(
                                                  dense: true,
                                                  leading: Container(
                                                    width: 40,
                                                    height: 40,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4),
                                                      color: Colors.grey[200],
                                                    ),
                                                    child: file.bytes != null
                                                        ? Image.memory(
                                                            file.bytes!,
                                                            fit: BoxFit.cover,
                                                          )
                                                        : const Icon(
                                                            Icons.image,
                                                            color: Colors.grey),
                                                  ),
                                                  title: Text(
                                                    file.name,
                                                    style: const TextStyle(
                                                        fontSize: 12),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  subtitle: Text(
                                                    '${(file.size / 1024).toStringAsFixed(1)} KB',
                                                    style: const TextStyle(
                                                        fontSize: 10),
                                                  ),
                                                  trailing: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      if (!isSelected)
                                                        IconButton(
                                                          icon: const Icon(
                                                              Icons.visibility,
                                                              size: 16),
                                                          onPressed: () =>
                                                              _selectImage(
                                                                  file),
                                                          tooltip: 'Preview',
                                                        ),
                                                      IconButton(
                                                        icon: const Icon(
                                                            Icons.delete,
                                                            size: 16,
                                                            color: Colors.red),
                                                        onPressed: () =>
                                                            _removeImage(index),
                                                        tooltip: 'Remove',
                                                      ),
                                                    ],
                                                  ),
                                                  onTap: () =>
                                                      _selectImage(file),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Device Selection
                          const Text(
                            'Device Frame',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 10),
                          DropdownButton<String>(
                            isExpanded: true,
                            value: selectedDevice,
                            items: const [
                              DropdownMenuItem(
                                  value: 'iPhone 15 Pro',
                                  child: Text('iPhone 15 Pro')),
                              DropdownMenuItem(
                                  value: 'Google Pixel 8',
                                  child: Text('Google Pixel 8')),
                              DropdownMenuItem(
                                  value: 'Samsung Galaxy S24 Ultra',
                                  child: Text('Samsung Galaxy S24 Ultra')),
                              DropdownMenuItem(
                                  value: 'iPad Pro 13',
                                  child: Text('iPad Pro 13')),
                            ],
                            onChanged: (value) =>
                                setState(() => selectedDevice = value),
                          ),

                          const SizedBox(height: 30),

                          // Background Selection
                          const Text(
                            'Background',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Column(
                            children: [
                              RadioListTile<String>(
                                title: const Text('Blue Gradient'),
                                value: 'gradient',
                                groupValue: selectedBackground,
                                onChanged: (value) =>
                                    setState(() => selectedBackground = value!),
                              ),
                              RadioListTile<String>(
                                title: const Text('Solid Color'),
                                value: 'solid',
                                groupValue: selectedBackground,
                                onChanged: (value) =>
                                    setState(() => selectedBackground = value!),
                              ),
                              RadioListTile<String>(
                                title: const Text('Custom Image'),
                                value: 'custom',
                                groupValue: selectedBackground,
                                onChanged: (value) =>
                                    setState(() => selectedBackground = value!),
                              ),
                            ],
                          ),

                          const SizedBox(height: 30),

                          // Text Input
                          const Text(
                            'Text Overlay',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: mainTextController,
                            decoration: const InputDecoration(
                              labelText: 'Main Title',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 40),

                  // Right Panel - Preview
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Preview',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Preview Area
                          Container(
                            width: double.infinity,
                            height: 500,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              gradient: selectedBackground == 'gradient'
                                  ? const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [Colors.blue, Colors.purple],
                                    )
                                  : null,
                              color: selectedBackground == 'solid'
                                  ? Colors.blue
                                  : null,
                            ),
                            child: Stack(
                              children: [
                                // Draggable Device Frame with Screenshot
                                Positioned(
                                  left: phonePosition.dx,
                                  top: phonePosition.dy,
                                  child: GestureDetector(
                                    onPanUpdate: (details) {
                                      setState(() {
                                        phonePosition += details.delta;
                                      });
                                    },
                                    child: Container(
                                      width: 300,
                                      height: 450,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          // Device Frame
                                          Image.asset(
                                            getDeviceFramePath(selectedDevice!),
                                            fit: BoxFit.contain,
                                            width: 300,
                                            height: 450,
                                          ),
                                          // Screenshot positioned inside frame
                                          if (selectedImageBytes != null)
                                            Container(
                                              width: _getScreenWidth(
                                                  selectedDevice!),
                                              height: _getScreenHeight(
                                                  selectedDevice!),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        _getScreenBorderRadius(
                                                            selectedDevice!)),
                                                child: Image.memory(
                                                  selectedImageBytes!,
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                ),
                                              ),
                                            )
                                          else
                                            Container(
                                              width: _getScreenWidth(
                                                  selectedDevice!),
                                              height: _getScreenHeight(
                                                  selectedDevice!),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        _getScreenBorderRadius(
                                                            selectedDevice!)),
                                              ),
                                              child: const Center(
                                                child: Text(
                                                  'Your Screenshot\nWill Appear Here',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                // Draggable Text Overlay
                                Positioned(
                                  left: textPosition.dx,
                                  top: textPosition.dy,
                                  child: GestureDetector(
                                    onPanUpdate: (details) {
                                      setState(() {
                                        textPosition += details.delta;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        color: Colors.black.withOpacity(0.1),
                                      ),
                                      child: Text(
                                        mainTextController.text,
                                        style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          shadows: [
                                            Shadow(
                                              offset: Offset(1, 1),
                                              blurRadius: 3,
                                              color: Colors.black54,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Export Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // TODO: Implement export functionality
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Export functionality coming soon!')),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.download),
                                  SizedBox(width: 8),
                                  Text(
                                    'Export High-Res Image',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
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
}
