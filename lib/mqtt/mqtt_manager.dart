import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttManager {
  late MqttServerClient client;
  Function(String, String)? onMessageReceived;
  Function()? onConnected;

  MqttManager({this.onMessageReceived, this.onConnected}) {
    client = MqttServerClient('broker.emqx.io', '');
    client.port = 1883;
    client.logging(on: true);
    client.onDisconnected = onDisconnected;
    client.onConnected = _onConnectedHandler;
    client.onSubscribed = onSubscribed;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier('flutter_client')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    client.connectionMessage = connMessage;
  }

  void connect() async {
    try {
      await client.connect();
    } catch (e) {
      print('Exception during connection: $e');
      _disconnectOnError();
      return;
    }

    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      print('MQTT client connected');
      _resubscribeToTopics();
      _listenForMessages();
    } else {
      print('ERROR: MQTT client connection failed');
      _disconnectOnError();
    }
  }

  void _resubscribeToTopics() {
    final topics = ['emn', 'temperature', 'distance', 'fan'];
    topics.forEach((topic) => subscribeToTopic(topic));
  }

  void _listenForMessages() {
    client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
      final String pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      print('Received message: $pt from topic: ${c[0].topic}');
      if (onMessageReceived != null) {
        onMessageReceived!(c[0].topic, pt);
      }
    });
  }

  void subscribeToTopic(String topic) {
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      print('Subscribing to the $topic topic');
      client.subscribe(topic, MqttQos.atLeastOnce);
    } else {
      print('ERROR: MQTT client is not connected');
    }
  }

  void publishMessage(String message) {
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      final builder = MqttClientPayloadBuilder();
      builder.addString(message);
      print('Publishing message: $message to topic: emn');
      client.publishMessage('emn', MqttQos.atLeastOnce, builder.payload!);
    } else {
      print('ERROR: MQTT client is not connected');
    }
  }

  void _disconnectOnError() {
    client.disconnect();
  }

  void onDisconnected() {
    print('Disconnected');
  }

  void _onConnectedHandler() {
    print('Connected');
    if (onConnected != null) {
      onConnected!();
    }
  }

  void onSubscribed(String topic) {
    print('Subscribed to $topic');
  }
}
