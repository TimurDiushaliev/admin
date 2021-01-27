import 'package:admin/api/Api.dart';
import 'package:admin/contextMenu/contextMenu.dart';
import 'package:admin/view/adminPage.dart';
import 'package:admin/view/came.dart';
import 'package:admin/view/didntCome.dart';
import 'package:admin/view/info.dart';
import 'package:admin/models/profileModel.dart';
import 'package:flutter/material.dart';
import '../main.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  MyHomePageState createState() => new MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  TextEditingController editingController = TextEditingController();

  final duplicateItems = List<String>.generate(10000, (i) => "Item $i");
  var profiles = List();
  var items = List();
  bool isFirstLoad = true;
  final api = Api();

  void navToAdminPage(context) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => AdminPage()));
  }

  void navToCamePage(context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => CamePage()));
  }

  void navToDidntComePage() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => LazyPersones()));
  }

  void exit(context) {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) {
      headers.remove('Authorization');
      box.delete('username');
      box.delete('password');
      box.delete('tokenInTheBox');
      adminPasswordcontroller.clear();
      return LoginPage();
    }), (route) => false);
    adminPasswordcontroller.clear();
  }

  void filterSearchResults(String query) {
    List dummySearchList = List();
    dummySearchList.addAll(profiles);
    query = query.toLowerCase();
    print(query);
    if (query.isNotEmpty) {
      List<ProfileModel> dummyListData = List<ProfileModel>();
      dummySearchList.forEach((item) {
        var fullName = '${item.user.firstName} ${item.user.lastName}';
        if (fullName.toLowerCase().contains(query)) {
          print('contains');
          dummyListData.add(item);
          print(item.user.username);
        }
      });
      print('data: ${dummyListData[0].user.username}');
      setState(() {
        print('1');
        items.clear();
        items.addAll(dummyListData);
        print('result: ${items[0].user.username}');
      });
    } else {
      setState(() {
        print('2');
        items.clear();
        items.addAll(profiles);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text('Список сотрудников'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
              icon: Icon(Icons.access_time),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LazyPersones()));
              })
        ],
      ),
      drawer: Drawer(
          child: ListView(
        children: [
          DrawerHeader(
            child: Image.network(
                'https://energonova.org/sites/default/files/О%20компании.jpg'),
          ),
          Card(
            child: ListTile(
              onTap: () {
                navToAdminPage(context);
              },
              leading: Icon(Icons.person_add),
              title: Text('Добавить сотрудника'),
            ),
          ),
          Card(
            child: ListTile(
              onTap: () => navToCamePage(context),
              leading: Icon(Icons.person),
              title: Text('Присутствующие'),
            ),
          ),
          Card(
            child: ListTile(
              onTap: () => navToDidntComePage(),
              leading: Icon(Icons.person_outline),
              title: Text('Отсутствующие'),
            ),
          ),
          Card(
            child: ListTile(
              onTap: () {
                exit(context);
              },
              leading: Icon(Icons.exit_to_app),
              title: Text('Выйти'),
            ),
          )
        ],
      )),
      body: Container(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (value) {
                  print('fsd');
                  filterSearchResults(value);
                },
                controller: editingController,
                decoration: InputDecoration(
                    labelText: "Поиск...",
                    // hintText: "Поиск...",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0)))),
              ),
            ),
            Expanded(
                child: FutureBuilder(
              future: api.fetchDataFromJson(context),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  print('snapshot data 2 : ${snapshot.data}');
                  profiles.clear();
                  profiles.addAll(snapshot.data);
                  if (isFirstLoad) {
                    items.addAll(profiles);
                    isFirstLoad = false;
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      // print('image ${items[index]}');
                      return ListTile(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        InfoPage(profileId: items[index])));
                          },
                          leading: items[index].image != null
                              ? CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(items[index].image.file),
                                )
                              : Icon(Icons.person),
                          title: Text(
                              '${items[index].user.firstName} ${items[index].user.lastName}'),
                          subtitle: Text('${items[index].position}'),
                          trailing: PopupMenuButton<String>(
                            onSelected: (e) {
                              api
                                  .delete(snapshot.data[index].id, context)
                                  .then((value) => setState(() {
                                        api
                                            .fetchDataFromJson(context)
                                            .then((value) => items = value);
                                      }));
                            },
                            itemBuilder: (BuildContext context) {
                              return ContextMenu.list.map((e) {
                                return PopupMenuItem(value: e, child: Text(e));
                              }).toList();
                            },
                          ));
                    },
                    itemCount: items.length,
                  );
                } else {
                  print('else');
                  return Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
              },
            )),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.refresh),
          onPressed: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => MyHomePage()));
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
