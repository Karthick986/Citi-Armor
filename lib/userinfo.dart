import 'dart:async';
import 'package:citi_policemen/audio_record.dart';
import 'package:citi_policemen/resolve_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'app_constants.dart';
import 'dart:io' as IO;
import 'package:image_picker/image_picker.dart';

// ignore: must_be_immutable
class UserInfo extends StatefulWidget {
  String lat, long;
  String userId;

  UserInfo(
      {Key? key, required this.userId, required this.lat, required this.long})
      : super(key: key);

  @override
  _UserInfoState createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {

  IO.File? _imageFile;
  late String byteImage;
  bool isLoading = false;
  final picker = ImagePicker();

  Future pickImage() async {
        final pickedFile = await picker.getImage(source: ImageSource.camera);
        setState(() {
          _imageFile = IO.File(pickedFile!.path);
        });
  }

  Future<void> _showResolve(context) async {
    return showDialog(context: context, builder: (BuildContext context) =>
      const ResolveDialog()
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _createUserInfo();
  }

  Widget _createUserInfo() {
    return Padding(
      padding: EdgeInsets.all(12.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(margin: EdgeInsets.all(8.0), child:
                  Text("Time: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0))),
                  SizedBox(height: 16.0,),
                  Container(margin: EdgeInsets.all(8.0), child:
                  Text("Name: ",  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0))),
                  SizedBox(height: 16.0,),
                  Container(margin: EdgeInsets.all(8.0), child:
                  Text("Mobile No: ",  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)))
                ]
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(child: FlutterLogo(size: 96,), margin: EdgeInsets.all(8.0),),
              SizedBox(height: 16.0,),
              Container(
                margin: EdgeInsets.all(4.0),
                child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) => PRIMARY_COLOR,
                      ),
                      shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          )
                      ),
                    ),
                    onPressed: () {
                      // _showResolve(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) =>
                          RecorderExample()));
                    },
                    child: Text(
                      'Resolve',
                      style: TextStyle(
                          color: Colors.white),
                      textAlign: TextAlign.center,
                    )
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}