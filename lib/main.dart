import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'choisir les données à afficher',
      home: MyCustomForm(),
    );
  }
}

// Define a custom Form widget.
class MyCustomForm extends StatefulWidget {
  const MyCustomForm({super.key});

  @override
  State<MyCustomForm> createState() => _MyCustomFormState();
}

// Define a corresponding State class.
// This class holds data related to the Form.
class _MyCustomFormState extends State<MyCustomForm> {
  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  final myController = TextEditingController();
  final myController1 = TextEditingController();
  final myController2 = TextEditingController();
  final myController3 = TextEditingController();

  //value of checkedBox widget true or false
  bool? _checkedValueVideo = false;
  bool? _checkedValuePhotos = false;
  bool? _checkedValueText = false;

  //result of the file Picker
  FilePickerResult? result;
  FilePickerResult? photoResult;
  FilePickerResult? videoResult;

  //enable or disable elevatedButton
  bool videoSubmit = false;
  bool photoSubmit = false;
  bool textSubmit = false;

  String? _videoPath = '';
  String? _photoPath = '';
  String? _textPath = '';

  List _images = [];

  void preview() {
    //preview widget state
    // ....
    print("element Previewed");
  }

  Future sendImage() async {
    var uri = "http://localhost/pubserver/create.php";
    var request = http.MultipartRequest('POST', Uri.parse(uri));
    if (_photoPath != '') {
      var pic = await http.MultipartFile.fromPath("image",
          _photoPath.toString().substring(1, _photoPath.toString().length - 1));
      request.files.add(pic);
      await request.send().then((result) {
        http.Response.fromStream(result).then((response) {
          var message = jsonDecode(response.body);
          print(message);
          print('sendmessage');

          // show snackbar if input data successfully
          final snackBar = SnackBar(content: Text(message['message']));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);

          //get new list images
          getImageServer();
        });
      }).catchError((e) {
        print(e);
      });
    }
  }

  Future getImageServer() async {
    try {
      final response =
          await http.get(Uri.parse("http://localhost/pubserver/list.php"));
      print(response.statusCode);
      if (response.statusCode == 200) {
        print('if response ok .');
        print(response.body);
        final data = jsonDecode(response.body);
        setState(() {
          _images = data;
          _images.forEach((element) {
            print(element);
          });
        });
      }
    } catch (e) {
      print('getError');
      print(e);
    }
  }

  Future sendVideo() async {
    //http POST video
    var uri = "http://localhost/pubserver/videoup.php";
    var request = http.MultipartRequest('POST', Uri.parse(uri));
    if (_videoPath != '') {
      var vid = await http.MultipartFile.fromPath('video',
          _videoPath.toString().substring(1, _videoPath.toString().length - 1));
      request.files.add(vid);
      await request.send().then((result) {
        http.Response.fromStream(result).then((response) {
          print(response.body);
          var message = jsonDecode(response.body);
          print(message);
          print('video');
          // show snackbar if input data successfully
          final snackBar = SnackBar(content: Text(message['message']));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          //get video for preview
          getVideoServer();
        });
      }).catchError((e) {
        print(e);
      });
    }
  }

  Future getVideoServer() async {
    try {
      final response = await http
          .get(Uri.parse("http://localhost/pubserver/Videoslist.php"));
      print(response.statusCode);
      if (response.statusCode == 200) {
        print('if response ok .');
        print(response.body);
        final data = jsonDecode(response.body);
        setState(() {
          _images = data;
          _images.forEach((element) {
            print(element);
          });
        });
      }
    } catch (e) {
      print('getError');
      print(e);
    }
  }

  void commitChanges() async {
    //send data to server
    // ....
    //image
    if (_photoPath != null) {
      await sendImage();
      // receive images data list from server
      await getImageServer();
    }
    //video
    if (_videoPath != null) {
      await sendVideo();
      // receive videos data list from server
      await getVideoServer();
    }

    print(_videoPath);
    print(_photoPath);
    print(_textPath);
    print("Changes Committted");
  }

  @override
  void initState() {
    super.initState();

    // Start listening to changes.
    myController1.addListener(_printFirstValue);
    myController.addListener(_printLSecondValue);
    myController3.addListener(_printThirdtValue);
    myController2.addListener(_printFourthValue);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree.
    // This also removes the _printLatestValue listener.
    myController.dispose();
    myController1.dispose();
    myController2.dispose();
    super.dispose();
  }

  void _printFirstValue() {
    print('First text field: ${myController1.text}');
  }

  void _printLSecondValue() {
    print('Second text field: ${myController.text}');
  }

  void _printThirdtValue() {
    print('Second text field: ${myController3.text}');
  }

  void _printFourthValue() {
    print('Second text field: ${myController2.text}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('choisir les données à afficher'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'tàche numeros'),
              style: const TextStyle(color: Color.fromARGB(199, 39, 39, 102)),
              controller: myController1,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: "taille d'écrans"),
              style: const TextStyle(color: Color.fromARGB(199, 39, 39, 102)),
              controller: myController3,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Background'),
              style: const TextStyle(color: Color.fromARGB(199, 39, 39, 102)),
              controller: myController,
            ),
            Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CheckboxListTile(
                      title: const Text("Video"),
                      value: _checkedValueVideo,
                      onChanged: (bool? video) {
                        setState(() {
                          _checkedValueVideo = video;
                          if (videoSubmit) {
                            videoSubmit = false;
                          } else {
                            videoSubmit = true;
                          }
                        });
                      }),
                  ElevatedButton(
                    onPressed: videoSubmit
                        ? () async {
                            videoResult = await FilePicker.platform
                                .pickFiles(type: FileType.video);
                            if (videoResult == null) {
                              print("no video result");
                            } else {
                              setState(() {
                                _videoPath = videoResult?.paths.toString();
                                videoResult?.files.forEach((element) {
                                  print(element.name);
                                  print(element.size);
                                });
                                //print(_videoPath);
                              });
                            }
                          }
                        : () => {print("video Button locked")},
                    child: const Text("Upload Video"),
                  ),
                  const Text(
                    'Selected Vodeos:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  ListView.builder(
                      shrinkWrap: true,
                      itemCount: videoResult?.files.length ?? 0,
                      itemBuilder: (context, index) {
                        return Text(videoResult?.files[index].name ?? '',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold));
                      }),
                ],
              ),
            ),
            //photo container
            Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CheckboxListTile(
                      title: const Text("Photos"),
                      value: _checkedValuePhotos,
                      onChanged: (bool? photos) {
                        setState(() {
                          _checkedValuePhotos = photos;
                          if (photoSubmit) {
                            photoSubmit = true;
                          } else {
                            photoSubmit = true;
                          }
                        });
                      }),
                  ElevatedButton(
                    onPressed: photoSubmit
                        ? () async {
                            print("photo button enabled");
                            photoResult = await FilePicker.platform
                                .pickFiles(type: FileType.image);
                            if (photoResult == null) {
                              print("no file result");
                            } else {
                              setState(() {
                                _photoPath = photoResult?.paths.toString();
                                photoResult?.files.forEach((element) {
                                  print(element.path);
                                  print("**********");
                                  print(element.bytes);
                                  print("**********");
                                  print(element.extension);
                                  print("**********");
                                  print(element.identifier);
                                  print("**********");
                                  print(element.size);
                                  print("**********");
                                });
                                //print(_photoPath);
                              });
                            }
                          }
                        : () => {print("photos button disabled")},
                    child: const Text("Upload photos"),
                  ),
                  const Text(
                    'Selected Photos:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  ListView.builder(
                      shrinkWrap: true,
                      itemCount: photoResult?.files.length ?? 0,
                      itemBuilder: (context, index) {
                        return Text(photoResult?.files[index].name ?? '',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold));
                      }),
                ],
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CheckboxListTile(
                      title: const Text("Text"),
                      value: _checkedValueText,
                      onChanged: (bool? text) {
                        setState(() {
                          _checkedValueText = text;
                          if (textSubmit) {
                            textSubmit = false;
                          } else {
                            textSubmit = true;
                          }
                        });
                      }),
                  TextField(
                    enabled: textSubmit,
                    decoration:
                        const InputDecoration(labelText: 'Text à Afficher'),
                    style: const TextStyle(
                        color: Color.fromARGB(199, 39, 39, 102)),
                    controller: myController2,
                    maxLength: 500,
                    maxLines: null,
                  )
                ],
              ),
            ),
            Column(children: [
              ElevatedButton(
                  onPressed: (() => setState(() {
                        commitChanges();
                      })),
                  child: const Text("Ajouter Tache")),
              ElevatedButton(
                  onPressed: (() => setState(() {
                        preview();
                      })),
                  child: const Text("Preview"))
            ])
          ],
        ),
      ),
    );
  }
}
