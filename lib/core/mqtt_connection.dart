import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:mqtt5_client/mqtt5_client.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:nocode_commons/core/constants.dart';
import 'package:nocode_commons/core/user_session.dart';

import 'mqtt_tcp_client.dart' if (dart.library.html) 'mqtt_ws_client.dart'
    as mqtt;

class MqttConnection {
  static final MqttConnection _instance = MqttConnection._internal();

  MqttClient? _client;
  final List<MqttSubscription> _subs = [];

  factory MqttConnection() {
    return _instance;
  }

  MqttConnection._internal() {
    if (null != _client) {
      _client!.disconnect();
      _client = null;
    }
  }

  void connect() async {
    await Constants.lock.synchronized(() async {
      if (null != _client) return;

      final String clientId =
          '${UserSession().getAuthToken()}:${UserSession().getLoginResponse()!.connCounter}';
      _client ??= mqtt.create(clientId);
      _client?.logging(on: false);
      _client?.onConnected = _onConnected;
      _client?.onDisconnected = _onDisconnected;
      _client?.onUnsubscribed = _onUnsubscribed;
      _client?.onSubscribed = _onSubscribed;
      _client?.onSubscribeFail = _onSubscribeFail;
      _client?.pongCallback = _pong;
      _client?.keepAlivePeriod = 60;
      _client?.autoReconnect = true;

      //_client?.keepAlive = MqttConnectionKeepAlive(connectionHandler, eventBus, keepAliveSeconds)

      //client.websocketProtocols = ['mqtt'];

      final connMess =
          MqttConnectMessage().withClientIdentifier(clientId).startClean();

      _client?.connectionMessage = connMess;

      try {
        debugPrint('Connecting');

        if (_client?.connectionStatus?.state ==
            MqttConnectionState.disconnected) {
          await _client?.connect();
        }

        if (_client?.connectionStatus?.state != MqttConnectionState.connected) {
          debugPrint('** MQTT NOT CONNECTED **');
        } else {
          debugPrint('** MQTT CONNECTED **');
          final String topic =
              '/${UserSession().getLoginResponse()!.user!.domainKey}/log/twin/#';

          try {
            for (var s in _subs) {
              //_client?.unsubscribeSubscription(s);
            }
            _subs.clear();
          } catch (e) {}

          _client?.subscribe(topic, MqttQos.atMostOnce);

          _client?.updates.listen(cancelOnError: false,
              (List<MqttReceivedMessage<MqttMessage>> c) async {
            try {
              final MqttPublishMessage message =
                  c[0].payload as MqttPublishMessage;
              String payload =
                  const AsciiDecoder().convert(message.payload.message!);

              debugPrint('topic:${c[0].topic} message:$payload');

              final Map<String, dynamic> msg = jsonDecode(payload);

              switch (msg['type'] ?? 'unknown') {
                case 'message':
                  BaseState.layoutEvents.emit(
                      PageEvent.twinMessageReceived.name,
                      this,
                      msg['deviceId'] as String);
                  break;
                default:
                  debugPrint('unknown message type:${msg['type']} discarded');
                  break;
              }
            } catch (e, s) {
              debugPrint('$e\n$s');
            }
          });
        }
      } catch (e) {
        debugPrint('Exception: $e');
        _client?.disconnect();
      }
    });
  }

  void disconnect() {
    if (null == _client) return;
    _client?.disconnect();
    _client = null;
  }

  void _onConnected() {
    //debugPrint('Connected, now subscribing...');
  }

  void _onDisconnected() {
    debugPrint('Disconnected');
  }

  void _onSubscribed(MqttSubscription sub) {
    debugPrint('Subscribed topic: ${sub.topic}');
    _subs.add(sub);
  }

  void _onSubscribeFail(MqttSubscription sub) {
    debugPrint('Failed to subscribe topic: ${sub.topic}');
  }

  void _onUnsubscribed(MqttSubscription sub) {
    debugPrint('Unsubscribed topic: ${sub.topic}');
  }

  void _pong() {
    debugPrint('Ping response client callback invoked');
  }
}
