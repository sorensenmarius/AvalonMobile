import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:signalr_client/signalr_client.dart';

void main() {
  runApp(MyApp());
}

class Game {
  String id;
  String joinCode;
  List<Player> players;
  int status;

  Game.fromJson(Map<String, dynamic> json) 
    : id = json['id'],
    joinCode = json['joinCode'],
    players = createPlayers(json['players']),
    status = json['status'];

}

class Player {
  String id;
  String name;
  int role;

  Player(this.id, this.name, this.role);
}

List<Player> createPlayers(List<dynamic> players) {
  List<Player> l = new List();
  players.forEach((p) {
    Player pl = new Player(p["id"], p["name"], p["role"]);
    l.add(pl);
  });
  return l;
}

final serverUrl = "http://10.0.0.17:45455/gameHub";

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.green,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Avalon App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final joinCodeController = TextEditingController();
  final nameController = TextEditingController();
  final socket = HubConnectionBuilder().withUrl(serverUrl).build();
  Game g;


  Map<String,String> headers = {
    'Content-type' : 'application/json', 
    'Accept': 'application/json',
  };

  void joinGame() async {
    http.Response res = await -http.post("http://10.0.0.17:45455/api/services/app/Player/Create", headers: headers, body: json.encode({
      'name': nameController.text,
      'joinCode': joinCodeController.text.trim()
    }));
    Map<String, dynamic> r = jsonDecode(res.body);
    g = new Game.fromJson(r["result"]);
    if(socket.state == HubConnectionState.Disconnected) await socket.start();
    await socket.invoke("JoinGameGroup", args: <Object>[g.id]);

    socket.on("GameUpdated", (args) {
      print("Fikk svar tilbake");
     });
  }



  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 2, // 20%
              child: Container(),
            ),
            Expanded(
              flex: 6, // 60%
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextField(
                    keyboardType: TextInputType.number,
                    controller: joinCodeController,
                    decoration: const InputDecoration(
                      labelText: 'Game Code'
                    )
                  ),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name'
                    )
                  ),
                  RaisedButton(
                    onPressed: () {
                      joinGame();
                    },
                    child: Text('Join Game'),
                  )
                ],
              ),
            ),
            Expanded(
              flex: 2, // 20%
              child: Container(),
            )
          ]
        ),
      ),
    );
  }
}
