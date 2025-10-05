import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class Esp32TestScreen extends StatefulWidget {
  const Esp32TestScreen({super.key});

  @override
  State<Esp32TestScreen> createState() => _Esp32TestScreenState();
}

class _Esp32TestScreenState extends State<Esp32TestScreen> {
  final client = MqttServerClient('broker.hivemq.com', 'flutter_esp32_test_${DateTime.now().millisecondsSinceEpoch}');
  bool _ledOn = false;
  String _status = "Disconnected";
  String _lastLog = "-";

  @override
  void initState() {
    super.initState();
    _connectToMQTT();
  }

  Future<void> _connectToMQTT() async {
    client.logging(on: false);
    client.port = 1883;
    client.keepAlivePeriod = 20;
    client.onConnected = () => setState(() => _status = "Connected to HiveMQ");
    client.onDisconnected = () => setState(() => _status = "Disconnected");

    client.setProtocolV311();
    client.onSubscribed = (topic) => debugPrint('Subscribed to $topic');

    try {
      await client.connect();
      setState(() => _status = "Connected ✅");
      client.subscribe('pusa/led/state', MqttQos.atMostOnce);

      client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? messages) {
        final recMess = messages![0].payload as MqttPublishMessage;
        final message = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        if (messages[0].topic == 'pusa/led/state') {
          setState(() {
            _ledOn = (message == "ON");
            _lastLog = "LED ${_ledOn ? "ON" : "OFF"} @ ${TimeOfDay.now().format(context)}";
          });
        }
      });
    } catch (e) {
      setState(() => _status = "Connection failed: $e");
    }
  }

  void _toggleLED(bool value) {
    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      final builder = MqttClientPayloadBuilder();
      builder.addString(value ? "ON" : "OFF");
      client.publishMessage('pusa/led/toggle', MqttQos.atMostOnce, builder.payload!); 
      setState(() {
        _ledOn = value;
        _lastLog = "Toggled from app @ ${TimeOfDay.now().format(context)}";
      });
    }
  }

  @override
  void dispose() {
    client.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ESP32 LED Test"),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Card(
          elevation: 4,
          margin: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lightbulb_outline, size: 80, color: Colors.amber),
                const SizedBox(height: 20),
                Text("Status: $_status", style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("LED: ", style: TextStyle(fontSize: 18)),
                    Switch(
                      value: _ledOn,
                      onChanged: (value) => _toggleLED(value),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Last action: $_lastLog",
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Text(
                  _ledOn ? "💡 LED is ON" : "🌙 LED is OFF",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _ledOn ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
