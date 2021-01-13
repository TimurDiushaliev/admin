import 'dart:io';

import 'package:admin/api/Api.dart';
import 'package:admin/layouts/choose.dart';
import 'package:admin/layouts/persons.dart';
import 'package:admin/style/style.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

TextEditingController adminName = TextEditingController();
TextEditingController adminPasswordcontroller = TextEditingController();
final style = Style();
final api = Api();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Directory document = await getApplicationDocumentsDirectory();
  await Hive.init(document.path);
  await Hive.openBox('myBox');
  runApp(MaterialApp(
    home: Choose()));
}

class LoginPage extends StatefulWidget {
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _height = MediaQuery.of(context).size.height;
    final _width = MediaQuery.of(context).size.width;
    var checkToken = box?.get('tokenInTheBox');
    print('check Token = $checkToken');
    if (checkToken == null) {
      return Scaffold(
        body: Container(
            height: _height * 1,
            width: _width * 1,
            child: LayoutBuilder(
              builder: (context, constaints) {
                return Column(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(
                          top: constaints.maxHeight * 0.13,
                          bottom: constaints.maxHeight * 0.05),
                      height: constaints.maxHeight * 0.15,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage('assets/images/clock.png'),
                              fit: BoxFit.fitHeight)),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          height: constaints.maxHeight * 0.002,
                          width: constaints.maxWidth * 0.3,
                          child: Container(
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'Контроль',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Container(
                          height: constaints.maxHeight * 0.002,
                          width: constaints.maxWidth * 0.3,
                          child: Container(
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Container(
                            margin: EdgeInsets.only(
                                top: constaints.maxHeight * 0.07,
                                left: constaints.maxWidth * 0.05,
                                right: constaints.maxWidth * 0.05),
                            child: TextField(
                              controller: adminName,
                              decoration: style.adminInputDecoration,
                            )),
                        Container(
                          margin: EdgeInsets.only(
                              top: constaints.maxHeight * 0.025,
                              left: constaints.maxWidth * 0.05,
                              right: constaints.maxWidth * 0.05),
                          child: TextField(
                              controller: adminPasswordcontroller,
                              decoration: style.adminPasswrodStyle),
                        ),
                        Container(
                          padding: EdgeInsets.only(top: _height * 0.07),
                          child: RaisedButton(
                              color: Colors.blue,
                              padding: EdgeInsets.only(
                                  top: _height * 0.03,
                                  bottom: _height * 0.03,
                                  left: _width * 0.38,
                                  right: _width * 0.38),
                              shape: style.loginButtonStyle,
                              child: Text(
                                'ВОЙТИ',
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () {
                                String getAdminName = adminName.text;
                                String getAdminPassword =
                                    adminPasswordcontroller.text;
                                print(getAdminName);
                                print(getAdminPassword);
                                api.onpressedLogin(
                                    context, getAdminName, getAdminPassword);
                              }),
                        ),
                        // RaisedButton(
                        //     child: Text('БД'),
                        //     onPressed: () {
                        //       var username = box.get('username');
                        //       var password = box.get('password');
                        //       var token = box.get('tokenInTheBox');
                        //       print('''
                        //     username in the box: $username
                        //     password in the box: $password
                        //     token in the box: $token
                        //     ''');
                        //     })
                      ],
                    )
                  ],
                );
              },
            )),
      );
    } else {
      headers['Authorization'] = 'Token $checkToken';
      return MyHomePage();
    }
  }
}
