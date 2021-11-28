import 'package:flutter/cupertino.dart';

enum ChatRoomConnectionState { connected, disconnected, connecting }

class ChatRoomStateProvider with ChangeNotifier{
  ChatRoomConnectionState _appConnectionState = ChatRoomConnectionState.disconnected;
  String _receivedText = '';
  String _historyText = '';

  String get getReceivedText => _receivedText;
  void setReceivedText(String text) {
    _receivedText = text;
    _historyText = _historyText + '\n' + _receivedText;
    notifyListeners();
  }

  ChatRoomConnectionState get getAppConnectionState => _appConnectionState;
  void setAppConnectionState(ChatRoomConnectionState state) {
    _appConnectionState = state;
    notifyListeners();
  }

  String get getHistoryText => _historyText;

}