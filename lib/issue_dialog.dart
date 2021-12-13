import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io' as IO;
import 'package:image_picker/image_picker.dart';
import 'app_constants.dart';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:record_mp3/record_mp3.dart';
import 'package:permission_handler/permission_handler.dart';

import 'home.dart';
import 'package:http/http.dart' as http;

class IssueDialog extends StatefulWidget {

  IssueDialog({Key? key}) : super(key: key);

  @override
  _IssueDialogState createState() => _IssueDialogState();
}

class _IssueDialogState extends State<IssueDialog> {

  String statusText = "", lat="0", long="0";
  bool isComplete = false, showVoiceNote = false, isLoading=true;

  _callNumber(String number) async {
    await FlutterPhoneDirectCaller.callNumber(number);
  }

  String token="";
  static List<Map<String, dynamic>> list = [];
  static List<String> shortlist = [];

  double calculateDistance(lat1, lon1, lat2, lon2){
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p)/2 +
        c(lat1 * p) * c(lat2 * p) *
            (1 - c((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a));
  }

  Future getData() async {
    var document = FirebaseFirestore.instance.collection("Users").doc(FirebaseAuth.instance.currentUser!.uid);
    document.get().then((value) {
      setState(() {
        lat = value["lat"];
        long = value["long"];
      });
    });
  }

  Future getCloudFirestoreCops() async {
    await Firebase.initializeApp();
    FirebaseFirestore.instance.collection("Cops").get().then((querySnapshot) {
      setState(() {
        for (var value in querySnapshot.docs) {
          if (value["lat"]!="0" && value["long"]!="0") {
            // double distance = calculateDistance(lat, long, double.parse((value["lat"].toString())), double.parse((value["long"].toString())));
            list.add({
              "token": value["token"],
              "lat": value["lat"],
              "long": value["long"],
            });
          }
        }
      });
    }).catchError((onError) {
      print(onError);
    });
    setState(() {
      isLoading = false;
    });
  }

