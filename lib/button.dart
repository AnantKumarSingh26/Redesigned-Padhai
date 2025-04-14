import 'package:flutter/material.dart'; 

class CircularAnimatedButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool isPressed;

  const CircularAnimatedButton({
    super.key,
    required this.onTap,
    required this.isPressed,
  });

  @override
  _CircularAnimatedButtonState createState() => _CircularAnimatedButtonState();
}

class _CircularAnimatedButtonState extends State<CircularAnimatedButton> {
  bool showRing = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onTap();
        setState(() {
          showRing = true;
        });
        Future.delayed(const Duration(seconds: 1), () {
          setState(() {
            showRing = false;
          });
        });
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedOpacity(
            opacity: showRing ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 500),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: showRing ? 100 : 75,
              height: showRing ? 100 : 75,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.blueAccent.withOpacity(0.5),
                  width: 5,
                ),
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: widget.isPressed ? 65 : 75,
            height: widget.isPressed ? 65 : 75,
            decoration: BoxDecoration(
              color: widget.isPressed ? const Color(0xFF1F41BB) : const Color(0xFF1F41BB), // Added 'const'
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(255, 4, 10, 169).withOpacity(0.3),
                  blurRadius: widget.isPressed ? 20 : 10,
                  spreadRadius: widget.isPressed ? 4 : 2,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: AnimatedScale(
                duration: const Duration(milliseconds: 500),
                scale: widget.isPressed ? 1.2 : 1.0,
                child: const Icon(
                  Icons.arrow_forward,
                  size: 35,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}