import 'package:flutter/material.dart';
import 'home_page.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  bool _isSwipedUp = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0),
      end: Offset(0, -1),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSwipeUp() {
    _controller.forward().then((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity! < 0 && !_isSwipedUp) {
          setState(() {
            _isSwipedUp = true;
          });
          _onSwipeUp();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade800,
        body: Stack(
          children: [
            SlideTransition(
              position: _slideAnimation,
              child: Scaffold(
                backgroundColor: Colors.grey.shade800,
                body: Stack(
                  children: [
                    Positioned(
                      top: 100,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Text(
                          'MoneyManager.App',
                          style: TextStyle(
                            fontSize: 30,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 175, // Move the logo 200px upwards from the center
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Icon(
                          Icons.monetization_on_outlined,
                          size: 80.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom:70,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.keyboard_arrow_up,
                              size: 24.0,
                              color: Colors.white,
                            ),
                            Text(
                              'Swipe up to continue',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
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
    );
  }
}