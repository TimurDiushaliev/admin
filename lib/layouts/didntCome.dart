
import 'dart:async';
import 'dart:io';

import 'package:admin/api/Api.dart';
import 'package:admin/models/infoModel.dart';
import 'package:admin/models/profileModel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';

Future fetchDate(context) async {
  try{
    List dateList = [];
    var date = DateTime.now().toLocal();
    var queryParametres = {
      'start_date': '${date.year}-${date.month}-${date.day}'
    };
    var uri = Uri.http('timeset.pythonanywhere.com',
        '/api/v1/timecontrol/list/', queryParametres);
    var response = await http.get(
      uri,
      headers: headers,
    );
    if (response.statusCode == 200) {
      dateList = infoModelFromJson(response.body);
    }
    return dateList;
  } on TimeoutException catch (e) {
    Toast.show('Вышло время ожидания, проверьте интернет подключение', context,
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

class LazyPersones extends StatelessWidget {
  final apiUrl = baseUrl + 'user/list';
  List persons = [];
  Future fetchProfileList() async {
    var response = await http.get(apiUrl, headers: headers);
    if (response.statusCode == 200) {
      persons = profileModelFromJson2(response.body);
    }
    return persons;
  }

  

  bool contains(ProfileModel element, persons) {
    for (var i = 0; i < persons.length; i++) {
      if (element.id == persons[i].id) {
        return true;
      }
    }
    return false;
  }

  Future catchLazyPerson(context) async {
    List list1 = await fetchProfileList();
    var list2 = await fetchDate(context);
      list2 = list2.map((e) => e.profile).toList();
      list1.removeWhere((e) => contains(e, list2));
    return list1;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: catchLazyPerson(context),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            print(snapshot.data);
            return Scaffold(
                appBar: AppBar(
                  title: Text('Отсутствующие'),
                  backgroundColor: Colors.red,
                  centerTitle: true,
                ),
                body: ListView.builder(
                    itemBuilder: (context, index) {
                      return Card(
                        child: Column(
                          children: [
                            ListTile(
                                title: Text(
                                    snapshot.data[index].user.firstName +
                                        ' ' +
                                        snapshot.data[index].user.lastName))
                          ],
                        ),
                      );
                    },
                    itemCount: snapshot.data.length));
          } else {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.red,
              ),
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        });
  }
}