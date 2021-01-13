import 'package:admin/layouts/didntCome.dart';
import 'package:flutter/material.dart';

class CamePage extends StatelessWidget {
  const CamePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchDate(context),
      builder: (context, snapshot){
        print('Snapshot data: ${snapshot.data}');
        if(snapshot.connectionState == ConnectionState.done){
        return Scaffold(
          appBar: AppBar(),
          body: ListView.builder(itemBuilder: (context, index){
            return ListTile(
              leading: Icon(Icons.account_circle),
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