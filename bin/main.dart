import 'package:alfred/alfred.dart';
import 'package:zaptools_server/zaptools_server.dart';

void main(List<String> arguments) async {

  final app = Alfred();

  final eventRegister = EventRegister();
  final room = Room("chats");

  eventRegister.onEvent("join-room", (context) { 
    room.add(context.connection);
    room.send("user-joined", context.eventData.payload, exclude: context.connection);
  });

  eventRegister.onDisconnected((context) {
    room.remove(context.connection);
    room.send("user-left", "Alguien", exclude: context.connection);
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
