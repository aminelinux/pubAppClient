import 'dart:convert';
//import 'dart:html';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp());

class Diaporama {
  String name;
  String date;

  List<Taches>? tache;

  Diaporama(this.name, this.date, [this.tache]);

  Map toJson() {
    List<Map>? tache =
        this.tache != null ? this.tache!.map((i) => i.toJson()).toList() : null;
    return {
      'name': name,
      'date': name,
      'tache': tache,
    };
  }

  @override
  String toString() {
    return '{ ${this.name}, ${this.date}, ${this.tache} }';
  }
}

class Taches {
  String kindOf;
  String link;
  int periode;

  Taches(this.kindOf, this.link, this.periode);

  Map toJson() => {
        'kindOf': kindOf,
        'link': link,
        'periode': periode,
      };
}

class VideosJson {
  int id_video = 0;
  String video = "";
  String date = "";

  VideosJson(this.id_video, this.video, this.date);

  factory VideosJson.fromJson(dynamic json) {
    return VideosJson(json('id_video') as int, json('video') as String,
        json('date') as String);
  }
}

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

  bool _show = false;
  String _previewPhoto =
      "http://localhost/pubserver/images/bison-3840x2160-grand-teton-national-park-wyoming-usa-bing-microsoft-23142.jpg";

  // path to save
  String? _videoPath = '';
  String? _photoPath = '';
  String? _textPath = '';

  late Socket socket;

  Diaporama? diapo;

  //list of diapo widget
  final List<Widget> _diapoList = [];

  void _addDiapoWidget() {
    setState(() {
      getImageServer();
      _diapoList.add(_diaWidget());
    });
  }

  Widget _diaWidget() {
    String _value = imgUrl.first;
    print("the first value is ");
    print(_value);
    return Container(
      height: 80,
      margin: const EdgeInsets.only(top: 5, left: 8, right: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.orangeAccent[100],
      ),
      child: Row(
        children: [
          DropdownButton(
            value: _value,
            selectedItemBuilder: (BuildContext context) {
              return imgUrl.map<Widget>((item) {
                return Text('item $item');
              }).toList();
            },
            items: imgUrl.map((item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text('Log $item'),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                print("the value is");
                print(value);
                _value = value!;
              });
            },
            //value: _value,
            hint: const Text("select image"),
            disabledHint: const Text('Disabled'),
          )
        ],
      ),
    );
  }

  void sendDiaapo() {
    List<Taches> tachetest = [
      Taches(
          'photo',
          "http://localhost/pubserver/images/bison-3840x2160-grand-teton-national-park-wyoming-usa-bing-microsoft-23142.jpg",
          4),
      Taches(
          'photo',
          "https://www.tunisienumerique.com/wp-content/uploads/2019/08/Tunisie-Telecom.png",
          10),
      Taches('video', "http://localhost/pubserver/videos/ERA%20-%20Ameno.mp4",
          230),
    ];
    String jsonTache = jsonEncode(tachetest);
    print(jsonTache);

    diapo = Diaporama('firstTest', '20/20/2022', tachetest);
    String jsonDiapo = jsonEncode(diapo);
    print(jsonDiapo);
  }

  List _images = [];
  List<String> imgUrl = [];
  List _videos = [];
  List<String> VidUrl = [];
  List _txts = [];
  List<String> txtUrl = [];

  void preview() {
    //preview widget state
    // ....
    setState(() {
      if (_show == false) {
        _show = true;
      } else {
        _show = false;
      }
    });
    print("element Previewed");
  }

  //send and save images to server MySQL
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
          //getImageServer();
        });
      }).catchError((e) {
        print(e);
      });
    }
  }

  //get List of images names from server
  Future getImageServer() async {
    try {
      final response =
          await http.get(Uri.parse("http://localhost/pubserver/list.php"));
      print(response.statusCode);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _images = data;
        setState(() {
          imgUrl.clear();
          _images.forEach((element) {
            imgUrl.add(element['image']);
          });
        });
      }
    } catch (e) {
      print('getError');
      print(e);
    }
  }

  //send and save videos to server MySQL
  // problem with "Content-Length of 122163458 bytes exceeds the limit of 41943040 bytes"
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
          //getVideoServer();
        });
      }).catchError((e) {
        print(e);
      });
    }
  }

  //get List of videos names from server
  Future getVideoServer() async {
    try {
      final response = await http
          .get(Uri.parse("http://localhost/pubserver/Videoslist.php"));
      print(response.statusCode);
      if (response.statusCode == 200) {
        print('if response ok .');
        print(response.body);
        final data = jsonDecode(response.body);
        _videos = data;
        setState(() {
          VidUrl.clear();
          _videos.forEach((element) {
            VidUrl.add(element['video']);
          });
        });
      }
    } catch (e) {
      print('getError');
      print(e);
    }
  }

  //send and save Text to server MySQL
  Future sendText() async {
    //http POST video
    var uri = "http://localhost/pubserver/textup.php";
    if (_textPath != '') {
      var requestt = await http.post(Uri.parse(uri), body: _textPath);
      var message = await requestt.body;
      print(message);
      print('text');
      // show snackbar if input data successfully
      // final snackBar = SnackBar(content: Text(message['message']));
      // ScaffoldMessenger.of(context).showSnackBar(snackBar);
      //get Text for preview
      //getText();
    }
  }

  //get List of Text names from server
  Future getText() async {
    try {
      final response =
          await http.get(Uri.parse("http://localhost/pubserver/textLists.php"));
      print(response.statusCode);
      if (response.statusCode == 200) {
        print('if response ok .');
        print(response.body);
        final data = jsonDecode(response.body);
        _txts = data;
        setState(() {
          _txts.forEach((element) {
            txtUrl.add(element['contenu']);
          });
        });
      }
    } catch (e) {
      print('getError');
      print(e);
    }
  }

  // commit videos,Images,Text choices to send to server
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

    //Text
    if (_textPath != null) {
      await sendText();

      await getText();
    }
    //print(socket.length);
    socket.add(utf8.encode('Update'));
    print(_videoPath);
    print(_photoPath);
    print(_textPath);
    print("Changes Committted");
  }

  //send signals to lcd to update their state and take the new pub
  void newChanges() async {
    Socket.connect("localhost", 9000).then((Socket sock) {
      socket = sock;
      socket.listen(dataHandler,
          onError: errorHandler, onDone: doneHandler, cancelOnError: false);
      socket.add(utf8.encode(
          'hello there this is the admin ${socket.address}:${socket.port}'));
      socket.add(utf8.encode('Update'));
    }).catchError((Object e) {
      print("Unable to connect: $e");
      exit(1);
    });

    //Connect standard in to the socket
    stdin.listen(
        (data) => socket.write('${String.fromCharCodes(data).trim()}\n'));
  }

  // Socket.connect("127.0.0.1", 9000).then((Socket sock) {
  //   socket = sock;
  //   print(socket);
  //   print("socket paired");
  //   socket.listen(
  //     dataHandler,
  //     onError: errorHandler,
  //     cancelOnError: false,
  //   );
  //   socket.add(utf8.encode('hello'));
  // }).catchError((Object e) {
  //   print("Unable to connect : $e");
  // });
  //socket.add(utf8.encode('hello'));

  // stdin.listen(
  //     (data) => socket.write(new String.fromCharCodes(data).trim() + '\n'));

  void dataHandler(data) {
    print(String.fromCharCodes(data).trim());
  }

  void errorHandler(error, StackTrace trace) {
    print(error);
  }

  void doneHandler() {
    //socket.destroy();
    //exit(0);
  }

  @override
  void initState() {
    sendDiaapo();
    getImageServer();
    super.initState();
    newChanges();
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
      body: Container(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextFormField(
                    decoration:
                        const InputDecoration(labelText: 'tàche numeros'),
                    style: const TextStyle(
                        color: Color.fromARGB(199, 39, 39, 102)),
                    controller: myController1,
                  ),
                  TextFormField(
                    decoration:
                        const InputDecoration(labelText: "taille d'écrans"),
                    style: const TextStyle(
                        color: Color.fromARGB(199, 39, 39, 102)),
                    controller: myController3,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Background'),
                    style: const TextStyle(
                        color: Color.fromARGB(199, 39, 39, 102)),
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
                                      _videoPath =
                                          videoResult?.paths.toString();
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
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        ListView.builder(
                            shrinkWrap: true,
                            itemCount: videoResult?.files.length ?? 0,
                            itemBuilder: (context, index) {
                              return Text(videoResult?.files[index].name ?? '',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold));
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
                                      _photoPath =
                                          photoResult?.paths.toString();
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
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        ListView.builder(
                            shrinkWrap: true,
                            itemCount: photoResult?.files.length ?? 0,
                            itemBuilder: (context, index) {
                              return Text(photoResult?.files[index].name ?? '',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold));
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
                          decoration: const InputDecoration(
                              labelText: 'Text à Afficher'),
                          style: const TextStyle(
                              color: Color.fromARGB(199, 39, 39, 102)),
                          controller: myController2,
                          maxLength: 500,
                          maxLines: null,
                        )
                      ],
                    ),
                  ),
                  Row(children: <Widget>[
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
                  ]),
                  Visibility(
                    visible: _show,
                    // replacement: Image.network(
                    //     "http://localhost/pubserver/images/bison-3840x2160-grand-teton-national-park-wyoming-usa-bing-microsoft-23142.jpg"),
                    child: Column(children: [
                      Image.network(_previewPhoto),
                    ]),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text("Diaporama",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  FloatingActionButton(
                    onPressed: _addDiapoWidget,
                    tooltip: 'Add',
                    child: const Icon(Icons.add),
                  ),
                  Column(
                    children: [
                      ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: _diapoList.length,
                          itemBuilder: ((context, index) {
                            return _diapoList[index];
                          }))
                    ],
                  ),
                  // MyDiaporama(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
