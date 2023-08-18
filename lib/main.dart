import 'package:flutter/material.dart';
import 'package:sentry/sentry.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
  await Sentry.init((options) {
    options.dsn =
        'https://51359dfdf2734d0e9c00f00ad56654a7@o1407376.ingest.sentry.io/4505591369105408';
    // Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
    // We recommend adjusting this value in production.
    options.tracesSampleRate = 1.0;
    options.debug = true;
  });
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
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  void _trycatch() async {
    try {
      throw FormatException('Expected at least 1 section');
    } catch (exception, stackTrace) {
      await Sentry.captureException(exception, stackTrace: stackTrace);
    }
  }

  void _createTransaction() async {
    final transaction = Sentry.startTransaction(
      'webrequest',
      'request',
      bindToScope: true,
    );
    var client = SentryHttpClient();
    try {
      var uriResponse =
          await client.get(Uri.parse("http://127.0.0.1:8000/api/food"));
    } catch (exception) {
      transaction.throwable = exception;
      transaction.status = SpanStatus.internalError();
    } finally {
      client.close();
    }
    await transaction.finish();
  }

  Future<http.Response> fetchFood() async {
    final response =
        await http.get(Uri.parse('http://127.0.0.1:8000/api/food'));
    print(response);
    return response;
  }

  void _incrementCounter() async {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const Text("hello!"),
            ElevatedButton(
              onPressed: () {
                print('button pressed!');
                _createTransaction();
              },
              child: const Text('Create Transaction'),
            ),
            ElevatedButton(
              onPressed: () {
                print('button pressed!');
                fetchFood();
              },
              child: Text('Fetch'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _trycatch,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),

      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
