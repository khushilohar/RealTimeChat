import 'package:flutter/material.dart';

class StatusList extends StatelessWidget {
  const StatusList({super.key});

  // Sample data for status updates (matching the image)
  final List<Map<String, String>> statuses = const [
    {'name': 'Williams Anders', 'time': '', 'avatar': ''}, // no time for "My Status"
    {'name': 'Mom', 'time': '20 minutes ago', 'avatar': 'https://i.pravatar.cc/150?img=1'},
    {'name': 'Hannah', 'time': '28 minutes ago', 'avatar': 'https://i.pravatar.cc/150?img=2'},
    {'name': 'Dad', 'time': '53 minutes ago', 'avatar': 'https://i.pravatar.cc/150?img=3'},
    {'name': 'Cayne Don', 'time': 'Today 04:30 pm', 'avatar': 'https://i.pravatar.cc/150?img=4'},
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: statuses.length,
      itemBuilder: (context, index) {
        final status = statuses[index];
        // First item is "My Status"
        if (index == 0) {
          return Column(
            children: [
              ListTile(
                leading: Stack(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.green[100],
                      backgroundImage: const NetworkImage(
                        'https://i.pravatar.cc/150?img=7', // your own avatar
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xff25D366),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  
                  ],
                  
                ),
                
                title: const Text(
                  'My Status',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Tap to add status update'),
              ),
              const Divider(height: 1, indent: 80), // separator line
            ],
          );
        } else {
          
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(status['avatar']!),
              backgroundColor: Colors.green[100],
            ),
            title: Text(status['name']!),
            subtitle: Text(status['time']!),
          );
          
        }
      },
    );
    
  }
}