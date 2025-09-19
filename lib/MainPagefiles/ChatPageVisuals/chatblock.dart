import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Chatblock extends StatefulWidget {
  final dynamic chat;
  const Chatblock({super.key, required this.chat});

  @override
  State<Chatblock> createState() => _ChatblockState();
}

class _ChatblockState extends State<Chatblock> {
  double chatborderRadiusSize = 20;

  @override
  Widget build(BuildContext context) {
    bool mychat = widget.chat['from'] == "Zin";
    return Align(
      alignment: mychat ? Alignment.topRight : Alignment.topLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            mychat ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment:
                mychat ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!mychat)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 15, 5, 0),
                      child: Column(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.black,
                            radius: 13,
                          ),
                        ],
                      ),
                    ),
                  Container(
                    decoration: BoxDecoration(
                      color:
                          mychat
                              ? const Color.fromARGB(255, 253, 253, 253)
                              : const Color.fromARGB(255, 244, 244, 244),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(chatborderRadiusSize),
                        topRight: Radius.circular(chatborderRadiusSize),
                        bottomLeft: Radius.circular(chatborderRadiusSize),
                        bottomRight: Radius.circular(chatborderRadiusSize),
                      ),
                    ),
                    margin: const EdgeInsets.all(3),
                    padding: const EdgeInsets.all(10),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (mychat &&
                            widget.chat['company'] != null &&
                            widget.chat['company'].isNotEmpty)
                          SizedBox(height: 4),
                        Text(
                          widget.chat['content'],
                          style: GoogleFonts.manrope(
                            textStyle: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
