import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:admin/layouts/persons.dart';
import 'package:admin/models/profileModel.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:toast/toast.dart';
import 'package:http/http.dart' as http;

import '../main.dart';

final String baseUrl = 'http://timeset.pythonanywhere.com/api/v1/';
var headers = {
  'Content-type': 'application/json; charset=Utf-8',
  'Authorization': ''
};
var box = Hive.box('myBox');
BuildContext dialogContext;
bool connectionState;

class Api {
  showAlertDialog(BuildContext context) {
    AlertDialog alertDialog = AlertDialog(
      content: Row(children: [
        CircularProgressIndicator(),
        Container(
          margin: EdgeInsets.only(left: 10),
          child: Text('Подождите...'),
        )
      ]),
    );
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          dialogContext = context;
          return alertDialog;
        });
  }

  bool loginResult = false;

  Future loginAdmin(context, String name, String password) async {
    try {
      showAlertDialog(context);
      final String apiUrl = baseUrl + 'auth/token/login/';
      final body = {'username': name, 'password': password};
      final response =
          await http.post(apiUrl, headers: headers, body: json.encode(body));
      print(json.decode(response.body));

      if (response.statusCode == 200) {
        final Map responseBody = json.decode(response.body);
        var token = responseBody['auth_token'];
        print('token: $token');
        box.put('tokenInTheBox', token);
        headers['Authorization'] = 'Token $token';
        print('headers: $headers');
        box.put('username', name);
        box.put('password', password);
        loginResult = true;
      } else {
        loginResult = false;
      }
      connectionState = true;
      Navigator.pop(dialogContext);
    } on TimeoutException catch (e) {
      Toast.show(
          'Вышло время ожидания, проверьте интернет подключение', context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
      print('Timeout Error: $e');
      Navigator.pop(dialogContext);
      connectionState = false;
    } on SocketException catch (e) {
      Toast.show(
          'Связь с сервером прервана, проверьте интернет подключение', context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
      print('Socket Error: $e');
      Navigator.pop(dialogContext);
      connectionState = false;
    } on Error catch (e) {
      print('General Error: $e');
      Navigator.pop(dialogContext);
      connectionState = false;
    }
  }

  Future onpressedLogin(context, String adminName, String adminPassword) async {
    if (adminName.isNotEmpty && adminPassword.isNotEmpty) {
      await loginAdmin(context, adminName, adminPassword);
      print('loginresult: $loginResult');
      if (connectionState) {
        if (loginResult) {
          Navigator.push(context,
                  MaterialPageRoute(builder: (context) => MyHomePage()))
              .then((value) => adminPasswordcontroller.clear());
        } else {
          Toast.show('Такого пользователя не существует', context,
              duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
        }
      }
    } else {
      Toast.show('Введите логин и пароль', context,
          duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
    }
  }

  Future<List<ProfileModel>> fetchDataFromJson(context) async {
    try {
      final apiUrl = baseUrl + 'user/list/';
      var response = await http.get(
        apiUrl,
        headers: headers,
      );
      var persons = List<ProfileModel>();
      if (response.statusCode == 200) {
        var personsJson = json.decode(response.body);
        for (var person in personsJson) {
          persons.add(ProfileModel.fromJson(person));
        }
      } else {
        print('fetchDataFromJson $headers');
        print('1: ${json.decode(response.body)}');
      }
      return persons;
    } on TimeoutException catch (e) {
      Toast.show(
          'Вышло время ожидания, проверьте интернет подключение', context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
      print('Timeout Error: $e');
      // Navigator.pop(dialogContext);
      connectionState = false;
    } on SocketException catch (e) {
      Toast.show(
          'Связь с сервером прервана, проверьте интернет подключение', context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
      print('Socket Error: $e');
      // Navigator.pop(dialogContext);
      connectionState = false;
    } on Error catch (e) {
      print('General Error: $e');
      // Navigator.pop(dialogContext);
      connectionState = false;
    }
  }

  Future delete(profileId, context) async {
    try {
      final apiUrl = baseUrl + 'user/delete/$profileId/';
      var response = await http.delete(apiUrl, headers: headers);
      if (response.statusCode == 204) {
        Toast.show('Пользователь успешно удалён', context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
        return true;
      } else {
        Toast.show('Произошла ошибка', context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
        print(json.decode(response.body));
        return false;
      }
    } on TimeoutException catch (e) {
      Toast.show(
          'Вышло время ожидания, проверьте интернет подключение', context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
      print('Timeout Error: $e');
      // Navigator.pop(dialogContext);
      connectionState = false;
    } on SocketException catch (e) {
      Toast.show(
          'Связь с сервером прервана, проверьте интернет подключение', context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
      print('Socket Error: $e');
      // Navigator.pop(dialogContext);
      connectionState = false;
    } on Error catch (e) {
      print('General Error: $e');
      // Navigator.pop(dialogContext);
      connectionState = false;
    }
  }
}
