import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'app_constants.dart';
import 'dart:io' as IO;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';

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
      AlertDialog(
        title: Text("Resolve"),
        content: Column(
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Evidence:"),
                ClipRRect(
                  child: (_imageFile != null)
                      ? Image.file(_imageFile!, width: 100, height: 100,)
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
                        pickImage();
                        setState(() {});
                      },
                      child: Text(
                        'Click here to pick',
                        style:
                        TextStyle(fontSize: 13, color: textColor),
                        textAlign: TextAlign.center,
                      )),
                ),
              ],
            ),
          ],
        ),
        actions: [
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
                  child: ElevatedButton(
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
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
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
      )
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
                  Container(margin: EdgeInsets.all(6.0), child:
                  Text("Time: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0))),
                  Container(margin: EdgeInsets.all(6.0), child:
                  Text("Name: ",  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0))),
                  Container(margin: EdgeInsets.all(6.0), child:
                  Text("Mobile No: ",  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)))
                ]
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                child: FlutterLogo(size: 150,),
              ),
              SizedBox(height: 16.0,),
              ElevatedButton(
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
                    _showResolve(context);
                  },
                  child: Text(
                    'Resolve',
                    style: TextStyle(
                        color: Colors.white),
                    textAlign: TextAlign.center,
                  )
              )
            ],
          )
        ],
      ),
    );
  }
}