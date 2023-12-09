import 'package:alfred/alfred.dart';
import 'package:zaptools_server/zaptools_server.dart';

void main(List<String> arguments) async {

  final app = Alfred();

  final eventRegister = EventRegister();
  final room = Room("chats");

  eventRegister.onEvent("join-room", (context) {
    final meta = MetaTag(name: context.payload["userName"]);
    room.add(context.connection, metaTag: meta);
    room.send("user-joined", context.eventData.payload, exclude: context.connection);
  });

  eventRegister.onDisconnected((context) {
    final meta = room.getMeta(context.connection);
    room.remove(context.connection);
    print(meta);
    room.send("user-left", meta?.name ?? "unknow", exclude: context.connection);
  });

  eventRegister.onEvent("send", (context) {
    room.send("new-message", context.eventData.payload, exclude: context.connection);
   });


  app.get("/ws", (req, res){
    final connector = IOConnector(req, eventRegister);
    connector.start();
  });

  await app.listen(8080);


}
