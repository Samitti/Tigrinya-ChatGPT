import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gtptg/constant.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;
import 'model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
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
  final TextEditingController _textController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];


  @override
  void initState() {
    super.initState();
    isLoading = false;
  }

  Future<String> generateResponse(String prompt) async {
    const apiKey = apiSecretKey;
    var url = Uri.http("api.openai.com", "/v1/completions");
    final response = await http.post(
      url,
      headers: {
        'Content-Type':'application/json',
        'Authorization':'Bearer $apiKey'
      },
      body: jsonEncode({
        'model': 'text-davinci-003',
        'prompt': prompt,
        'temperature': 0,
        'max_token': 2000,
        'top_p': 1,
        'frequency_penalty': 0.0,
        'presence_penalty': 0.0,
      }));

      //decode the response
      Map<String, dynamic> newresponse = jsonDecode(response.body);
      return newresponse['choices'][0]['text'];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 100,
          title: const Padding(
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
              child: const CircularProgressIndicator(
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
        style: const TextStyle(color: Colors.white),
        controller: _textController,
        decoration: const InputDecoration(
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
        icon: const Icon(Icons.send, color: Color.fromRGBO(142, 142, 160, 1),), 
        onPressed: () {
          // display user input
          setState(() {
            _messages.add(ChatMessage(
              text: _textController.text, 
              chatMessageType: ChatMessageType.user));
            isLoading = true;
          });
          var input = _textController.text;
          _textController.clear();
          Future.delayed(const Duration(milliseconds: 50))
          .then((value) => _scrollDown());

          // call chatbot api
          generateResponse(input).then((value) {
            setState(() {
              isLoading = false;
          //display chatbot response
            _messages.add(ChatMessage(
              text: value,
              chatMessageType: ChatMessageType.bot,
            ));
            });
            _textController.clear();
            Future.delayed(const Duration(milliseconds: 50))
            .then((value) => _scrollDown());
          });
        },
        ),
    )
    );
 }

 void _scrollDown() {
  _scrollController.animateTo(
    _scrollController.position.maxScrollExtent, 
    duration: const Duration(milliseconds: 300), 
    curve: Curves.easeOut,
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
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      color: chatMessageType == ChatMessageType.bot ? botBackgroundColor : backgroundColor,
      child: Row(
        children: [
        chatMessageType == ChatMessageType.bot
         ? Container(
          margin: const EdgeInsets.only(right: 16),
          child: CircleAvatar(
            backgroundColor: const Color.fromRGBO(16, 163, 127, 1), 
            child: Image.asset('assets/images/chatBotPng.png', color: Colors.white, scale: 1.5,
            ),
          ),
        )
        : Container(
          margin: const EdgeInsets.only(right: 16),
          child: const CircleAvatar(
            child: Icon(Icons.person),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
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