import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:openai_assist/src/openai_assist_internal.dart';

class MockClient extends Mock implements http.Client {}

void main() {
  group('ApiService', () {
    test('returns a Stream if the http call completes successfully', () async {
      final client = MockClient();
      final apiService = ApiService(
        baseUrl: 'https://api.example.com',
        apiKey: 'some-api-key',
        headers: {'Authorization': 'Bearer some-token'},
      );
      final endpoint = '/endpoint';
      final body = {'key': 'value'};
      final responseType = OpenAiResponseType.normal;

      when(client.post(Uri(path: 'https://api.example.com/endpoint'),
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) => Future.value(http.Response('Success', 200)));

      expect(
          apiService.post(endpoint, body, responseType),
          emitsInOrder([
            'Success',
            emitsDone,
          ]));
    });
  });
}
