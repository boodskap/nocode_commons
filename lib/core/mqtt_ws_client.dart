import 'package:mqtt5_client/mqtt5_browser_client.dart';
import 'package:mqtt5_client/mqtt5_client.dart';
import 'package:nocode_commons/core/constants.dart';

MqttClient create(String clientId) {
  return MqttBrowserClient.withPort(mqttWsUrl, clientId, mqttWsPort);
}
