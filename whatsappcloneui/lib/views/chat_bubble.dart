import 'package:flutter/material.dart';
import 'dart:io'; // for File

class ChatBubble extends StatelessWidget {
  final String message;
  final String time;
  final bool isMe;
  final bool isImage;
  final String? imagePath; // optional image path

  ChatBubble({
    super.key,
    required this.message,
    required this.time,
    required this.isMe,
    this.isImage = false,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: isImage ? 200 : MediaQuery.of(context).size.width * 0.7,
              ),
              decoration: BoxDecoration(
                color: isImage ? Colors.transparent : (isMe ? const Color(0xff25D366) : Colors.grey[300]),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft: isMe ? const Radius.circular(12) : const Radius.circular(0),
                  bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(12),
                ),
              ),
              padding: isImage ? EdgeInsets.zero : const EdgeInsets.all(12.0),
              child: isImage && imagePath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(imagePath!),
                        fit: BoxFit.cover,
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          message,
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          time,
                          style: TextStyle(
                            fontSize: 10,
                            color: isMe ? Colors.white70 : Colors.black54,
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