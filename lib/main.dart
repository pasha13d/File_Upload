import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:file_upload/api/firebase_api.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:open_file/open_file.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

File? file;
class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  UploadTask? task;
  @override
  Widget build(BuildContext context){
    final fileName = file != null ? basename(file!.path) : 'No File Selected';
    print('PAth before file pick $file!.path');
    final _fileNameController = TextEditingController();
    String path;
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('File Picker'),
        ),
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton.icon(
                  icon: const Icon(Icons.attach_file_rounded),
                  onPressed: () async {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['doc', 'docx']
                    );
                    if(result != null) {
                      path = result.files.single.path!;
                      await OpenFile.open(path);
                      // var s = json.encode(newResult);
                      // log(s);

                      // FileMode.append;
                      // await file!.writeAsString(path);
                      print('Picked file path $path');
                      setState(() {
                        // file = File(path);
                        file = File(path);
                      });
                    }
                  },
                  label: const Text('Choose File'),
                  style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                    primary: Colors.teal,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  // _fileNameController.text = fileName,
                  fileName,
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8.0),
                ElevatedButton.icon(
                  icon: const Icon(Icons.cloud_upload_outlined),
                  onPressed: uploadFile,
                  label: const Text('Upload File'),
                  style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                    primary: Colors.teal,
                  ),
                ),
                const SizedBox(height: 20.0),

                task != null ? buildUploadStatus(task!) : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }
// }

  Future uploadFile() async{
    if(file == null) return;
    final fileName = basename(file!.path);
    // final fileName = 'Download/sample2.docx';
    print('Upload file path $file');
    print('Base path $fileName');
    final destination = 'files/$fileName';
    // FirebaseApi.uploadFile(destination, file!);
    var task = FirebaseApi.uploadFile(destination, file!);
    setState(() {});
    if(task == null) return;
    final snapshot = await task.whenComplete(() {});
    final downloadUrl = await snapshot.ref.getDownloadURL();
    print('Download Url $downloadUrl');
  }

  Widget buildUploadStatus(UploadTask task) => StreamBuilder<TaskSnapshot>(
    stream: task.snapshotEvents,
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        final snap = snapshot.data!;
        final progress = snap.bytesTransferred / snap.totalBytes;
        final percentage = (progress * 100).toStringAsFixed(2);

        print(task);
        return Text(
          '$percentage %',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        );
      } else {
        return Container();
      }
    },
  );
}