import 'package:flutter/cupertino.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:mqttchatterbox/pages/chatroom/state_chat_room.dart';

class MQTTChatRoomManager extends ChangeNotifier  {
  // Private instance of client
  final ChatRoomStateProvider _currentState;
  MqttServerClient? _client;
  final String _identifier;
  final String _host;
  final String _topic;
  final int _port;

  // Constructor
  // ignore: sort_constructors_first
  MQTTChatRoomManager(
      {required String host,
        required int port,
        required String topic,
        required String identifier,
        required ChatRoomStateProvider state})
      : _identifier = identifier,
        _host = host,
        _port = port,
        _topic = topic,
        _currentState = state;

  void initializeMQTTClient() {
    _client = MqttServerClient(_host, _identifier);
    _client!.port = _port;//1883;
    _client!.keepAlivePeriod = 2000;
    _client!.secure = false;
    _client!.websocketProtocols = ['mqtt'];
    _client!.logging(on: true);

    /// Add the successful connection callback
    _client!.onConnected = onConnected;
    _client!.onSubscribed = onSubscribed;
    _client!.onDisconnected = onDisconnected;

    final MqttConnectMessage connMess = MqttConnectMessage()
        .withClientIdentifier(_identifier)
        .withWillTopic('willtopic') // If you set this you must set a will message
        .withWillMessage('My Will message')
        .startClean() // Non persistent session for testing
        .withWillQos(MqttQos.atLeastOnce);
    print('Local Log: client connecting....');
    _client!.connectionMessage = connMess;
  }

  // Connect to the host
  // ignore: avoid_void_async
  void connect() async {
    assert(_client != null);
    try {
      print('Local Log: start client connecting....');
      _currentState.setAppConnectionState(ChatRoomConnectionState.connecting);
      await _client!.connect();
    } on Exception catch (e) {
      print('Local Log: client exception - $e');
      disconnect();
    }
  }

  void connectWithIdPass(String userName, String pass) async {
    assert(_client != null);
    try {
      print('Local Log: start client connecting....');
      _currentState.setAppConnectionState(ChatRoomConnectionState.connecting);
      await _client!.connect(userName, pass);
    } on Exception catch (e) {
      print('Local Log: client exception - $e');
      disconnect();
    }
  }

  void disconnect() {
    print('Disconnected');
    _client!.disconnect();
  }

  void publish(String message) {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);
    _client!.publishMessage(_topic, MqttQos.exactlyOnce, builder.payload!);
  }

  /// The subscribed callback
  void onSubscribed(String topic) {
    print('Local Log: Subscription confirmed for topic $topic');
  }

  /// The unsolicited disconnect callback
  void onDisconnected() {
    print('Local Log: OnDisconnected client callback - Client disconnection');
    if (_client!.connectionStatus!.returnCode ==
        MqttConnectReturnCode.noneSpecified) {
      print('Local Log: OnDisconnected callback is solicited, this is correct');
    }
    _currentState.setAppConnectionState(ChatRoomConnectionState.disconnected);
  }

  /// The successful connect callback
  void onConnected() {
    _currentState.setAppConnectionState(ChatRoomConnectionState.connected);
    print('Local Log: client connected....');
    _client!.subscribe(_topic, MqttQos.atLeastOnce);
    _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      // ignore: avoid_as
      final MqttPublishMessage recMess = c![0].payload as MqttPublishMessage;

      // final MqttPublishMessage recMess = c![0].payload;
      final String pt =
      MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      _currentState.setReceivedText(pt);
      print(
          'Local Log: Change notification:: topic is <${c[0].topic}>, payload is <-- $pt -->');
      print('');
    });
    print(
        'Local Log: OnConnected client callback - Client connection was successful');
  }
}