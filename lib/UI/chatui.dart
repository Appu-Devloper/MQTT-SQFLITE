import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

// Define a class to represent each message
class Message {
  final String content;
  final String sender;
  final DateTime timestamp;

  Message({
    required this.content,
    required this.sender,
    required this.timestamp,
  });
}

class Chatpage extends StatefulWidget {
  final MqttServerClient client;

  const Chatpage({Key? key, required this.client}) : super(key: key);

  @override
  State<Chatpage> createState() => _ChatpageState();
}

class _ChatpageState extends State<Chatpage> {
  final TextEditingController publishController = TextEditingController();
  final TextEditingController subscribeController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  String publishTopic = '';
  String subscribeTopic = '';
  List<Message> messages = []; // List to store messages

  @override
  void dispose() {
    publishController.dispose();
    subscribeController.dispose();
    widget.client.disconnect();
    super.dispose();
  }

  void _publishMessage(String message) {
    try {
      final builder = MqttClientPayloadBuilder();
      builder.addString(message);
      widget.client
          .publishMessage(publishTopic, MqttQos.atLeastOnce, builder.payload!);

      print('Successfully published: $message');

      // Add sent message to the list
      messages.add(Message(
        content: message,
        sender: 'You',
        timestamp: DateTime.now(),
      ));

      // Update the UI
      setState(() {});
    } catch (e) {
      print('Failed to publish message: $e');
    }
  }

  void _subscribeToTopic(String topic) {
    try {
      widget.client.subscribe(topic, MqttQos.atLeastOnce);

      widget.client.updates!.listen(
        (List<MqttReceivedMessage<MqttMessage>> event) {
          final MqttPublishMessage receivedMessage =
              event[0].payload as MqttPublishMessage;
          final String message = MqttPublishPayload.bytesToStringAsString(
              receivedMessage.payload.message);

          print('Successfully received: $message');

          // Check if the message already exists in the messages list
          final thresholdTime = DateTime.now().subtract(Duration(seconds: 1));

          // Check if the message already exists in the messages list within the threshold time
          bool messageExists = messages.any((m) =>
              m.content == message &&
              m.sender == 'Other' &&
              m.timestamp.isAfter(thresholdTime));

          // Add received message to the list only if it doesn't already exist
          if (!messageExists) {
            messages.add(Message(
              content: message,
              sender: 'Other',
              timestamp: DateTime.now(),
            ));

            // Update the UI
            setState(() {});
          }
        },
      );
    } catch (e) {
      print('Failed to subscribe to topic: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didpop) async {
        final navigator = Navigator.of(context);
        bool value = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Disconnect MQTT?'),
              content: Text('Do you want to disconnect MQTT and Exit?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true); // Disconnect MQTT
                  },
                  child: Text('Yes'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false); // Don't disconnect MQTT
                  },
                  child: Text('No'),
                ),
              ],
            );
          },
        );

        if (value) {
          widget.client.disconnect();
          navigator.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'MQTT',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ExpansionTile(
                initiallyExpanded: true,
                title: Text(
                  'Set Publish and Subscribe',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
                children: [
                  TextFormField(
                    controller: publishController,
                    decoration: InputDecoration(labelText: 'Publish Message'),
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: subscribeController,
                    decoration: InputDecoration(labelText: 'Subscribe Topic'),
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        publishTopic = publishController.text;
                        subscribeTopic = subscribeController.text;
                      });

                      _subscribeToTopic(subscribeTopic);
                    },
                    child: Text('Set Topics'),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              Expanded(
                child: ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return ListTile(
                      title: Text(message.sender),
                      subtitle: Text(message.content),
                      trailing: Text(
                          '${message.timestamp.hour}:${message.timestamp.minute}'),
                    );
                  },
                ),
              ),
              TextFormField(
                controller: messageController,
                decoration: InputDecoration(
                  labelText: 'Enter Message to Publish',
                  suffixIcon: IconButton(
                    onPressed: () {
                      _publishMessage(messageController.text);
                      messageController.clear();
                    },
                    icon: Icon(Icons.send),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
