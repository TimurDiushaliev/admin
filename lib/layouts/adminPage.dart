import 'dart:convert';

import 'package:admin/api/Api.dart';
import 'package:admin/layouts/persons.dart';
import 'package:admin/models/userModel.dart';
import 'package:admin/style/style.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';

List<int> a = [];
UserModel _user;

Future<UserModel> createUser(String username, String position, String password,
    String firstname, String lastname, context) async {
  final String apiUrl = baseUrl + 'user/create/';

  var body = {
    'username': username,
    'password': password,
    'first_name': firstname,
    'last_name': lastname,
    "position": position
  };
  try {
    final response =
        await http.post(apiUrl, headers: headers, body: json.encode(body));

    if (response.statusCode == 201) {
      final String responseString = response.body;
      Toast.show('Пользователь успешно создан', context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
      return userModelFromJson(responseString);
    } else {
      Toast.show('Допустимые символы для логина и пароля только <a-z> и <1-9>', context,
          duration: Toast.LENGTH_SHORT);
      return null;
    }
  } catch (e) {
    Toast.show('Что-то пошло не так, проверьте интернет подключение', context,
        duration: Toast.LENGTH_SHORT);
    print('General Error: $e');
  }
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
  final style = Style();
  final persons = MyHomePageState();

  @override
  Widget build(BuildContext context) {
    final _height = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        kToolbarHeight;
    final _width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(),
      body: Container(
          margin: EdgeInsets.only(top: _height * 0.05),
          height: _height * 1,
          width: _width * 1,
          child: LayoutBuilder(builder: (context, constaints) {
            return Column(
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
                  margin: EdgeInsets.only(bottom: constaints.maxHeight * 0.03),
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
                      margin:
                          EdgeInsets.only(bottom: constaints.maxHeight * 0.01),
                      width: constaints.maxWidth * 0.9,
                      child: TextField(
                        controller: lastnameController,
                        decoration: style.personLastName,
                      ),
                    ),
                    Container(
                      margin:
                          EdgeInsets.only(bottom: constaints.maxHeight * 0.01),
                      width: constaints.maxWidth * 0.9,
                      child: TextField(
                          controller: nameController,
                          decoration: style.personFirstName),
                    ),
                    Container(
                      width: constaints.maxWidth * 0.9,
                      child: TextField(
                          controller: positionController,
                          decoration: style.personPosition),
                    ),
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
            final UserModel user = await createUser(
                username, position, password, name, lastname, context);
            setState(() {
              _user = user;
            });
          }),
    );
  }
}
