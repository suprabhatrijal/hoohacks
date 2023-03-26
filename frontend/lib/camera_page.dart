import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:frontend/preview_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:image/image.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key, required this.cameras}) : super(key: key);

  final List<CameraDescription>? cameras;

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _cameraController;
  bool _isRearCameraSelected = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initCamera(widget.cameras![0]);
  }

  Future takePicture() async {
    setState(() {
      _isLoading = true;
    });
    if (!_cameraController.value.isInitialized) {
      return null;
    }
    if (_cameraController.value.isTakingPicture) {
      return null;
    }
    try {
      await _cameraController.setFlashMode(FlashMode.off);
      XFile picture = await _cameraController.takePicture();
      // call our api

      String response = await fetchInfo(picture);

      Map<String, dynamic> responseMap = jsonDecode(response);


      String? name = responseMap['name'];
      String? description = responseMap['description'];


      // The name of the food
      // The description
      setState(() {
        _isLoading = false;
      });

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PreviewPage(
                    picture: picture,
                name: name != null ? name: "No name",
                description: description != null ?description: "No description"
                  )));

    } on CameraException catch (e) {
      debugPrint('Error occured while taking picture: $e');
      return null;
    }
  }


  Future initCamera(CameraDescription cameraDescription) async {
    _cameraController =
        CameraController(cameraDescription, ResolutionPreset.high);
    try {
      await _cameraController.initialize().then((_) {
        if (!mounted) return;
        setState(() {});
      });
    } on CameraException catch (e) {
      debugPrint("camera error $e");
    }
  }


  Future<String> fetchInfo(XFile image) async {


    var filepath = image.path;
    var request = http.MultipartRequest('POST', Uri.parse('https://hoohacks-backend.herokuapp.com/'));

    request.files.add(http.MultipartFile('image',
        File(filepath).readAsBytes().asStream(), File(filepath).lengthSync(),
        filename: filepath.split("/").last));
    var res = await request.send();
    final respStr = await res.stream.bytesToString();
    return respStr;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Stack(children: [
        (_cameraController.value.isInitialized)
        && (_isLoading != true)
            ? CameraPreview(_cameraController)
            : Container(
                color: Colors.black,
                child: const Center(child: CircularProgressIndicator())),
        Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.20,
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  color: Colors.black),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Expanded(
                    child: IconButton(
                  padding: EdgeInsets.zero,
                  iconSize: 30,
                  icon: Icon(
                      _isRearCameraSelected
                          ? CupertinoIcons.switch_camera
                          : CupertinoIcons.switch_camera_solid,
                      color: Colors.white),
                  onPressed: () {
                    setState(
                        () => _isRearCameraSelected = !_isRearCameraSelected);
                    initCamera(widget.cameras![_isRearCameraSelected ? 0 : 1]);
                  },
                )),
                Expanded(
                    child: IconButton(
                  onPressed: takePicture,
                  iconSize: 50,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.circle, color: Colors.white),
                )),
                const Spacer(),
              ]),
            )),
      ]),
    ));
  }
}
