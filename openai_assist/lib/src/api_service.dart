import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'openai_response_types.dart';


class ApiService {
  ApiService({
    required this.baseUrl,
    required this.apiKey,
    required this.headers,
  });

  final String baseUrl;
  final String apiKey;
  final Map<String, String> headers;


FutureOr<Stream<String>> post(
  String endpoint,
  Map<String, dynamic> body,
  OpenAiResponseType responseType,
) async {
  if (responseType == OpenAiResponseType.normal) {
    final response = await http.post(
      Uri.parse(baseUrl + endpoint),
      headers: headers,
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      return Stream.fromIterable([response.body]);
    } else {
      throw Exception(response.reasonPhrase);
    }
  } else {
    final request = http.Request('POST', Uri.parse(baseUrl + endpoint))
      ..headers.addAll(headers)
      ..body = json.encode(body);
    final response = await request.send();
    if (response.statusCode == 200) {

      if (responseType == OpenAiResponseType.stream) {
        print('Received 200 status code for stream responseType');
        final decodedStream = response.stream.transform(utf8.decoder).asBroadcastStream();
        return decodedStream;
      } else {
        final streamController = StreamController<String>();
        response.stream.transform(utf8.decoder).transform(const LineSplitter()).listen(
          (data) {
            streamController.add(data);
          },
          onDone: () {
            streamController.close();
          },
          onError: (error) {
            streamController.addError(error);
            streamController.close();
          },
        );
        return streamController.stream;
      }
    } else {
      throw Exception(response.reasonPhrase);
    }
  }
}

  Future<String> uploadFile(
      String endpoint, String filePath, String model) async {
    final request = http.MultipartRequest('POST', Uri.parse(baseUrl + endpoint))
      ..headers.addAll(headers)
      ..fields['model'] = model;
    final file = await http.MultipartFile.fromPath(
      'file',
      filePath,
      contentType: MediaType('audio', 'mpeg'),
    );

    request.files.add(file);

    final response = await request.send();

    if (response.statusCode == 200) {
      return response.stream.bytesToString();
    } else {
      throw Exception(response.reasonPhrase);
    }
  }

  Future<String> transcribeAudio(String filePath, String model) async {
    return await uploadFile('audio/transcriptions', filePath, model);
  }
}

class _JsonSplitter extends StreamTransformerBase<String, String> {
  @override
  Stream<String> bind(Stream<String> stream) {
    late StreamController<String> controller;
    late StreamSubscription<String> subscription;
    StringBuffer buffer = StringBuffer();

    controller = StreamController<String>(
      onListen: () {
        subscription = stream.listen(
          (data) {
            buffer.write(data);
            String bufferString = buffer.toString();
            int startPos = 0;
            int endPos;

            while ((endPos = bufferString.indexOf('}', startPos)) != -1) {
              String jsonString = bufferString.substring(startPos, endPos + 1);
              controller.add(jsonString);
              startPos = endPos + 1;
            }

            if (startPos > 0) {
              buffer = StringBuffer(bufferString.substring(startPos));
            }
          },
          onError: controller.addError,
          onDone: () {
            if (buffer.isNotEmpty) {
              controller.add(buffer.toString());
            }
            controller.close();
          },
          cancelOnError: false,
        );
      },
      onPause: () => subscription.pause(),
      onResume: () => subscription.resume(),
      onCancel: () => subscription.cancel(),
    );

    return controller.stream;
  }
}

