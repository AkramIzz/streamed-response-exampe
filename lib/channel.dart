import 'dart:convert';

import 'people.dart';

class AppChannel extends ApplicationChannel {
  final _people = [
    {'id': 1, 'name': 'Mr. Nice'},
    {'id': 2, 'name': 'Mr. Ugly'},
    {'id': 3, 'name': 'Mr. Polite'},
    {'id': 4, 'name': 'Mr. Felony'},
    {'id': 5, 'name': 'Mr. Crime'},
    {'id': 6, 'name': 'Mr. Handsome'},
  ];

  @override
  Future prepare() async {
    logger.onRecord.listen(
        (rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));
  }

  @override
  Controller get entryPoint {
    final router = Router();

    router.route('/people/[:id]').linkFunction((request) {
      final controller = StreamController<Map<String, dynamic>>();

      controller.onListen = () {
        int nextPersonIndex = 0;
        Timer.periodic(const Duration(milliseconds: 300), (t) {
          controller.add(_people[nextPersonIndex++]);

          if (nextPersonIndex >= _people.length) {
            controller.close();
            t.cancel();
          }
        });
      };

      return Response.ok(controller.stream.map(json.encode))
        ..bufferOutput = false
        ..contentType = ContentType('text', 'event-stream', charset: 'utf-8');
    });

    return router;
  }
}
