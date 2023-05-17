import 'dart:io';
import 'src/openai_assist_internal.dart';


Future<void> main() async {
  final openAiAssist = OpenAiAssist(
    apiKey: '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'
  );

  print('Choose a number from 1-4 to select an operation:');
  print('1. Normal chat completion');
  print('2. Stream chat completion');
  print('3. Normal completion');
  print('4. Stream completion');

  String? input = stdin.readLineSync();

  if (input == null) {
    print('No input provided');
    return;
  }

  List<Message> messages = [
    Message(role: 'user', content: 'tell me a joke'),
  ];

  try {
    switch (input) {
      case '1':
        // Normal chat completion
        CompletionResponse normalChatResponse = await openAiAssist.createChatCompletion(
          OpenAiModel.gpt4,
          messages,
          responseType: OpenAiResponseType.normal,
          parameters: CompletionParameters(
            temperature: 0.8,
            maxTokens: 50,
          ),
        );
        print('Normal chat response: ${normalChatResponse.text}');
        print('Normal chat response usage: ${normalChatResponse.usage}');
        break;
      case '2':
        // Stream chat completion
        CompletionResponse streamChatCompletionResponse =
            await openAiAssist.createChatCompletion(
          OpenAiModel.gpt4,
          messages,
          responseType: OpenAiResponseType.stream,
          parameters: CompletionParameters(
            temperature: 0.8,
            maxTokens: 50,
          ),
          onStreamData: (completionResponse) {
            // You can still use this callback if you want to do something with each chunk of data.
            print("Chat: ${completionResponse.text}");
          },
        );
        break;
      case '3':
        // Normal completion
        CompletionResponse normalCompletionResponse = await openAiAssist.createCompletion(
          OpenAiModel.gpt3,
          'tell me a joke',
          responseType: OpenAiResponseType.normal,
          parameters: CompletionParameters(
            temperature: 0.8,
            maxTokens: 50,
          ),
        );
        print('Normal completion response: ${normalCompletionResponse.text}');
        print('Normal completion response usage: ${normalCompletionResponse.usage}');
        break;
      case '4':
        // Stream completion
        CompletionResponse streamCompletion = await openAiAssist.createCompletion(
          OpenAiModel.gpt3,
          'tell me a joke',
          responseType: OpenAiResponseType.stream,
          parameters: CompletionParameters(
            temperature: 0.8,
            maxTokens: 50,
          ),
          onStreamData: (completionResponse) {
            print('GPT3: ${completionResponse.text}');
          },
        );
        break;
      default:
        print('Invalid input');
    }
  } catch (e) {
    print('Error in main: $e');
  }
}
