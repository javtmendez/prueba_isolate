import 'dart:async';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

class IsolateArguments{
  final SendPort sendPort;
  final RootIsolateToken rootIsolateToken;

  IsolateArguments(this.sendPort, this.rootIsolateToken);
}


void entryPoint(IsolateArguments arguments)async{
  BackgroundIsolateBinaryMessenger.ensureInitialized( arguments.rootIsolateToken);
Timer.periodic(const Duration(seconds: 1), (_) async {
   Position position = await Geolocator.getCurrentPosition(
       desiredAccuracy: LocationAccuracy.high);
     arguments.sendPort.send(position);
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
  
  Isolate? _isolate;
  final ReceivePort _receivePort=ReceivePort();
  late StreamSubscription _subscription;
  
  void onPressed()async{
    try{
      _isolate?.kill();
      RootIsolateToken rootIsolateToken = RootIsolateToken.instance!;
      _isolate=await Isolate.spawn<IsolateArguments>(entryPoint, IsolateArguments(_receivePort.sendPort, rootIsolateToken));
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
      body:  const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
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
