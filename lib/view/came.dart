import 'package:admin/api/Api.dart';
import 'package:admin/models/profileModel.dart';
import 'package:admin/view/didntCome.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CamePage extends StatelessWidget {
  // const CamePage({Key key}) : super(key: key);
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
        return false;
      }
    }
    return true;
  }

  Future catchNotLazyPerson(context) async {
    List list1 = await fetchProfileList();
    var list2 = await fetchDate(context);
      list2 = list2.map((e) => e.profile).toList();
      list1.removeWhere((e) => contains(e, list2));
    return list1;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: catchNotLazyPerson(context),
      builder: (context, snapshot){
        print('Snapshot data: ${snapshot.data}');
        if(snapshot.connectionState == ConnectionState.done){
        return Scaffold(
          appBar: AppBar(),
          body: ListView.builder(itemBuilder: (context, index){
            return ListTile(
              leading: snapshot.data[index].image != null
                              ? CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(snapshot.data[index].image.file),
                                )
                              : Icon(Icons.person),
              title: Text('${snapshot.data[index].user.firstName}' + ' ' '${snapshot.data[index].user.lastName}'),
              subtitle: Text(snapshot.data[index].position),
            );
          },
          itemCount: snapshot.data.length,
          ),
        );
        } else{
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: CircularProgressIndicator(),),
          );
        }
    });
}
}