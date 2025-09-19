import 'package:aiagentchatbot/BackendFiles/supabasefunctions.dart';
import 'package:aiagentchatbot/BackendFiles/webhookfunctions.dart';
import 'package:aiagentchatbot/MainPagefiles/ChatPageVisuals/chatblock.dart';
import 'package:aiagentchatbot/MainPagefiles/audiotogglepill.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  /* The following are the Text controllers which are integrated into the 
     Company Context Textfields and CHAT message textfields.
  */
  final TextEditingController _messageController = TextEditingController();

  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _servicesController = TextEditingController();
  final TextEditingController _idealcustomerController =
      TextEditingController();
  final TextEditingController _webhookController = TextEditingController();
  final TextEditingController _teamcustomerController = TextEditingController();

  GlobalKey formkey = GlobalKey<FormFieldState>();

  String message = "";
  bool _hasText = false;
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _hasText = _messageController.text.trim().isNotEmpty;
    _messageController.addListener(_handleTextChange);
  }

  @override
  void dispose() {
    _messageController.removeListener(_handleTextChange);
    _messageController.dispose();
    _companyController.dispose();
    _emailController.dispose();
    _nameController.dispose();
    _webhookController.dispose();
    _servicesController.dispose();
    _focusNode.dispose();
    _idealcustomerController.dispose();
    _webhookController.dispose();
    _teamcustomerController.dispose();
    super.dispose();
  }

  void _handleTextChange() {
    final hasText = _messageController.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  /* DIALOG BOX FOR ADDING CONTEXT TO THE PAYLOAD


  */

  Future<void> _showUserInfoDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Company Information',
            style: GoogleFonts.manrope(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ///
                /// WEBHOOK FIELD
                ///
                TextField(
                  cursorColor: Colors.black,
                  controller: _webhookController,
                  decoration: InputDecoration(
                    focusColor: Colors.black,
                    labelText: 'WebHook',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),

                SizedBox(height: 16),

                ///
                /// COMPANY NAME FIELD
                ///
                TextField(
                  cursorColor: Colors.black,
                  controller: _companyController,
                  decoration: InputDecoration(
                    focusColor: Colors.black,

                    labelText: 'Company Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                SizedBox(height: 16),

                ///
                /// COMPANY WEBSITE URL FIELD
                ///
                TextField(
                  cursorColor: Colors.black,
                  controller: _websiteController, // Add controller for website
                  decoration: InputDecoration(
                    focusColor: Colors.black,
                    labelText: 'Website URL',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),

                SizedBox(height: 16),

                ///
                /// PRODUCTS AND SERVICES FIELD
                ///
                TextField(
                  cursorColor: Colors.black,
                  controller:
                      _servicesController, // Add controller for products
                  decoration: InputDecoration(
                    focusColor: Colors.black,
                    labelText: 'Products / Services',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  maxLines: 2,
                ),
                SizedBox(height: 16),

                ///
                /// IDEAL CUSTOMER FIELD
                ///
                SizedBox(height: 8),
                TextField(
                  cursorColor: Colors.black,
                  controller: _idealcustomerController,
                  decoration: InputDecoration(
                    focusColor: Colors.black,
                    hintText: 'Describe your ideal customer profile...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  maxLines: 4,
                ),

                //
                SizedBox(height: 16),

                ///
                /// TEAM BREAKDOWN FIELD
                ///
                SizedBox(height: 8),
                TextField(
                  cursorColor: Colors.black,
                  controller: _teamcustomerController,
                  decoration: InputDecoration(
                    focusColor: Colors.black,
                    hintText:
                        'Detail key roles, responsibilities, teams, and workflows...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  maxLines: 6,
                ),
              ],
            ),
          ),
          actions: [
            ///
            /// CLEAR BUTTON
            ///
            FilledButton(
              style: ButtonStyle(
                foregroundColor: WidgetStatePropertyAll(Colors.white),
                backgroundColor: WidgetStatePropertyAll(Colors.black),
              ),
              onPressed: () {
                _webhookController.clear();
                _companyController.clear();
                _emailController.clear();
                _nameController.clear();
                _websiteController.clear();
                _servicesController.clear();
                _idealcustomerController.clear();
                _webhookController.clear();
                _teamcustomerController.clear();
                // Save the information
                Navigator.of(context).pop();
              },
              child: Text('Clear'),
            ),

            ///
            /// CANCEL BUTTON
            ///
            ///
            ///
            TextButton(
              style: ButtonStyle(
                foregroundColor: WidgetStatePropertyAll(Colors.white),
                backgroundColor: WidgetStatePropertyAll(Colors.black),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),

            ///
            /// SAVE BUTTON
            ///
            ///
            ///
            FilledButton(
              style: ButtonStyle(
                foregroundColor: WidgetStatePropertyAll(Colors.white),
                backgroundColor: WidgetStatePropertyAll(Colors.black),
              ),
              onPressed: () {
                // Save the information
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  /* This method _sendMessage() handles sending messages, sends messages, to the backend, and Webhook
  */

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isNotEmpty) {
      final message = _messageController.text;

      /*
        IMPORTANT
          - Currently "from" field in the messageDataToDB is hardcoded

        The following payload is being sent the Database
      */
      final messageDataToDB = {
        'content': message,
        'created_at': DateTime.now().toIso8601String(),
        'from': "Zin",
        'company': _companyController.text,
        'email': _emailController.text,
        'name': _nameController.text,
      };
      await Supabasefunctions().sendMessage(messageDataToDB);

      /*
        The following payload is being sent the webhook
      */
      final businesscontextToWebhook = {
        'company': _companyController.text,
        'website': _websiteController.text,
        'product/services': _servicesController.text,
        'idealcustomer': _idealcustomerController.text,
        'teambreakdown': _teamcustomerController.text,
      };
      await Webhookfunctions().sendPostRequest(
        businesscontextToWebhook,
        _webhookController.text,
      );

      setState(() {
        _messageController.clear();
        _hasText = false;
      });

      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        StreamBuilder(
                          stream: Supabase.instance.client
                              .from('Chats')
                              .stream(primaryKey: ['id'])
                              .order('id', ascending: true),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Center(
                                child: CircularProgressIndicator(
                                  color: Theme.of(context).dividerColor,
                                ),
                              );
                            }

                            if (snapshot.data!.isEmpty) {
                              return Center(child: Text("No messages yet"));
                            }

                            final messages = snapshot.data!;

                            SchedulerBinding.instance.addPostFrameCallback((_) {
                              if (_scrollController.hasClients) {
                                _scrollController.animateTo(
                                  _scrollController.position.maxScrollExtent,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOut,
                                );
                              }
                            });

                            return ListView.builder(
                              controller: _scrollController,
                              itemCount: messages.length,
                              itemBuilder: (context, index) {
                                final message = messages[index];
                                return Chatblock(chat: message);
                              },
                            );
                          },
                        ),

                        // Position of the Audio Pill
                        Positioned(
                          bottom: 0,
                          left: MediaQuery.of(context).size.width * 0.35,
                          //  right: ,
                          child: AudioTogglePill(
                            onTranscriptionComplete: _messageController,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Main Chat FormField and its UI
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Card(
                      shadowColor: const Color.fromARGB(255, 252, 251, 251),
                      elevation: 2,
                      color: const Color.fromARGB(247, 247, 247, 247),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                key: formkey,
                                controller: _messageController,
                                focusNode: _focusNode,
                                style: GoogleFonts.lato(
                                  textStyle: TextStyle(
                                    color: Colors.grey[800],
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                cursorColor: Color.fromARGB(255, 0, 0, 0),
                                maxLines: 5,
                                minLines: 1,
                                decoration: InputDecoration(
                                  fillColor: Colors.grey,
                                  border: InputBorder.none,
                                  hintText: '  Type your messages here',
                                  hintStyle: GoogleFonts.dmSans(
                                    textStyle: TextStyle(
                                      color: const Color.fromARGB(
                                        221,
                                        214,
                                        214,
                                        214,
                                      ),
                                      fontWeight: FontWeight.w400,

                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            AnimatedOpacity(
                              opacity: _hasText ? 1.0 : 0.0,
                              duration: Duration(milliseconds: 200),
                              child: IconButton(
                                onPressed: _hasText ? _sendMessage : null,
                                icon: Icon(
                                  Icons.send,
                                  color: const Color.fromARGB(255, 51, 51, 52),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.person),
                              onPressed: _showUserInfoDialog,
                              tooltip: 'Add user information',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
