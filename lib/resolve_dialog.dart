import 'package:flutter/material.dart';
import 'dart:io' as IO;
import 'package:image_picker/image_picker.dart';
import 'app_constants.dart';

class ResolveDialog extends StatefulWidget {
  const ResolveDialog({Key? key}) : super(key: key);

  @override
  _ResolveDialogState createState() => _ResolveDialogState();
}

class _ResolveDialogState extends State<ResolveDialog> {

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
  Widget build(BuildContext context) {
    return AlertDialog(
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
    );
  }
}
