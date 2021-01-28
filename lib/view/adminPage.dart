import 'dart:convert';
import 'dart:io';

import 'package:admin/api/Api.dart';
import 'package:admin/models/userModel.dart';
import 'package:admin/style/style.dart';
import 'package:admin/view/persons.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:toast/toast.dart';
import 'package:path/path.dart' as path;
import 'package:async/async.dart';

List<int> a = [];
UserModel _user;
var bytesImage;
File image;
final String apiUrl = baseUrl + 'user/create/';
final api = Api();

Future<UserModel> createUser(
    String username,
    String position,
    String password,
    String firstname,
    String lastname,
    // String company,
    File image,
    context) async {
  Map<String, String> body = {
    'username': username,
    'password': password,
    'first_name': firstname,
    'last_name': lastname,
    "position": position,
    // 'company': company,
    // 'file': image
  };

  print('image $image');
  try {
    http.MultipartRequest request = await upload(image, context);
    api.showAlertDialog(context);
    request.fields.addAll(body);
    request.headers.addAll(headers);
    print('request $request');
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    print('response body ${json.decode(response.body)}');
    // var image = json.decode(response.body);
    // final response =
    //     await http.post(apiUrl, headers: headers, body: json.encode(body));

    if (response.statusCode == 201) {
      final String responseString = response.body;
      Toast.show('Пользователь успешно создан', context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
      Navigator.pop(dialogContext);
      // homePage.refreshPage();
      return userModelFromJson(responseString);
    } else {
      Toast.show('Допустимые символы для логина и пароля только <a-z> и <1-9>',
          context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
      Navigator.pop(dialogContext);
      return null;
    }
  } on SocketException catch (e) {
    Toast.show('Что-то пошло не так, проверьте интернет подключение', context,
        gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
    Navigator.pop(dialogContext);
    print('General Error: $e');
  } on Error catch (e) {
    Toast.show('General Error', context,
        gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
    Navigator.pop(dialogContext);
  }
}

upload(File imageFile, context) async {
  // open a bytestream
  print('1');
  var stream =
      new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
  // get file length
  print('2');
  var length = await imageFile.length();
  print('3');
  // string to uri
  var uri = Uri.parse(apiUrl);
  print('4');
  // create multipart request
  var request = new http.MultipartRequest("POST", uri);
  print('5');
  // multipart that takes file
  var multipartFile = new http.MultipartFile('file', stream, length,
      filename: path.basename(imageFile.path));
  print('6');
  // add file to multipart
  request.files.add(multipartFile);
  print('7');
  // send
  // var streamedResponse = await request.send();
  // var response = await http.Response.fromStream(streamedResponse);
  // var image = json.decode(response.body);
  // print('fsd ${image}');
  return request;
}

class AdminPage extends StatefulWidget {
  AdminPage({Key key}) : super(key: key);

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  // this allows us to access the TextField text
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController lastnameController = TextEditingController();
  TextEditingController positionController = TextEditingController();
  TextEditingController companyController = TextEditingController();
  final style = Style();

  @override
  Widget build(BuildContext context) {
    getImage() async {
      var picker = ImagePicker();
      var pickedImage = await picker.getImage(source: ImageSource.camera);
      if (pickedImage != null) {
        image = File(pickedImage.path);
        print('image path $image');
        bytesImage = await image.readAsBytes();
        print('image as bytes $bytesImage');
        setState(() {});
      }
    }

    final _height = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        kToolbarHeight;
    final _width = MediaQuery.of(context).size.width;
    Widget checkImage() {
      if (bytesImage != null) {
        return Container(
          margin: EdgeInsets.only(top: _height * 0.03),
          // height: _height * ,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(height: _height * 0.4, child: Image.memory(bytesImage)),
              IconButton(
                  iconSize: _height * 0.1,
                  icon: Icon(Icons.cancel),
                  onPressed: () {
                    bytesImage = null;
                    setState(() {});
                  })
            ],
          ),
        );
      } else {
        return Container(
          margin: EdgeInsets.only(top: _height * 0.03),
          height: _height * 0.3,
          width: _width * 0.5,
          child:
              RaisedButton(child: Text('Добавить фото'), onPressed: getImage),
        );
      }
    }

    return WillPopScope(
      onWillPop: () {
        print('pop');
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => MyHomePage()));
      },
      child: Scaffold(
        appBar: AppBar(),
        body: Container(
            margin: EdgeInsets.only(top: _height * 0.05),
            height: _height * 1,
            width: _width * 1,
            child: LayoutBuilder(builder: (context, constaints) {
              return ListView(
                physics: BouncingScrollPhysics(),
                children: [
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          height: constaints.maxHeight * 0.002,
                          width: constaints.maxWidth * 0.2,
                          child: Container(
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'Добавить Сотрудника',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Container(
                          height: constaints.maxHeight * 0.002,
                          width: constaints.maxWidth * 0.2,
                          child: Container(
                            color: Colors.black,
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    child: Column(
                      children: [
                        checkImage(),
                        Container(
                          width: constaints.maxWidth * 0.9,
                          margin: EdgeInsets.only(
                            top: constaints.maxHeight * 0.05,
                            bottom: constaints.maxHeight * 0.02,
                          ),
                          child: TextField(
                              controller: usernameController,
                              decoration: style.adminInputDecoration),
                        ),
                        Container(
                          width: constaints.maxWidth * 0.9,
                          margin: EdgeInsets.only(
                            bottom: constaints.maxHeight * 0.05,
                          ),
                          child: TextField(
                              controller: passwordController,
                              decoration: style.adminPasswrodStyle),
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin:
                        EdgeInsets.only(bottom: constaints.maxHeight * 0.03),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          height: constaints.maxHeight * 0.002,
                          width: constaints.maxWidth * 0.2,
                          child: Container(
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'Личная информация:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Container(
                          height: constaints.maxHeight * 0.002,
                          width: constaints.maxWidth * 0.2,
                          child: Container(
                            color: Colors.black,
                          ),
                        )
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                            bottom: constaints.maxHeight * 0.01),
                        width: constaints.maxWidth * 0.9,
                        child: TextField(
                          controller: lastnameController,
                          decoration: style.personLastName,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                            bottom: constaints.maxHeight * 0.01),
                        width: constaints.maxWidth * 0.9,
                        child: TextField(
                            controller: nameController,
                            decoration: style.personFirstName),
                      ),
                      Container(
                        width: constaints.maxWidth * 0.9,
                        margin:
                            EdgeInsets.only(bottom: constaints.minHeight * 0.1),
                        child: TextField(
                            controller: positionController,
                            decoration: style.personPosition),
                      ),
                      // Container(
                      //   width: constaints.maxWidth * 0.9,
                      //   child: TextField(
                      //     controller: companyController,
                      //     decoration: style.adminInputDecoration,
                      //   ),
                      // ),
                    ],
                  )
                ],
              );
            })),
        floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () async {
              final String username = usernameController.text;
              final String password = passwordController.text;
              final String lastname = lastnameController.text;
              final String name = nameController.text;
              final String position = positionController.text;
              final String company = companyController.text;
              final UserModel user = await createUser(
                  username, position, password, name, lastname, image, context);
              // setState(() {
              //   _user = user;
              // });
            }),
      ),
    );
  }
}
