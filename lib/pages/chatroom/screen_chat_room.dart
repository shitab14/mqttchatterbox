import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mqttchatterbox/network/broker_constants.dart';
import 'package:mqttchatterbox/network/mqtt_manager.dart';
import 'package:mqttchatterbox/pages/chatroom/state_chat_room.dart';
import 'package:mqttchatterbox/util/app_util.dart';
import 'package:provider/provider.dart';

class ChatRoomPage extends StatefulWidget {
  const ChatRoomPage({Key? key}) : super(key: key);


  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _chatMsgController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  late ChatRoomStateProvider chatRoomStateProvider;
  late MQTTChatRoomManager _manager;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _topicController.dispose();
    _chatMsgController.dispose();
    _nameController.dispose();
    // _manager.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stateProvider  = Provider.of<ChatRoomStateProvider>(context);
    chatRoomStateProvider = stateProvider;

    return Scaffold(
      appBar: _getAppBar(),
      body: Container(
        height: double.infinity,
        padding: const EdgeInsets.only(top:20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            _topSection(),
            _chatBox(),
          ],
        ),
      ),

    );
  }

  ///UI
  AppBar _getAppBar() {
    return AppBar(
      title: const Text(
        'MQTT Chat Room',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.lightGreen,
    );
  }

  Widget _userName() {
    return Flexible(
      flex: 1,
      child: Container(
        margin: const EdgeInsets.only(left: 10, right: 5,),
        child: TextFormField(
          maxLines: 1,
          controller: _nameController,
          keyboardType: TextInputType.text,
          enabled: !(chatRoomStateProvider.getAppConnectionState == ChatRoomConnectionState.connected),
          style: const TextStyle(
            fontSize: 14,
          ),
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.all(18),
            border: OutlineInputBorder(),
            hintText: 'Name',
            counterText: '',
          ),
        ),
      ),
    );
  }

  Widget _chatRoomConnect() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _userName(),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(left: 10, right: 10,),
            child: TextFormField(
              maxLines: 1,
              controller: _topicController,
              keyboardType: TextInputType.text,
              enabled: !(chatRoomStateProvider.getAppConnectionState == ChatRoomConnectionState.connected),
              style: const TextStyle(
                fontSize: 14,
              ),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.all(18),
                border: OutlineInputBorder(),
                hintText: 'Channel',
                counterText: '',
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: ElevatedButton(
            onPressed: _connectDisconnectButtonPress,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(0.0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.0)),
            ),
            child: Ink(
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                color: (chatRoomStateProvider.getAppConnectionState == ChatRoomConnectionState.connected)
                    ? const Color(0xFFD32F2F)
                    : (chatRoomStateProvider.getAppConnectionState == ChatRoomConnectionState.connecting)
                    ? const Color(0xffff9b38)
                    : const Color(0xFF61d800),
              ),
              child: Container(
                height: 23,
                padding: const EdgeInsets.all(5),
                margin: const EdgeInsets.all(10),
                child: FittedBox(
                  child: Text(
                    (chatRoomStateProvider.getAppConnectionState == ChatRoomConnectionState.connected)
                        ? "Disconnect"
                        : (chatRoomStateProvider.getAppConnectionState == ChatRoomConnectionState.connecting) ? 'Connecting' : " Connect ",
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _topSection() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          _chatRoomConnect(),
          _getChatHistorySection(),
        ],
      ),
    );
  }

  Widget _chatBox() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      color: const Color(0xFFCDE1C9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Chat Body
          Expanded(
            flex: 8,
            child: Container(
              margin: const EdgeInsets.only(left: 10, right: 5,),
              child: TextFormField(
                maxLines: 1,
                maxLength: 1000,
                controller: _chatMsgController,
                keyboardType: TextInputType.text,
                style: const TextStyle(
                  fontSize: 14,
                ),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(18),
                  border: OutlineInputBorder(),
                  hintText: 'Write here',
                  counterText: '',
                ),
              ),
            ),
          ),
          // Send Button
          Visibility(
            visible: (chatRoomStateProvider.getAppConnectionState == ChatRoomConnectionState.connected),
            child: IconButton(
              onPressed: _sendChat,
              icon: const Icon(
                Icons.arrow_forward,
                color: Colors.lightGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getChatHistorySection() {
    return Expanded(
      child: Visibility(
        visible: chatRoomStateProvider.getHistoryText.isNotEmpty,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(10),
          child: Container(
            color: Colors.grey[300],
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            margin: const EdgeInsets.all(5),
            child: Text(
              chatRoomStateProvider.getHistoryText,
            ),
          ),
        ),
      ),
    );
  }

  /// Functions
  _connectDisconnectButtonPress() {
    if (_topicController.text.isNotEmpty && _nameController.text.isNotEmpty) {

      if (chatRoomStateProvider.getAppConnectionState == ChatRoomConnectionState.connected) {
        _manager.disconnect();
      } else if (chatRoomStateProvider.getAppConnectionState == ChatRoomConnectionState.disconnected) {
        _manager = MQTTChatRoomManager(
          host: BrokerConstants.brokerHost,
          port: BrokerConstants.port,
          topic: _topicController.text.toString(),//BrokerConstants.chatTopic,
          identifier: _nameController.text.toString(),
          state: chatRoomStateProvider,
        );
        _manager.initializeMQTTClient();
        _manager.connect();

      }

    } else {
      CommonUtil.instance.showToast(context, 'Please Enter Name & Topic');
    }

  }

  _sendChat() {
    if (chatRoomStateProvider.getAppConnectionState == ChatRoomConnectionState.connected) {
      _manager.publish(_nameController.text.toString() + ': ' + _chatMsgController.text.toString());
      _chatMsgController.clear();
    }
  }

}

