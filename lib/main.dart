import 'package:flutter/material.dart';
import 'package:mqttchatterbox/pages/chatroom/screen_chat_room.dart';
import 'package:mqttchatterbox/pages/chatroom/state_chat_room.dart';
import 'package:mqttchatterbox/pages/home/screen_home_page.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(

      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => ChatRoomStateProvider(),
          ),
          // todo
        ],
        child: const MyApp(),
      )

  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chatter Box',
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
      ),
      home: const ChatRoomPage(), //MyHomePage(),
    );
  }
}

