import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

void main() => runApp(const NumKeyboardApp());

class NumKeyboardApp extends StatelessWidget {
  const NumKeyboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/': (context) => const NumKeyboardScreen(),
      },
    );
  }
}

class NumKeyboardScreen extends StatelessWidget {
  const NumKeyboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: NumKeyboardDisplay(),
    );
  }
}

class NumKeyboardDisplay extends StatefulWidget {
  const NumKeyboardDisplay({super.key});

  @override
  State<NumKeyboardDisplay> createState() => _NumKeyboardDisplayState();
}

class _NumKeyboardDisplayState extends State<NumKeyboardDisplay> {
  List<List<String>> keys = [
    ['F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'F7', 'F8', 'F9', 'F10', 'F11', 'F12'],
    [
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '0',
      '-',
      '=',
      '+',
      '<-',
      '<--'
    ],
    [
      'ESC',
      'Q',
      'W',
      'E',
      'R',
      'T',
      'Y',
      'U',
      'I',
      'O',
      'P',
      '[',
      ']',
      'TAB',
      'ALL CAPS'
    ],
    ['CTRL', 'A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', ';', "'", '~', 'RET'],
    ['SHIFT', '\\', 'Z', 'X', 'C', 'V', 'B', 'N', 'M', ',', '.', '/', 'SPACE'],
    ['SWIRL', 'HELP'],
    ['INS', 'DEL', ''],
    ['HOME', 'UP', 'PgUp'],
    ['LEFT', 'VALID', 'RIGHT'],
    ['END', 'DOWN', 'PgDn'],
    ['MODE', 'TOOL', 'JOG'],
    ['BLOCK SKIP', 'M01'],
    ['CONTEXT 1', 'CONTEXT 2', 'CONTEXT 4'],
    ['         ', 'CONTEXT 3', 'RESET']
  ];
  String message = '';

  @override
  void initState() {
    super.initState();
  }

  _sendKey(String input) async {
    var httpClient = http.Client();

    message = "input " + input + "\n";

    var response =
        await httpClient.post(Uri.parse('key'), body: {'key': input});
    print(response);
    setState(() {
      message = message + response.body;
    });
  }

  final FocusNode _focusNode = FocusNode();
  final FocusScopeNode fnode = FocusScopeNode();

  @override
  Widget build(BuildContext context) {
    return FocusScope(
        node: fnode,
        child: KeyboardListener(
            focusNode: _focusNode,
            autofocus: true,
            onKeyEvent: (event) {
              if (event is KeyDownEvent) {
                // event.physicalKey.usbHidUsage
                // event.character (printable char)
                // https://api.flutter.dev/flutter/services/PhysicalKeyboardKey/usbHidUsage.html
                _sendKey(event.logicalKey.keyLabel);
                //return KeyEventResult.handled;
              }
            },
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ...keys.map((line) => Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            ...line
                                .map((key) => ElevatedButton(
                                    onPressed: () => _sendKey(key),
                                    child: Text(key)))
                                .toList()
                          ])),
                  Text(message),
                ])));
  }
}