  Future notifyUser() async {
    String link = "https://fcm.googleapis.com/fcm/send";

    if (list.isNotEmpty) {
      var res = await http.post(Uri.parse(link),
          headers: {
            'Content-Type': 'application/json',
            'accept': 'application/json',
            'Authorization': 'key=AAAABV8o_JU:APA91bHIOVCDBmxCSY_dOFbe59GrsxI2ujxLUFD47lfmPWCsDFMM8_JqcIdPC4uizMYnTgbnlX2iPUDXY8RaczVzKJ3_DXTnVxp0VJwn2Aim-8bmuj0B7t-jyECp3f3K4BaRrdD4jXM1'
          },
          body: jsonEncode({
            "to": list[0]["token"],
            "notification": {
              "title": "Raised Issue",
              "body": "Your issue is undertaken by Cops!"
            }
          }));

      if (res.statusCode == 200) {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(msg: "Raised Issue, Message has sent to a Cop!");
        Navigator.pop(context);
      }
    } else {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: "Raised Issue, Message is on hold to receive nearby Cops!");
      Navigator.pop(context);
    }
  }

  Future<bool> checkPermission() async {
    if (!await Permission.microphone.isGranted) {
      PermissionStatus status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }

  void startRecord() async {
    bool hasPermission = await checkPermission();
    if (hasPermission) {
      statusText = "Recording...";
      recordFilePath = await getFilePath();
      isComplete = false;
      RecordMp3.instance.start(recordFilePath!, (type) {
        statusText = "Record error--->$type";
        setState(() {});
      });
    } else {
      statusText = "No microphone permission";
    }
    setState(() {});
  }

  void pauseRecord() {
    if (RecordMp3.instance.status == RecordStatus.PAUSE) {
      bool s = RecordMp3.instance.resume();
      if (s) {
        statusText = "Recording...";
        setState(() {});
      }
    } else {
      bool s = RecordMp3.instance.pause();
      if (s) {
        statusText = "Recording pause...";
        setState(() {});
      }
    }
  }

  void stopRecord() {
    bool s = RecordMp3.instance.stop();
    if (s) {
      statusText = "Record complete";
      isComplete = true;
      setState(() {});
    }
  }

  void resumeRecord() {
    bool s = RecordMp3.instance.resume();
    if (s) {
      statusText = "Recording...";
      setState(() {});
    }
  }

  String? recordFilePath;

  void play() {
    if (recordFilePath != null && File(recordFilePath!).existsSync()) {
      AudioPlayer audioPlayer = AudioPlayer();
      audioPlayer.play(recordFilePath!, isLocal: true);
    }
  }

  int i = 0;

  Future<String> getFilePath() async {
    Directory storageDirectory = await getApplicationDocumentsDirectory();
    String sdPath = storageDirectory.path + "/record";
    var d = Directory(sdPath);
    if (!d.existsSync()) {
      d.createSync(recursive: true);
    }
    return sdPath + "/test_${i++}.mp3";
  }

  IO.File? _imageFile1;
  IO.File? _imageFile2;
  final picker = ImagePicker();

  Future pick1Image() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    setState(() {
      _imageFile1 = IO.File(pickedFile!.path);
    });
  }

  Future pick2Image() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    setState(() {
      _imageFile2 = IO.File(pickedFile!.path);
    });
  }

  @override
  void initState() {
    super.initState();
    // getData();
    getCloudFirestoreCops();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("Issue:"),
        Container(
          margin: EdgeInsets.only(top: 8.0),
          child: TextFormField(
            maxLines: 3,
            style: TextStyle(
                fontSize: 13.0),
            onChanged: (value) {},
            decoration: InputDecoration(
                hintText: "Type here",
                hintStyle: TextStyle(
                    fontSize: 13.0),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                        Radius.circular(4.0)))),
          ),
        ),
        SizedBox(height: 16.0,),
        Text("Issue images:"),
        SizedBox(height: 8.0,),
        Row(
          mainAxisAlignment: (_imageFile1 != null) ? MainAxisAlignment.spaceAround : MainAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
              child: (_imageFile1 != null)
                  ? Image.file(_imageFile1!, width: 100, height: 100,)
                  : ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                    MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) => Colors.white24,
                    ),
                    shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.0),
                        )),
                  ),
                  onPressed: () {
                    pick1Image();
                  },
                  child: Text(
                    'Click to Add Image',
                    style:
                    TextStyle(fontSize: 13, color: textColor),
                    textAlign: TextAlign.center,
                  )),
            ),
            (_imageFile1 != null) ? ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
              child: (_imageFile2 != null)
                  ? Image.file(_imageFile2!, width: 100, height: 100,)
                  : ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                    MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) => Colors.white24,
                    ),
                    shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.0),
                        )),
                  ),
                  onPressed: () {
                    pick2Image();
                  },
                  child: Text(
                    'Add Image',
                    style:
                    TextStyle(fontSize: 13, color: textColor),
                    textAlign: TextAlign.center,
                  )),
            ) : SizedBox(),
          ],
        ),
        Container(child: Text("Voice note: "), margin: EdgeInsets.only(top: 12.0),),
        showVoiceNote ? Container(
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black54, width: 1),
              borderRadius: BorderRadius.all(Radius.circular(4.0))
          ),
          margin: EdgeInsets.only(top: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              RecordMp3.instance.status == RecordStatus.PAUSE ?
              InkWell(child: Icon(Icons.play_arrow_rounded, size: 36,),
                onTap: () async {
                  resumeRecord();
                },) : InkWell(child: Icon(Icons.pause, size: 36,),
                onTap: () {
                  pauseRecord();
                },),
              SizedBox(width: 4.0,),
              Text("|"),
              SizedBox(width: 4.0,),
              InkWell(child: Icon(Icons.stop, size: 36,),
                onTap: () {
                  setState(() {
                    showVoiceNote = false;
                  });
                  stopRecord();
                },),
            ],
          ),
        ) : ElevatedButton(
            style: ButtonStyle(
              backgroundColor:
              MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) => Colors.white24,
              ),
              shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.0),
                  )),
            ),
            onPressed: () {
              setState(() {
                showVoiceNote = true;
              });
              startRecord();
            },
            child: Text(
              'Record',
              style:
              TextStyle(fontSize: 13, color: textColor),
              textAlign: TextAlign.center,
            )),
        Container(child: Text(statusText, style: TextStyle(fontSize: 13.0),), margin: EdgeInsets.only(top: 4.0, bottom: 4.0),),
        Row(
          children: [
            Expanded(
                child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) => Colors.white,
                      ),
                      shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0),
                          )
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        'Skip',
                        style: TextStyle(
                            color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                    )
                )
            ),
            SizedBox(
              width: 16,
            ),
            Expanded(
                child: isLoading ? Center(child: CircularProgressIndicator(color: PRIMARY_COLOR,),) : ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) => PRIMARY_COLOR,
                      ),
                      shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0),
                          )
                      ),
                    ),
                    onPressed: () {
                        setState(() {
                          isLoading=true;
                        });
                        notifyUser().then((value) {
                          Fluttertoast.showToast(msg: "Calling central number");
                          _callNumber("+917588807491");
                        });
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        'Submit',
                        style: TextStyle(
                            color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    )
                )
            ),
          ],
        ),
      ],
    );
  }
}