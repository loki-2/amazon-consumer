import 'package:flutter/material.dart';

class AmazonSearchBar extends StatelessWidget {
  const AmazonSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 8),
            child: Icon(Icons.search, color: Colors.black54),
          ),
          Expanded(
            child: TextField(
              textAlign: TextAlign.left,
              decoration: InputDecoration(
                hintText: 'Search or ask a question',
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                hintStyle: const TextStyle(color: Colors.black54),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.camera_alt_outlined),
            onPressed: () {},
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            color: Colors.black54,
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.mic),
            onPressed: () {},
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            color: Colors.black54,
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () {},
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            color: Colors.black54,
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}