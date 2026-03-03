import 'package:flutter/material.dart';
 class Contactcard extends StatelessWidget {
  const Contactcard ({super.key});
  @override
  Widget build(BuildContext context){
    return InkWell(
      onTap: (){},
      child: ListTile(
       leading: CircleAvatar(
         radius: 23,
         backgroundColor: Colors.blueGrey[200],
       ),
       title: Text("Beauty" ,
      style: TextStyle(
        fontSize: 15,
        fontWeight:  FontWeight.bold,
      )
       ),
       subtitle: Text('hi.....', style: TextStyle(
         fontSize: 13,
       ) ,),
      ),
    );
  }
 }