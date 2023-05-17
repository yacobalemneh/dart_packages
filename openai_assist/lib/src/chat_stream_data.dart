import 'dart:async';
import 'dart:convert';

class ChatStreamData {
  final String id;
  final String object;
  final int created;
  final String model;
  final List<dynamic> choices;
  final String rawJsonData;
  final bool isDone;

  ChatStreamData({
    required this.id,
    required this.object,
    required this.created,
    required this.model,
    required this.choices,
    required this.rawJsonData,
    required this.isDone,
  });
  factory ChatStreamData.fromJson(String rawData) {
    if (rawData == '[DONE]' || rawData.trim().isEmpty) {
      return ChatStreamData(
        id: '',
        object: '',
        created: 0,
        model: '',
        choices: [],
        rawJsonData: '',
        isDone: rawData == '[DONE]',
      );
    }

    final prefix = 'data: ';
    if (rawData.startsWith(prefix)) {
      rawData = rawData.substring(prefix.length);
    }
    Map<String, dynamic> jsonData = jsonDecode(rawData);
    return ChatStreamData(
      id: jsonData['id'],
      object: jsonData['object'],
      created: jsonData['created'],
      model: jsonData['model'],
      choices: jsonData['choices'],
      rawJsonData: rawData,
      isDone: false,
    );
  }
  void processData(void Function(String) onStreamData,
      StreamController<String> responseController) {
    if (choices.isEmpty || choices[0].toString().trim().isEmpty) {
      return;
    }

    if (isDone) {
      responseController.close();
      return;
    }

    if (choices.isEmpty) {
      return;
    }

    if (choices[0]['delta'] != null && choices[0]['delta']['content'] != null) {
      onStreamData(choices[0]['delta']['content']);
      responseController.add(choices[0]['delta']['content']);
    } else if (choices.isNotEmpty && choices[0]['finish_reason'] == 'stop') {
      responseController.close();
    } else if (choices.isNotEmpty &&
        choices[0]['delta'] != null &&
        choices[0]['delta']['role'] != null) {
      onStreamData('Assistant: ');
      responseController.add('Assistant: ');
    }
  }
}
