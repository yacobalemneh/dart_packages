import 'dart:async';
import 'dart:convert';
import 'openai_assist_internal.dart';
import 'package:logging/logging.dart';

final log = Logger('InfoLogger');

abstract class CompletionResponse {
  String text;
  final Map<String, dynamic> metadata;
  late Map<String, dynamic> usage;

  String get responseText;
  int get tokenCount;

  CompletionResponse(
      {required this.text, required this.metadata, required this.usage});

  factory CompletionResponse.fromJson(
    Map<String, dynamic> json,
    OpenAiModel model,
    OpenAiResponseType responseType,
    Stream<String> responseStream,
    void Function(CompletionResponse)? onStreamData,
  ) {
    if (responseType == OpenAiResponseType.stream) {
      if (model == OpenAiModel.gpt3) {
        return Gpt3StreamCompletionResponse.fromStream(
            json, responseStream, onStreamData);
      } else {
        return ChatGptStreamCompletionResponse.fromStream(
            json, responseStream, onStreamData);
      }
    } else {
      if (model == OpenAiModel.gpt3) {
        return GptNonStreamCompletionResponse.fromGpt3Json(json);
      } else {
        return ChatGptNonStreamCompletionResponse.fromChatGptJson(json);
      }
    }
  }
}

abstract class StreamCompletionResponse extends CompletionResponse {
  StringBuffer response;
  int tokens = 0;
  StreamController<String> responseController;
  String? role;
  String? id;
  String? object;
  int? created;
  String? model;

  StreamCompletionResponse({
    required this.response,
    required Map<String, dynamic> metadata,
    required Map<String, dynamic>? usage,
    required this.responseController,
  }) : super(
          text: response.toString(),
          metadata: metadata,
          usage: usage ?? {},
        );

  void processResponseStream(Stream<String> responseStream,
      void Function(CompletionResponse)? onStreamData) async {
    await for (String data in responseStream) {
      if (data == '[DONE]' || data.contains('[DONE]')) {
        responseController.close();
        break;
      }
      if (data.startsWith('data: ')) {
        data = data.substring('data: '.length);
        data = data.trim();
      }
      if (data.contains('}{')) {
        List<String> dataParts = data.split('}{');
        for (String part in dataParts) {
          if (!part.startsWith('{')) {
            part = '{' + part;
          }
          if (!part.endsWith('}')) {
            part = part + '}';
          }
          processJsonData(part, onStreamData);
        }
      } else {
         // function to process each JSON object
         // TODO: Find a better way to handle this

          if (data.contains('role')) {
          List<String> lines = data.split('\n');
          for (String line in lines) {
            processJsonData(
                line, onStreamData);
          }
        } else {
          processJsonData(data, onStreamData);
        }
      }
    }
  }

  void processJsonData(
      String data, void Function(CompletionResponse)? onStreamData);

  @override
  String get responseText => response.toString();
  @override
  int get tokenCount => tokens;

  @override
  String get text => response.toString();
}

class Gpt3StreamCompletionResponse extends StreamCompletionResponse {
  String? finishReason;

  Gpt3StreamCompletionResponse.fromStream(
      Map<String, dynamic> json,
      Stream<String> responseStream,
      void Function(CompletionResponse)? onStreamData)
      : super(
          response: StringBuffer(),
          metadata: json,
          usage: json['usage'],
          responseController: StreamController<String>(),
        ) {
    processResponseStream(responseStream, onStreamData);
  }

  @override
  void processJsonData(
      String data, void Function(CompletionResponse)? onStreamData) {
    try {
      Map<String, dynamic> jsonData = jsonDecode(data);

      if (jsonData.containsKey('choices') && jsonData['choices'].isNotEmpty) {
        Map<String, dynamic>? choice = jsonData['choices'][0];
        if (choice != null) {
          if (choice.containsKey('text') && choice['text'] != null) {
            response.write(choice['text']);
          }
          if (choice['finish_reason'] == null) {
            tokens++;
          }
          if (choice.containsKey('finish_reason') &&
              choice['finish_reason'] != null) {
            finishReason = choice['finish_reason'];
          }
        }
      }

      if (metadata.isEmpty) {
        metadata.addAll(jsonData);
        usage = jsonData['usage'];
        id = jsonData['id'];
        object = jsonData['object'];
        created = jsonData['created'];
        model = jsonData['model'];
      }

      if (onStreamData != null) {
        onStreamData(this);
      }
    } catch (e) {
      print('Error in data processing in completion response: $e');
    }
  }
}

class ChatGptStreamCompletionResponse extends StreamCompletionResponse {
  String? finishReason;

  ChatGptStreamCompletionResponse.fromStream(
      Map<String, dynamic> json,
      Stream<String> responseStream,
      void Function(CompletionResponse)? onStreamData)
      : super(
          response: StringBuffer(),
          metadata: json,
          usage: json['usage'],
          responseController: StreamController<String>(),
        ) {
    processResponseStream(responseStream, onStreamData);
  }

    @override
      void processJsonData(
      String data, void Function(CompletionResponse)? onStreamData) {
    try {
      Map<String, dynamic> jsonData;

      try {
        if (data.startsWith('data: ')) {
          data = data.substring('data: '.length);
          data = data.trim();
          data = data.replaceAll('\n', ''); // remove newline characters
        }
        jsonData = jsonDecode(data);
      } catch (e) {
        return;
      }
      if (jsonData.containsKey('choices') && jsonData['choices'].isNotEmpty) {
        Map<String, dynamic>? choice = jsonData['choices'][0];
        if (choice != null) {
          if (choice.containsKey('delta') && choice['delta'] != null) {
            var delta = choice['delta'] as Map<String, dynamic>;
            if (delta.containsKey('content') && delta['content'] != null) {
              response.write(delta['content']);
            } else if (delta.containsKey('role') && delta['role'] != null) {
              role = delta['role'];
            } else {
              print('Delta NULL');
            }
          }
          if (choice['finish_reason'] == null) {
            tokens++;
          }
          if (choice.containsKey('finish_reason') &&
              choice['finish_reason'] != null) {
            finishReason = choice['finish_reason'];
          }
        }
      }
      if (metadata.isEmpty) {
        metadata.addAll(jsonData);
        usage = jsonData['usage'];
        id = jsonData['id'];
        object = jsonData['object'];
        created = jsonData['created'];
        model = jsonData['model'];
      }
      if (onStreamData != null) {
        onStreamData(this);
      }
    } catch (e) {
      log.info('Error in data processing in completion response: $e');
    }
  }
}

abstract class NonStreamCompletionResponse extends CompletionResponse {
  NonStreamCompletionResponse({
    required String text,
    required Map<String, dynamic> metadata,
    required Map<String, dynamic> usage,
  }) : super(text: text, metadata: metadata, usage: usage);

  @override
  String get responseText => text;

  @override
  int get tokenCount => usage['total_tokens'];
}

class GptNonStreamCompletionResponse extends NonStreamCompletionResponse {
  GptNonStreamCompletionResponse.fromGpt3Json(Map<String, dynamic> json)
      : super(
          text: json['choices'][0]['text'],
          metadata: json,
          usage: json['usage'],
        );
}

class ChatGptNonStreamCompletionResponse extends NonStreamCompletionResponse {
  ChatGptNonStreamCompletionResponse.fromChatGptJson(Map<String, dynamic> json)
      : super(
          text: json['choices'][0]['message']['content'],
          metadata: json,
          usage: json['usage'],
        );
}
