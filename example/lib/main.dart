import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:keep_alive_listener/keep_alive_listener.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        children: const [
          SimplePage(color: Colors.blue, text: 'standard page'),
          KeepAlivePage(),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class SimplePage extends StatelessWidget {
  final Color color;
  final String text;

  const SimplePage({
    super.key,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      alignment: Alignment.center,
      child: Text(text),
    );
  }
}

class KeepAlivePage extends StatefulWidget {
  const KeepAlivePage({super.key});

  @override
  State<KeepAlivePage> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return KeepAliveListener(
        keepAliveListener: (bool isKeptAlive) {
          Fluttertoast.showToast(
              msg: 'keep alive page, kept alive = $isKeptAlive');
        },
        child: const SimplePage(color: Colors.red, text: 'keep alive page'));
  }

  @override
  bool get wantKeepAlive => true;
}
