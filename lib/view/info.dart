import 'dart:async';
import 'dart:io';

import 'package:admin/api/Api.dart';
import 'package:admin/models/infoModel.dart';
import 'package:admin/models/profileModel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:date_format/date_format.dart';
import 'package:toast/toast.dart';

class InfoPage extends StatefulWidget {
  final profileId;
  InfoPage({Key key, @required this.profileId}) : super(key: key);

  @override
  _InfoPageState createState() => _InfoPageState(profileId);
}

List<InfoModel> _list = List<InfoModel>();
var domen = '192.168.88.167:8000';

Future fetchData(profileId, context,{start, end}) async {
  try {
    var startDate = start == null
        ? DateTime.now().subtract(new Duration(days: 7)).toLocal()
        : start;
    var endDate = end == null ? DateTime.now().toLocal() : end;
    var queryParameters = {
      'profile_id': profileId.id.toString(),
      'start_date': "${startDate.year}-${startDate.month}-${startDate.day}",
      'end_date': "${endDate.year}-${endDate.month}-${endDate.day}"
    };
    var url = Uri.http(domen,
        'api/timecontrol/list/', queryParameters);
    var response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      var infoList = infoModelFromJson(response.body);
      return infoList;
    }
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

class _InfoPageState extends State<InfoPage> {
  ProfileModel profileId;
  DateTime _startDate;
  DateTime _endDate;

  _InfoPageState(profileId) {
    this.profileId = profileId;
  }

  @override
  void initState() {
    fetchData(profileId,context).then((value) {
      setState(() {
        print(value);
        _list = List.from(value);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(profileId.user.firstName + ' ' + profileId.user.lastName),
          centerTitle: true),
      body: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            RaisedButton(
                color: Colors.blue,
                child: Text('Дата начала'),
                onPressed: () {
                  showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2019),
                          lastDate: DateTime(2024))
                      .then((value) {
                    _startDate = value;
                    fetchData(profileId,context, start: _startDate, end: _endDate)
                        .then((value) {
                      setState(() {
                        _list = List.from(value);
                      });
                    });
                  });
                }),
            RaisedButton(
                color: Colors.blue,
                child: Text('Дата конца'),
                onPressed: () {
                  showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2019),
                          lastDate: DateTime(2024))
                      .then((value) {
                    _endDate = value;
                    fetchData(profileId,context, start: _startDate, end: _endDate)
                        .then((value) {
                      setState(() {
                        _list = List.from(value);
                      });
                    });
                  });
                })
          ]),
          Expanded(
            child: ListView.builder(
              itemBuilder: (_, index) {
                // print(_list);

                return Card(
                    child: Column(
                  children: <Widget>[
                    ListTile(
                        title: monthInfo(_list[index].date),
                        subtitle: Text(
                          getDatesString(_list[index]),
                        ))
                  ],
                ));
              },
              itemCount: _list.length,
            ),
          ),
        ],
      ),
    );
  }
}

Widget monthInfo(date) {
  int month = date.month;
  List<String> months = [
    'Январь',
    'Февраль',
    'Март',
    'Апрель',
    'Май',
    'Июнь',
    'Июль',
    'Август',
    'Сентябрь',
    'Октябрь',
    'Ноябрь',
    'Декабрь'
  ];
  Widget result =
      Text(formatDate(date, [dd, ' - ', months[month - 1], ' - ', yyyy]));
  return result;
}

String getDatesString(InfoModel info) {
  String incoming = formatDate(info.incoming, [HH, ':', nn]);
  String outcoming =
      (info.outcoming == '') ? '--' : formatDate(info.outcoming, [HH, ':', nn]);
  return 'Время прихода $incoming   --   Время ухода: $outcoming';
}
