# Dart OpenAI Assist

This repository contains Dart classes for handling OpenAI's GPT-3 and ChatGPT responses. It provides abstraction for both streaming and non-streaming responses. The classes are designed to be flexible, with support for different OpenAI models and response types.

## Files

- `openai_assist_internal.dart`: Contains definitions for the OpenAiModel and OpenAiResponseType enums used throughout the code.
- `main.dart`: Contains the main code with classes and their implementations.

## Classes

1. `CompletionResponse`: An abstract class that provides basic structure for all types of completion responses. It includes the response text, metadata, and usage information.

2. `StreamCompletionResponse`: An abstract class that extends `CompletionResponse`, specifically for handling streaming responses. It includes functionality to process response streams and individual JSON data.

3. `Gpt3StreamCompletionResponse` and `ChatGptStreamCompletionResponse`: These classes extend `StreamCompletionResponse` and override the method to process JSON data according to the response from GPT-3 and ChatGPT models respectively.

4. `NonStreamCompletionResponse`: An abstract class extending `CompletionResponse`, specifically for handling non-streaming responses.

5. `GptNonStreamCompletionResponse` and `ChatGptNonStreamCompletionResponse`: These classes extend `NonStreamCompletionResponse` and construct the response from GPT-3 and ChatGPT models respectively.

## Usage

To use these classes, first determine whether the response from OpenAI is streaming or non-streaming. Then, create an instance of the appropriate class (Gpt3 or ChatGPT, Stream or NonStream), passing the response JSON data, response type, and model type to the constructor.

For `StreamCompletionResponse`, also pass the response stream and an optional callback function to be invoked whenever new data is processed from the stream.

## Logging

The `Logger` class from the `logging` package is used to log informational messages, specifically errors encountered during data processing.

## Future Improvements

- Find a better way to handle JSON objects in `StreamCompletionResponse.processResponseStream()`.
- Increase the robustness of error handling in the `processJsonData()` methods of `Gpt3StreamCompletionResponse` and `ChatGptStreamCompletionResponse`.

## Dependencies

- Dart SDK
- `logging` package

## Contributing

Please read CONTRIBUTING.md for details on our code of conduct, and the process for submitting pull requests.

## License

This project is licensed under the MIT License - see the LICENSE.md file for details.