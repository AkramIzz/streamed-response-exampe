import 'dart:convert';

import 'package:http/http.dart';

void main(List<String> args) async {
  const url = 'http://localhost:8888/people';

  // wait for all documents to be recieved
  // body == {id: 1, name: Mr. Nice}{id: 2, name: Mr. Ugly}{..}...
  final body = await get(url).then((r) => r.body);
  try {
    // throws a FormatException since body isn't valid json.
    print(jsonDecode(body));
  } on FormatException {
    print('body = $body \n');
  }

  // or get documents as they are recieved
  final client = Client();
  final streamedResponse = await client.send(Request('get', Uri.parse(url)));
  final jsonStream = const Utf8Decoder()
      .bind(streamedResponse.stream)
      .map((str) => json.decode(str) as Map<String, dynamic>);
  await jsonStream.forEach((json) {
    assert(json is Map<String, dynamic>);
    print(json);
  });

  client.close();
}
