import 'dart:async';
import 'package:allen/screens/SettingsPage.dart';
import 'package:allen/widgets/feature_box.dart';
import 'package:allen/services/openai_service.dart';
import 'package:allen/widgets/pallete.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'TermsOfServices.dart';

//Uses speech_to_text package for speech recognition
//Uses flutter_tts for text-to-speech responses

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // State Variables
  final speechToText = SpeechToText();
  final flutterTts = FlutterTts();
  final OpenAIService openAIService = OpenAIService();

  String lastWords = '';
  String? generatedContent;
  String? generatedImageUrl;
  String _realTimeTranscription = '';
  double _soundLevel = 0.0;

  Timer? _silenceTimer;
  final int start = 200;
  final int delay = 200;

  // Initialization Methods
  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    await initTextToSpeech();
    await initSpeechToText();
  }

  Future<void> initTextToSpeech() async {
    await flutterTts.setSharedInstance(true);
    setState(() {});
  }

  Future<void> initSpeechToText() async {
    await speechToText.initialize();
    setState(() {});
  }

  // Speech Control Methods
  Future<void> toggleListening() async {
    if (speechToText.isListening) {
      await stopListening();
    } else {
      if (await speechToText.hasPermission && speechToText.isNotListening) {
        await startListening();
      } else if (!speechToText.isAvailable) {
        initSpeechToText();
      }
    }
  }

  Future<void> startListening() async {
    setState(() {
      _realTimeTranscription = '';
      lastWords = '';
    });

    await speechToText.listen(
      onResult: _handleSpeechResult,
      listenFor: const Duration(minutes: 5),
      pauseFor: const Duration(seconds: 3),
      onSoundLevelChange: (level) => setState(() => _soundLevel = level ?? 0),
    );
  }

  void _handleSpeechResult(SpeechRecognitionResult result) async {
    setState(() {
      if (!result.finalResult) {
        _realTimeTranscription = result.recognizedWords;
      } else {
        lastWords = result.recognizedWords;
      }
    });

    if (result.finalResult) {
      await _processSpeechResult();
    }
  }

  Future<void> _processSpeechResult() async {
    try {
      final speech = await openAIService.handleUserPrompt(lastWords);

      setState(() {
        if (speech.contains('https')) {
          generatedImageUrl = speech;
          generatedContent = null;
        } else {
          generatedImageUrl = null;
          generatedContent = speech;
        }
      });

      if (generatedContent != null) {
        await systemSpeak(generatedContent!);
      }

      _silenceTimer = Timer(const Duration(seconds: 3), () {
        if (!speechToText.isListening) {
          startListening();
        }
      });
    } catch (e) {
      setState(() => generatedContent = 'Error processing request');
    }
  }

  Future<void> stopListening() async {
    _silenceTimer?.cancel();
    await speechToText.stop();
    setState(() {});
  }

  Future<void> systemSpeak(String content) async {
    await flutterTts.speak(content);
  }

  // UI Helper Methods
  Widget _buildSpeechIndicator() {
    return Visibility(
      visible: _realTimeTranscription.isNotEmpty || speechToText.isListening,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Pallete.assistantCircleColor.withOpacity(0.4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.mic, color: Colors.blue),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _realTimeTranscription.isNotEmpty
                        ? _realTimeTranscription
                        : 'Listening...',
                    style: const TextStyle(
                      fontFamily: 'Cera Pro',
                      color: Pallete.mainFontColor,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (speechToText.isListening)
                  Pulse(
                    duration: const Duration(milliseconds: 1000),
                    child:
                        const Icon(Icons.circle, color: Colors.red, size: 12),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: _soundLevel / 100,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, String> message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: message['role'] == 'user'
            ? Pallete.historyUserColor
            : Pallete.historyAiColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor:
              message['role'] == 'user' ? Colors.blue[100] : Colors.green[100],
          child: Icon(
            message['role'] == 'user' ? Icons.person : Icons.auto_awesome,
            color: message['role'] == 'user' ? Colors.blue : Colors.green,
          ),
        ),
        title: Text(
          message['content']!,
          style: const TextStyle(
            fontFamily: 'Cera Pro',
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          message['role'] == 'user' ? 'You' : 'AI Assistant',
          style: const TextStyle(
            fontFamily: 'Cera Pro',
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  // Dialog Methods
  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'About',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cera Pro',
              color: Pallete.mainFontColor,
            ),
          ),
          content: const Text(
            'I am Smita Patel studying B.Tech in Computer Science in Indian '
            'Institute of Information Technology. I build apps using flutter, dart. '
            'I am doing my best to upgrade my skills by building new projects.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cera Pro',
              color: Pallete.mainFontColor,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'OK',
                style: TextStyle(
                  fontFamily: 'Cera Pro',
                  color: Pallete.mainFontColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showContactDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Contact Details',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cera Pro',
              color: Pallete.mainFontColor,
            ),
          ),
          content: const Text(
            'Phone no. : 9580632505.\nE-mail: miss.smitapatel04@gmail.com',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cera Pro',
              color: Pallete.mainFontColor,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'OK',
                style: TextStyle(
                  fontFamily: 'Cera Pro',
                  color: Pallete.mainFontColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Conversation History',
            style: TextStyle(
              fontFamily: 'Cera Pro',
              color: Pallete.mainFontColor,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: openAIService.conversationHistory.length,
              itemBuilder: (context, index) {
                return _buildHistoryItem(
                    openAIService.conversationHistory[index]);
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Close',
                style: TextStyle(
                  fontFamily: 'Cera Pro',
                  color: Pallete.mainFontColor,
                ),
              ),
            ),
            TextButton(
              onPressed: () => _confirmClearHistory(context),
              child: const Text(
                'Clear History',
                style: TextStyle(
                  fontFamily: 'Cera Pro',
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _confirmClearHistory(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Clear History?',
            style: TextStyle(
              fontFamily: 'Cera Pro',
              color: Pallete.mainFontColor,
            ),
          ),
          content: const Text(
            'Are you sure you want to delete all conversation history?',
            style: TextStyle(
              fontFamily: 'Cera Pro',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Cera Pro',
                  color: Pallete.mainFontColor,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                openAIService.clearConversationHistory();
                Navigator.pop(context);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('History cleared')),
                );
              },
              child: const Text(
                'Clear',
                style: TextStyle(
                  fontFamily: 'Cera Pro',
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController feedbackController = TextEditingController();
        return AlertDialog(
          title: Text(
            'Feedback',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cera Pro',
              color: Pallete.mainFontColor,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'We would love to hear your feedback!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Cera Pro',
                  color: Pallete.mainFontColor,
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: feedbackController,
                decoration: InputDecoration(
                  hintText: 'Enter your feedback here...',
                ),
                maxLines: 5,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Handle the feedback submission here (you can send it to a server, save locally, etc.)
                String feedback = feedbackController.text;
                print('User feedback: $feedback');
                Navigator.pop(context); // Close the dialog
              },
              child: Text(
                'Submit',
                style: TextStyle(
                  fontFamily: 'Cera Pro',
                  color: Pallete.mainFontColor,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Cera Pro',
                  color: Pallete.mainFontColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showRateUsDialog(BuildContext context) {
    double userRating = 0.0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Rate Us',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cera Pro',
              color: Pallete.mainFontColor,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enjoying the app? Your feedback is valuable to us!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Cera Pro',
                  color: Pallete.mainFontColor,
                ),
              ),
              SizedBox(height: 20),
              RatingBar.builder(
                initialRating: 3,
                itemCount: 5,
                itemBuilder: (context, index) {
                  switch (index) {
                    case 0:
                      return Icon(
                        Icons.sentiment_very_dissatisfied,
                        color: Colors.red,
                      );
                    case 1:
                      return Icon(
                        Icons.sentiment_dissatisfied,
                        color: Colors.redAccent,
                      );
                    case 2:
                      return Icon(
                        Icons.sentiment_neutral,
                        color: Colors.amber,
                      );
                    case 3:
                      return Icon(
                        Icons.sentiment_satisfied,
                        color: Colors.lightGreen,
                      );
                    case 4:
                      return Icon(
                        Icons.sentiment_very_satisfied,
                        color: Colors.green,
                      );
                    default:
                      // A default case is required, even though it should never be reached in this example
                      return Container(); // or another suitable default widget
                  }
                },
                onRatingUpdate: (rating) {
                  userRating = rating;
                  print(rating);
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (userRating >= 4.0) {
                    // Prompt the user to rate on the app store
                    // You can use a package like `url_launcher` to open a URL
                    // Example: launch('https://play.google.com/store/apps/details?id=your_app_package_name');
                    Navigator.pop(context); // Close the dialog
                  } else {
                    // Handle lower ratings, e.g., open a feedback form
                    // You can customize this part based on your app's logic
                    // For now, just close the dialog
                    Navigator.pop(context); // Close the dialog
                  }
                },
                child: Text(
                  'Submit Rating',
                  style: TextStyle(
                    fontFamily: 'Cera Pro',
                    color: Pallete.mainFontColor,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text(
                'Maybe Later',
                style: TextStyle(
                  fontFamily: 'Cera Pro',
                  color: Pallete.mainFontColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showHelpCenterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Help Center',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cera Pro',
              color: Pallete.mainFontColor,
            ),
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Card(
                elevation: 4.0,
                child: ListTile(
                  title: Text(
                    'FAQ Section',
                    style: TextStyle(
                      fontFamily: 'Cera Pro',
                      color: Pallete.mainFontColor,
                    ),
                  ),
                  subtitle: Text(
                    'Check our FAQ section on our website for answers to common questions.',
                    style: TextStyle(
                      fontFamily: 'Cera Pro',
                      color: Pallete.mainFontColor,
                    ),
                  ),
                  onTap: () {
                    // Add functionality to navigate to the FAQ section
                    Navigator.pop(context);
                    // Example: Navigator.push(context, MaterialPageRoute(builder: (context) => FAQPage()));
                  },
                ),
              ),
              Card(
                elevation: 4.0,
                child: ListTile(
                  title: Text(
                    'Support Page',
                    style: TextStyle(
                      fontFamily: 'Cera Pro',
                      color: Pallete.mainFontColor,
                    ),
                  ),
                  subtitle: Text(
                    'Visit our support page for step-by-step guides and tutorials.',
                    style: TextStyle(
                      fontFamily: 'Cera Pro',
                      color: Pallete.mainFontColor,
                    ),
                  ),
                  onTap: () {
                    // Add functionality to navigate to the support page
                    Navigator.pop(context);
                    // Example: Navigator.push(context, MaterialPageRoute(builder: (context) => SupportPage()));
                  },
                ),
              ),
              Card(
                elevation: 4.0,
                child: ListTile(
                  title: Text(
                    'Contact Support',
                    style: TextStyle(
                      fontFamily: 'Cera Pro',
                      color: Pallete.mainFontColor,
                    ),
                  ),
                  subtitle: Text(
                    'Contact our support team at support@example.com for personalized assistance.',
                    style: TextStyle(
                      fontFamily: 'Cera Pro',
                      color: Pallete.mainFontColor,
                    ),
                  ),
                  onTap: () {
                    // Add functionality to contact support
                    // Example: launch('mailto:support@example.com');
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text(
                'Close',
                style: TextStyle(
                  fontFamily: 'Cera Pro',
                  color: Pallete.mainFontColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showTermsOfServiceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TermsOfServiceDialog();
      },
    );
  }

  @override
  void dispose() {
    _silenceTimer?.cancel();
    speechToText.stop();
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BounceInDown(
          child: const Text(
            'My AI',
            style: TextStyle(
              fontFamily: 'Cera Pro',
              color: Pallete.mainFontColor,
              fontSize: 28,
            ),
          ),
        ),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        centerTitle: true,
      ),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildAssistantImage(),
            _buildChatBubble(),
            _buildSpeechIndicator(),
            if (generatedImageUrl != null) _buildGeneratedImage(),
            _buildFeaturesList(),
          ],
        ),
      ),
      floatingActionButton: _buildMicButton(),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Pallete.assistantCircleColor,
            ),
            child: Text(
              'Hi, Friend!',
              style: TextStyle(
                fontFamily: 'Cera Pro',
                color: Pallete.mainFontColor,
                fontSize: 35,
              ),
            ),
          ),
          ListTile(
            title: Text('History',
                style: TextStyle(
                  fontFamily: 'Cera Pro',
                  color: Pallete.mainFontColor,
                )),
            leading: Icon(Icons.history),
            onTap: () {
              _showHistoryDialog(context);
            },
          ),
          ListTile(
            title: Text(
              'Settings',
              style: TextStyle(
                fontFamily: 'Cera Pro',
                color: Pallete.mainFontColor,
              ),
            ),
            leading: Icon(Icons.settings), // Add an icon
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (builder) => SettingsPage()));
            },
          ),
          ListTile(
            title: Text(
              'About',
              style: TextStyle(
                fontFamily: 'Cera Pro',
                color: Pallete.mainFontColor,
              ),
            ),
            leading: Icon(Icons.info), // Add an icon
            onTap: () {
              _showAboutDialog();
            },
          ),
          Divider(), // Add a divider for visual separation
          ListTile(
            title: Text(
              'Contact Us',
              style: TextStyle(
                fontFamily: 'Cera Pro',
                color: Pallete.mainFontColor,
              ),
            ),
            leading: Icon(Icons.mail), // Add an icon
            onTap: () {
              _showContactDialog();
            },
          ),
          ListTile(
            title: Text(
              'Feedback',
              style: TextStyle(
                fontFamily: 'Cera Pro',
                color: Pallete.mainFontColor,
              ),
            ),
            leading: Icon(Icons.feedback), // Add an icon
            onTap: () {
              _showFeedbackDialog(context);
            },
          ),
          ListTile(
            title: Text(
              'Rate Us',
              style: TextStyle(
                fontFamily: 'Cera Pro',
                color: Pallete.mainFontColor,
              ),
            ),
            leading: Icon(Icons.star), // Add an icon
            onTap: () {
              _showRateUsDialog(context);
            },
          ),
          Divider(), // Add another divider
          ListTile(
            title: Text(
              'Help Center',
              style: TextStyle(
                fontFamily: 'Cera Pro',
                color: Pallete.mainFontColor,
              ),
            ),
            leading: Icon(Icons.help), // Add an icon
            onTap: () {
              _showHelpCenterDialog(context);
            },
          ),
          ListTile(
            title: Text(
              'Terms of Service',
              style: TextStyle(
                fontFamily: 'Cera Pro',
                color: Pallete.mainFontColor,
              ),
            ),
            leading: Icon(Icons.library_books), // Add an icon
            onTap: () {
              _showTermsOfServiceDialog(context);
            },
          ),
          // Add more options as needed
        ],
      ),
    );
  }

  Widget _buildAssistantImage() {
    return ZoomIn(
      child: Stack(
        children: [
          Center(
            child: Container(
              height: 120,
              width: 120,
              margin: const EdgeInsets.only(top: 4),
              decoration: const BoxDecoration(
                color: Pallete.assistantCircleColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Container(
            height: 123,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage('assets/images/virtualAssistant.png'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble() {
    return FadeInRight(
      child: Visibility(
        visible: generatedImageUrl == null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          margin: const EdgeInsets.symmetric(horizontal: 40).copyWith(top: 30),
          decoration: BoxDecoration(
            border: Border.all(color: Pallete.borderColor),
            borderRadius:
                BorderRadius.circular(20).copyWith(topLeft: Radius.zero),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Text(
              generatedContent == null
                  ? 'Hi, Friend!, what task can I do for you?'
                  : generatedContent!,
              style: TextStyle(
                fontFamily: 'Cera Pro',
                color: Pallete.mainFontColor,
                fontSize: generatedContent == null ? 25 : 18,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGeneratedImage() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: generatedImageUrl!.startsWith('http')
          ? ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                generatedImageUrl!,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Could not load image',
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                },
              ),
            )
          : Text(
              generatedImageUrl!,
              style: const TextStyle(color: Colors.red),
            ),
    );
  }

  Widget _buildFeaturesList() {
    return SlideInLeft(
      child: Visibility(
        visible: generatedContent == null && generatedImageUrl == null,
        child: Column(
          children: [
            SlideInLeft(
              delay: Duration(milliseconds: start),
              child: const FeatureBox(
                color: Pallete.firstSuggestionBoxColor,
                headerText: 'ChatGPT',
                descriptionText:
                    'A smarter way to stay organized and informed with ChatGPT',
              ),
            ),
            SlideInLeft(
              delay: Duration(milliseconds: start + delay),
              child: const FeatureBox(
                color: Pallete.secondSuggestionBoxColor,
                headerText: 'Dall-E',
                descriptionText:
                    'Get inspired and stay creative with your personal assistant powered by Dall-E',
              ),
            ),
            SlideInLeft(
              delay: Duration(milliseconds: start + 2 * delay),
              child: const FeatureBox(
                color: Pallete.thirdSuggestionBoxColor,
                headerText: 'Smart Voice Assistant',
                descriptionText:
                    'Get the best of both worlds with a voice assistant powered by Dall-E and ChatGPT',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMicButton() {
    return ZoomIn(
      delay: Duration(milliseconds: start + 3 * delay),
      child: FloatingActionButton(
        backgroundColor: Pallete.firstSuggestionBoxColor,
        onPressed: toggleListening,
        child: Icon(
          speechToText.isListening ? Icons.stop : Icons.mic,
        ),
      ),
    );
  }
}
