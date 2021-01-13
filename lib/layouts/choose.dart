import 'package:admin/layouts/adminPage.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class Choose extends StatelessWidget {
  const Choose({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,  
          children: [
            Text('Кто вы?'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                RaisedButton(
                  color: Colors.pink,
                  child: Text('Работадатель'),
                  onPressed: (){
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> LoginPage()));
                  }),
                RaisedButton(
                  color: Colors.pink,
                  child: Text('Работник'),
                  onPressed: (){
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> AdminPage()));
                  }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
