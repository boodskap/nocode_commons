import 'package:mqtt5_client/mqtt5_client.dart';
import 'package:mqtt5_client/mqtt5_server_client.dart';
import 'package:nocode_commons/core/constants.dart';

MqttClient create(String clientId) {
  return MqttServerClient.withPort(mqttTcpUrl, clientId, mqttTcpPort);
}
