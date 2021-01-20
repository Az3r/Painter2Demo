import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'drawing_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _picker = ImagePicker();
  Uint8List _imageData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('☕ Home ☕'),
        actions: [
          IconButton(
            icon: Icon(Icons.add_a_photo),
            onPressed: _displayPhoto,
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.brush),
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => DrawingPage()));
        },
      ),
      body: Container(
        constraints: BoxConstraints.expand(),
        child: _imageData == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image,
                    size: 128,
                    color: Colors.black45,
                  ),
                  Text('No image is selected',
                      style: TextStyle(fontSize: 24, color: Colors.black45))
                ],
              )
            : Image.memory(
                _imageData,
                fit: BoxFit.cover,
              ),
      ),
    );
  }

  void _displayPhoto() async {
    final file = await _picker.getImage(source: ImageSource.gallery);
    final data = await file.readAsBytes();
    setState(() => _imageData = data);
  }
}
