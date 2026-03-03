import 'package:flutter/material.dart';
import 'package:whatsappcloneui/views/contactCard.dart';

class SelectContact extends StatefulWidget {
  const SelectContact({Key? key}) : super(key: key);

  @override
  _SelectContactState createState() => _SelectContactState();
}

class _SelectContactState extends State<SelectContact> {
  

  @override
  Widget build(BuildContext context) {
// List <ChatBubble> contacts =[
//   // ChatBubble(message: message, time: time, isMe: isMe)
// ];

    return Scaffold(
       appBar: AppBar(
        foregroundColor: Colors.white,
       backgroundColor: const Color(0xff128C7E),
        title: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Selected Contacts" ,
           style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
           ),
          ),
          
        ],
        ),
        actions: [
          IconButton(onPressed:(){}, icon: Icon(Icons.search)),
          PopupMenuButton<String>(
            padding: EdgeInsets.all(0),
            onSelected: (value){
              print(value);
            },
            itemBuilder: (BuildContext context){
              return[
                PopupMenuItem(child: Text("Invite a friend"),
                value: "Invite a friend",
                ),
                PopupMenuItem(child: Text("Contacts"),
                value: "Contacts",
                ),
                PopupMenuItem(child: Text("Refresh"),
                value: "Refresh",
                ),
                PopupMenuItem(child: Text("Help"),
                value: "Help",
                )
              
              ];
            },
          )
        ],
       ),
       body: ListView.builder(
        itemCount: 10,
        itemBuilder:(context, index) => Contactcard(),)
         
       );
    
  }

}
//   Widget _buildSectionHeader(String title) {
    
//   }

//   Widget _buildCreateTile(IconData icon, String label) {
   
//   }

//   Widget _buildContactTile(Map<String, String> contact) {
    
// }