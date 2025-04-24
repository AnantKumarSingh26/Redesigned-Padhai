import 'package:flutter/material.dart';

class TokensDisplay extends StatelessWidget {
  final int tokens;

  const TokensDisplay({Key? key, required this.tokens}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white, // Background color
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.monetization_on, // Token symbol
              color: Colors.green, // Symbol color
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'Tokens: $tokens',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue, // Text color
              ),
            ),
          ],
        ),
      ),
    );
  }
}