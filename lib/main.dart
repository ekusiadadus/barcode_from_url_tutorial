import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:scan/scan.dart';

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

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final qrCodeController = TextEditingController();

  //Image is a temporary memory Image
  Image? image;

  //File is a temporary file
  File? imageFile;

  //Result of the QR code
  String? result;

  @override
  void initState() {
    super.initState();
    qrCodeController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    qrCodeController.dispose();
    super.dispose();
  }

  // onGetImage

  void onGetImage(String url) async {
    final tmpFile = await urlToFile(url);
    final qr = await Scan.parse(tmpFile.path);
    setState(() {
      imageFile = tmpFile;
      image = Image.file(tmpFile);
      result = qr;
    });
  }

  // url to file function
  Future<File> urlToFile(String imageUrl) async {
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    //datetime to make the file name unique
    File file = File('$tempPath${DateTime.now()}.png');
    http.Response response = await http.get(Uri.parse(imageUrl));
    await file.writeAsBytes(response.bodyBytes);

    return file;
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: qrCodeController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'QR Code URL',
                suffixIcon: qrCodeController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          qrCodeController.clear();
                        },
                      )
                    : Container(width: 0),
              ),
            ),
            const SizedBox(height: 20),
            image ?? Container(),
            const SizedBox(height: 20),
            Text(result ?? ''),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          onGetImage(qrCodeController.text);
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
