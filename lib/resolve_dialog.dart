import 'dart:convert';

import 'package:citi_policemen/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:io' as IO;
import 'package:image_picker/image_picker.dart';
import 'app_constants.dart';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:record_mp3/record_mp3.dart';
import 'package:permission_handler/permission_handler.dart';

class ResolveDialog extends StatefulWidget {
  String userId, name, token;

  ResolveDialog({Key? key, required this.userId, required this.name, required this.token}) : super(key: key);

  @override
  _ResolveDialogState createState() => _ResolveDialogState();
}

class _ResolveDialogState extends State<ResolveDialog> {

  String statusText = "";
  bool isComplete = false, showVoiceNote = false, isLoading=false;

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

  Future notifyUser() async {
    String link = "https://fcm.googleapis.com/fcm/send";

    var res = await http.post(Uri.parse(link),
        headers: {
      'Content-Type': 'application/json',
          'accept': 'application/json',
          'Authorization': 'key=AAAABV8o_JU:APA91bHIOVCDBmxCSY_dOFbe59GrsxI2ujxLUFD47lfmPWCsDFMM8_JqcIdPC4uizMYnTgbnlX2iPUDXY8RaczVzKJ3_DXTnVxp0VJwn2Aim-8bmuj0B7t-jyECp3f3K4BaRrdD4jXM1'
        },
        body: jsonEncode({
          "to": widget.token,
          "notification": {
            "title": "Issue Solved",
            "body": "Your issue is being solved by Cops!"
          }
        }));

    if (res.statusCode==200) {
      setState(() {
        isLoading=false;
      });
      Fluttertoast.showToast(msg: "Resolved Issue, Message has sent to ${widget.name}!");

      await FirebaseFirestore.instance
          .collection("Users").doc(widget.userId)
          .update({'lat': "0", 'long': "0"}).then((value) {
        Navigator.pop(context);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home()));
      });
    }
  }

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
  Widget build(BuildContext context) {
    return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Reason:"),
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
              Text("Evidence:"),
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
                            'Cancel',
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
                          notifyUser();
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
