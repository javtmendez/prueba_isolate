import 'dart:async';
import 'dart:isolate';

import 'package:flutter/material.dart';

void entryPoint(SendPort sendPort)async{
Timer.periodic(const Duration(seconds: 1), (_){
    sendPort.send(DateTime.now().toString());
});
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
       
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  
  String? _resp;
  Isolate? _isolate;
  final ReceivePort _receivePort=ReceivePort();
  late StreamSubscription _subscription;
  void onPressed()async{
    try{
      _isolate?.kill();
      _isolate=await Isolate.spawn<SendPort>(entryPoint, _receivePort.sendPort);
    }on IsolateSpawnException catch(e)
    {
      // ignore: avoid_print
      print("$e");
    }
  }
  @override
  void initState() {
    super.initState();
   _subscription= _receivePort.listen((message) { 
    // ignore: avoid_print
    print("Mensaje:$message");
   });
  }
  @override
  void dispose() {
    _subscription.cancel();
_isolate?.kill();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body:  Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text('$_resp')
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: onPressed,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), 
    );
  }
}
