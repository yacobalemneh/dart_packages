import 'dart:async';
import 'dart:convert';
import 'openai_assist_internal.dart';


class OpenAiAssist {
  OpenAiAssist({required String apiKey})
      : assert(apiKey.isNotEmpty),
        _apiService = ApiService(
          baseUrl: 'https://api.openai.com',
          apiKey: apiKey,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
        );

  final ApiService _apiService;

 Future<CompletionResponse> createChatCompletion(
    OpenAiModel model,
    List<Message> messages, {
    OpenAiResponseType responseType = OpenAiResponseType.normal,
    CompletionParameters? parameters,
    void Function(CompletionResponse)? onStreamData,
  }) async {
    if (!OpenAiModelUtils.chatCompletionModels.contains(model)) {
      throw ArgumentError('Invalid model for chat completion');
    }
    final formattedMessages = Message.formatMessages(messages);
    final body = {
      'model': model.value,
      'messages': formattedMessages,
      if (responseType == OpenAiResponseType.stream) 'stream': true,
      ...?parameters?.toJson(),
    };

    final responseStream = await _apiService.post(
      OpenAiEndpoint.chatCompletions,
      body,
      responseType,
    );
    if (responseType == OpenAiResponseType.stream) {
      return ChatGptStreamCompletionResponse.fromStream(
        {}, // initial empty metadata
        responseStream,
        onStreamData,
      );
    } else {
      StringBuffer responseBuffer = StringBuffer();
      await for (String data in responseStream) {
        responseBuffer.write(data);
      }
      Map<String, dynamic> jsonResponse =
          json.decode(responseBuffer.toString());
      return CompletionResponse.fromJson(
        jsonResponse,
        model,
        responseType,
        Stream.empty(),
        null,
      );
    }
  }

Future<CompletionResponse> createCompletion(OpenAiModel model, String prompt,
      {OpenAiResponseType responseType = OpenAiResponseType.normal,
      CompletionParameters? parameters,
      void Function(CompletionResponse)? onStreamData}) async {
    if (!OpenAiModelUtils.completionModels.contains(model)) {
      throw ArgumentError('Invalid model for completion');
    }
    final body = {
      'model': model.value,
      'prompt': prompt,
      if (responseType == OpenAiResponseType.stream) 'stream': true,
      ...?parameters?.toJson(),
    };

    final responseStream = await _apiService.post(
      OpenAiEndpoint.completions,
      body,
      responseType,
    );

    if (responseType == OpenAiResponseType.stream) {
      return Gpt3StreamCompletionResponse.fromStream(
        {}, // initial empty metadata
        responseStream,
        onStreamData,
      );
    } else {
      StringBuffer responseBuffer = StringBuffer();
      await for (String data in responseStream) {
        responseBuffer.write(data);
      }
      Map<String, dynamic> jsonResponse =
          json.decode(responseBuffer.toString());

      return CompletionResponse.fromJson(
        jsonResponse,
        model,
        responseType,
        Stream.empty(),
        null,
      );
    }
  }

  Future<String> transcribeAudio(
    OpenAiModel model,
    String filePath,
  ) async {
    if (!OpenAiModelUtils.speechToTextModels.contains(model)) {
      throw ArgumentError('Invalid model for speech to text');
    }
    return await _apiService.transcribeAudio(filePath, model.value);
  }
}
