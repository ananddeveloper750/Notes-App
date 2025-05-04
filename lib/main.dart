import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/Data/Local/db_helper.dart';

import 'home_screen.dart';

void main(){
  runApp(FlutterApp());
}
class FlutterApp extends StatelessWidget{
  //DBHelper obj=DBHelper();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Notes Application",
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Colors.blue,
        appBarTheme: AppBarTheme(
          color: Colors.blue,
          centerTitle: true
        )
      ),
      home:HomeScreen()
    );
  }
}