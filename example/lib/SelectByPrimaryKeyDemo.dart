import 'package:flutter/material.dart';
import 'package:flutter_orm_plugin/flutter_orm_plugin.dart';


class SelectByPrimaryKeyDemo extends StatefulWidget {
  @override
  _SelectByPrimaryKeyDemoState createState() => _SelectByPrimaryKeyDemoState();
}

class _SelectByPrimaryKeyDemoState extends State<SelectByPrimaryKeyDemo>{

  List userList = new List();

  @override
  void initState() {
    super.initState();
    Query("Student").primaryKey([1,3,5]).all().then((List l) {
      setState(() {
        userList = l;
      });
    });

  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Select Demo"),
      ),
      body:  new ListView.builder(
        itemCount: userList.length,
        padding: const EdgeInsets.all(10.0),
        itemBuilder: (context, i) {
          Map data = userList[i];
          return GestureDetector(
            child: new Column(
              crossAxisAlignment:CrossAxisAlignment.start,
              children: <Widget>[
                new Text('name  : ${data["name"]}', style: const TextStyle(fontSize: 15.0)),
                new Text('studentId: ${data["studentId"]}', style: const TextStyle(fontSize: 15.0)),
                new Text('class : ${data["class"]}', style: const TextStyle(fontSize: 15.0)),
                new Text('score : ${data["score"]}', style: const TextStyle(fontSize: 15.0)),
                new Divider(),
              ],
            ),
          );
        },
      ),
    );
  }
}


