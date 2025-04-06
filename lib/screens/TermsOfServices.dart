import 'package:allen/widgets/pallete.dart';
import 'package:flutter/material.dart';

class TermsOfServiceDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 0.0,
      child: contentBox(context),
    );
  }

  Widget contentBox(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FadeIn(
            child: Text(
              'Terms of Service',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cera Pro',
                color: Pallete.mainFontColor,
              ),
            ),
          ),
          SizedBox(height: 12.0),
          FadeIn(
            child: Text(
              'Welcome to our app. By using our app, you agree to these terms of service.',
              style: TextStyle(fontSize: 16.0,fontFamily: 'Cera Pro',
                color: Pallete.mainFontColor,),
            ),
          ),
          SizedBox(height: 12.0),
          FadeIn(
            child: Text(
              '1. User Responsibilities:',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cera Pro',
                color: Pallete.mainFontColor,
              ),
            ),
          ),
          FadeIn(
            child: Text(
              'Users are responsible for their actions and content shared within the app.',
              style: TextStyle(fontSize: 16.0,fontFamily: 'Cera Pro',
                color: Pallete.mainFontColor,),
            ),
          ),
          SizedBox(height: 12.0),
          FadeIn(
            child: Text(
              '2. Privacy Policy:',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cera Pro',
                color: Pallete.mainFontColor,
              ),
            ),
          ),
          FadeIn(
            child: Text(
              'Review our privacy policy for information on how we handle user data.',
              style: TextStyle(fontSize: 16.0,fontFamily: 'Cera Pro',
                color: Pallete.mainFontColor,),
            ),
          ),
          SizedBox(height: 12.0),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Pallete.secondSuggestionBoxColor,
            ),
            child: Text(
              'Close',
              style: TextStyle(
                fontSize: 18.0,
                fontFamily: 'Cera Pro',
                color: Pallete.mainFontColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FadeIn extends StatefulWidget {
  final Widget child;

  const FadeIn({Key? key, required this.child}) : super(key: key);

  @override
  _FadeInState createState() => _FadeInState();
}

class _FadeInState extends State<FadeIn> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
