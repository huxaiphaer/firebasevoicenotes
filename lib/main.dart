import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebasevoicenotes/audio_widget.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Firestore _firestore = Firestore.instance;

  Widget MyList() {
    return StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection("radioChatCollection1")
            .document("9")
            .collection("radioChatMessage1")
            .orderBy("time", descending: true)
            .snapshots(),
        builder: (_context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }
          return ListView.builder(
              itemCount: snapshot.data.documents.length,
              reverse: true,
              itemBuilder: (context, index) {
                print(
                    "--- > ${snapshot.data.documents[index].data["message"]}");
                return Container(
                  child: AudioWidget(
                      snapshot.data.documents[index].data["message"], null),
                );
              });
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
      body: Container(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: MyList(),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
