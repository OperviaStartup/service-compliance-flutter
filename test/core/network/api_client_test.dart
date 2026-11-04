import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:service_compliance/core/network/api_client.dart';

void main() {
  group('ApiClient', () {
    for (final status in [401, 403]) {
      test('expone el código HTTP $status como ApiException', () async {
        final client = ApiClient(
          baseUrl: 'https://example.test',
          client: MockClient((request) async => http.Response('{}', status)),
        );
        addTearDown(client.close);

        await expectLater(
          client.get('/protected'),
          throwsA(
            isA<ApiException>()
                .having((error) => error.statusCode, 'statusCode', status)
                .having(
                  (error) => error.message,
                  'message',
                  'La API respondió con el código $status.',
                ),
          ),
        );
      });
    }

    test('envía el token Bearer en GET y POST', () async {
      final requests = <http.Request>[];
      final client = ApiClient(
        baseUrl: 'https://example.test',
        client: MockClient((request) async {
          requests.add(request);
          return http.Response('{}', 200);
        }),
      );
      addTearDown(client.close);

      await client.get('/protected', token: 'test-token');
      await client.post('/protected', token: 'test-token');

      expect(requests.map((request) => request.method), ['GET', 'POST']);
      expect(requests.map((request) => request.headers['authorization']), [
        'Bearer test-token',
        'Bearer test-token',
      ]);
    });

    test('convierte JSON inválido en ApiException', () async {
      final client = ApiClient(
        baseUrl: 'https://example.test',
        client: MockClient((request) async => http.Response('{invalid', 200)),
      );
      addTearDown(client.close);

      await expectLater(
        client.get('/data'),
        throwsA(
          isA<ApiException>()
              .having(
                (error) => error.message,
                'message',
                'La API devolvió una respuesta inválida.',
              )
              .having((error) => error.statusCode, 'statusCode', isNull),
        ),
      );
    });

    test(
      'envía el cuerpo JSON de POST y omite autorización sin token',
      () async {
        late http.Request captured;
        final client = ApiClient(
          baseUrl: 'https://example.test',
          client: MockClient((request) async {
            captured = request;
            return http.Response('{"created":true}', 201);
          }),
        );
        addTearDown(client.close);

        final result = await client.post('/data', body: {'name': 'ejemplo'});

        expect(captured.method, 'POST');
        expect(captured.url, Uri.parse('https://example.test/data'));
        expect(captured.headers['content-type'], 'application/json');
        expect(captured.headers['accept'], 'application/json');
        expect(captured.headers.containsKey('authorization'), isFalse);
        expect(jsonDecode(captured.body), {'name': 'ejemplo'});
        expect(result, {'created': true});
      },
    );

    test('devuelve null cuando la respuesta no tiene contenido', () async {
      final client = ApiClient(
        baseUrl: 'https://example.test',
        client: MockClient((request) async => http.Response('', 204)),
      );
      addTearDown(client.close);

      expect(await client.get('/data'), isNull);
    });

    test('convierte un fallo de conexión en ApiException', () async {
      final client = ApiClient(
        baseUrl: 'https://example.test',
        client: MockClient(
          (request) async => throw http.ClientException('offline'),
        ),
      );
      addTearDown(client.close);

      await expectLater(
        client.get('/data'),
        throwsA(
          isA<ApiException>().having(
            (error) => error.message,
            'message',
            'No se pudo conectar con la API.',
          ),
        ),
      );
    });

    testWidgets('convierte un timeout en ApiException', (tester) async {
      final response = Completer<http.Response>();
      final client = ApiClient(
        baseUrl: 'https://example.test',
        client: MockClient((request) => response.future),
      );
      addTearDown(client.close);

      final assertion = expectLater(
        client.get('/data'),
        throwsA(
          isA<ApiException>().having(
            (error) => error.message,
            'message',
            'La conexión con la API agotó el tiempo de espera.',
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 16));
      await assertion;
    });

    for (final url in ['', '/relative', 'ftp://example.test', 'http://[']) {
      test('rechaza la URL base inválida "$url" antes de enviar', () async {
        var requestsSent = 0;
        final client = ApiClient(
          baseUrl: url,
          client: MockClient((request) async {
            requestsSent++;
            return http.Response('{}', 200);
          }),
        );
        addTearDown(client.close);

        await expectLater(
          client.get('/data'),
          throwsA(
            isA<ApiException>()
                .having(
                  (error) => error.message,
                  'message',
                  'Configura una URL válida con API_BASE_URL.',
                )
                .having((error) => error.statusCode, 'statusCode', isNull),
          ),
        );
        expect(requestsSent, 0);
      });
    }
  });
}
