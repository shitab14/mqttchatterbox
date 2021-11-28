import 'package:flutter/material.dart';
import 'package:mqttchatterbox/pages/chatroom/screen_chat_room.dart';
import 'package:mqttchatterbox/util/app_navigator.dart';

class MyHomePage extends StatefulWidget {

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
                onPressed: _notificationPage,
                child: const Text(
                  'Notification Sender',
                ),
            ),
            ElevatedButton(
                onPressed: _receiverPage,
                child: const Text(
                  'Notification Receiver',
                ),
            ),
            ElevatedButton(
                onPressed: _chatterPage,
                child: const Text(
                  'Chatter Page',
                ),
            ),
          ],
        ),
      ),

    );
  }

  void _notificationPage() {
    /// Go to Notification
  }

  void _receiverPage() {
    /// Go to Receiver Page
  }

  void _chatterPage() {
    /// Go to Receiver Page
    AppNavigator.goToNextScreen(context, ChatRoomPage(), null);
  }
}