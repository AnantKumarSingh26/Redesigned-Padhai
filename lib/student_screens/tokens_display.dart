import 'package:flutter/material.dart';

class TokensDisplay extends StatelessWidget {
  final int tokens;

  const TokensDisplay({Key? key, required this.tokens}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Tokens: $tokens',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blueAccent,
        ),
      ),
    );
  }
}