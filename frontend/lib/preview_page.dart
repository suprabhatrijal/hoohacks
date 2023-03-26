import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class PreviewPage extends StatelessWidget {
  const PreviewPage(
      {Key? key,
      required this.picture,
      required this.description,
      required this.name})
      : super(key: key);

  final XFile picture;
  final String name;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preview Page')),
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Image.file(File(picture.path), fit: BoxFit.cover, width: 250),
          const SizedBox(height: 24),
          Text(name,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          const SizedBox(height: 24),
          Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Text(description, textAlign: TextAlign.justify)),
        ]),
      ),
    );
  }
}
