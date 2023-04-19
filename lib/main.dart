import 'package:flutter/material.dart';

import 'model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChatPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

const backgroundColor = Color(0xff343541);
const botBackgroundColor = Color(0xff444654);


class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late  bool isLoading;
  TextEditingController _textController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 100,
          title: Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'OpenAIs chatGPT flutter Exg',
              maxLines: 2,
              textAlign: TextAlign.center,
              ),
          ),
          backgroundColor: botBackgroundColor,
        ),
        backgroundColor: backgroundColor,
        body: Column(
          children: [
            // chat body
            Expanded(
             child: _buildList(),
            ),
            Visibility(
              visible: isLoading,
              child: CircularProgressIndicator(
              color: Colors.white,
              ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    //input fiels
                    _buildInput(),
                    //submit button
                    _buidSubmit(),
                  ],
                  ),
              ),
          ],
        ),
      ),
    );
  }

  Expanded _buildInput() {
    return Expanded(
      child: TextField(
        textCapitalization: TextCapitalization.sentences,
        style: TextStyle(color: Colors.white),
        controller: _textController,
        decoration: InputDecoration(
          fillColor: botBackgroundColor,
          filled: true,
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none
        ),
      ),
    );
  }

 Widget _buidSubmit() {
  return Visibility(
    visible: !isLoading,
    child: Container(
      color: botBackgroundColor,
      child: IconButton(
        icon: Icon(Icons.send, color: Color.fromRGBO(142, 142, 160, 1),), 
        onPressed: () {
          
        },
        ),
    )
    );
 }

 ListView _buildList() {
  return ListView.builder(
    itemCount: _messages.length,
    controller: _scrollController,
    itemBuilder: ((context, index){
      var message = _messages[index];
      return ChatMessageWidget(
        text: message.text,
        chatMessageType: message.chatMessageType,
      );
  }),);
 }
}

class ChatMessageWidget extends StatelessWidget {
  final String text;
  final ChatMessageType chatMessageType;
  const ChatMessageWidget({super.key, required this.text, required this.chatMessageType});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.all(16),
      color: chatMessageType == ChatMessageType.bot ? botBackgroundColor : backgroundColor,
      child: Row(
        children: [
        chatMessageType == ChatMessageType.bot
         ? Container(
          margin: EdgeInsets.only(right: 16),
          child: CircleAvatar(
            backgroundColor: Color.fromRGBO(16, 163, 127, 1), 
            child: Image.asset('assets/images/chatBotPng.png', color: Colors.white, scale: 1.5,
            ),
          ),
        )
        : Container(
          margin: EdgeInsets.only(right: 16),
          child: CircleAvatar(
            child: Icon(Icons.person),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(8),
                  ),
                ),
                child: Text(
                  text,
                  style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: Colors.white),
                ),
              )
            ],
          )
        )

      ]),
    );
  }
}