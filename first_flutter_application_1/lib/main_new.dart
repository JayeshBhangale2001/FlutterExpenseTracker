import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(), // Set the initial route to the LoginPage
    );
  }
}

class LoginPage extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> loginUser(
      BuildContext context, String username, String password) async {
    const String apiUrl = 'http://10.85.81.228:1337/login';
    // You can perform login authentication here with username and password
    // For simplicity, always consider it successful for this example
    Map<String, String> data = {'username': username, 'password': password};

    // Make POST request
    var response = await http.post(Uri.parse(apiUrl), body: data);

    if (response.statusCode == 200) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SecondPage(),
        ),
      );
    } else {
      print('invalid credentials');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Call loginUser function on login button press
                loginUser(context, _usernameController.text,
                    _passwordController.text);
              },
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

// class SecondPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Birthday Application Dashbor')),
//       body: Align(
//         alignment: Alignment.topCenter,
//         child: Column(

//           mainAxisSize: MainAxisSize.min,
//           children: <Widget>[

//             ElevatedButton(
//                onPressed: () {
//               // Call your function here
//              // loginUser(username, password);
//              },
//               child: const Text('Login'),
//             ),
//           ],
//         )

//       ),
//     );
//   }
// }

class SecondPage extends StatefulWidget {
  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  List<Map<String, dynamic>> birthdays = [];
  List<String> onlineTeammates = [];

  @override
  void initState() {
    super.initState();
    fetchTeammatesBirthdays();
    fetchOnlineTeammembers();
  }

  Future<void> fetchTeammatesBirthdays() async {
    final String apiUrl = 'http://10.85.81.228:1337/teammates-birthdays';

    var response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(response.body);
      setState(() {
        birthdays = List<Map<String, dynamic>>.from(jsonResponse);
      });
    } else {
      print('Failed to fetch birthdays: ${response.statusCode}');
    }
  }

  Future<void> fetchOnlineTeammembers() async {
    final String apiUrl = 'http://10.85.81.228:1337/active-users';

    var response = await http.get(Uri.parse(apiUrl));

    Map<String, dynamic> jsonResponse = jsonDecode(response.body);

    // Access the 'activeUsers' key to get the usernames
    List<dynamic> usernames = jsonResponse['activeUsers'];

    setState(() {
      onlineTeammates = List<String>.from(usernames);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Second Page'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Text(
                'Active Users',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 12),
            Expanded(
              flex: 1,
              child: Center(
                child: FractionallySizedBox(
                  widthFactor: 0.2,
                  child: ListView.builder(
                    itemCount: onlineTeammates.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        title: Text(onlineTeammates[index]),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatPage(
                                recipient: onlineTeammates[index],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                'Teammates\' Birthdays',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 12),
            Expanded(
              flex: 2,
              child: Center(
                child: FractionallySizedBox(
                  widthFactor: 0.7,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      columns: <DataColumn>[
                        DataColumn(label: Text('Username')),
                        DataColumn(label: Text('Mobile Number')),
                        DataColumn(label: Text('Birthdate')),
                      ],
                      rows: birthdays.isEmpty
                          ? [
                              DataRow(cells: [DataCell(Text('No data'))])
                            ]
                          : birthdays.map((birthday) {
                              return DataRow(
                                cells: <DataCell>[
                                  DataCell(
                                    Text(birthday['USERNAME'] ?? 'No Username'),
                                  ),
                                  DataCell(
                                    Text(birthday['MOBILENO'] ??
                                        'No Mobile Number'),
                                  ),
                                  DataCell(
                                    Text(birthday['BIRTHDATE'] ??
                                        'No Birthdate'),
                                  ),
                                ],
                              );
                            }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatPage extends StatefulWidget {
  final String recipient;

  ChatPage({required this.recipient});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController _messageController = TextEditingController();
  List<String> messages = []; // Store chat messages

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipient), // Show recipient's username
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(messages[index]), // Display chat messages
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: () {
                    // Send message functionality
                    // Call a function here to send the message to the recipient
                    // Add the sent message to the messages list for display
                    setState(() {
                      messages.add(_messageController.text);
                      _messageController.clear();
                    });
                  },
                  child: Text('Send'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
