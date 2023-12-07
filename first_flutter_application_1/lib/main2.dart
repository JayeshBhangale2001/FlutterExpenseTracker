import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; 

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

  Future<void> loginUser(BuildContext context, String username, String password) async {
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
        } else { print('invalid credentials');}

    
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
                loginUser(context, _usernameController.text, _passwordController.text);
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

  void fetchTeammatesBirthdays() async {
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                fetchTeammatesBirthdays();
              },
              child: Text('Show Teammates\' Birthdays'),
            ),
            SizedBox(height: 20),
      
Expanded(
  child: birthdays.isEmpty ? Center( child: Text(''), ):
  DataTable(

    columns: <DataColumn>[
      DataColumn(label: Text('Username')),
      DataColumn(label: Text('Mobile Number')),
      DataColumn(label: Text('Birthdate')),
    ],
    rows: List<DataRow>.generate(
      birthdays.length,
      (index) => DataRow(
        cells: <DataCell>[
          DataCell(Text(birthdays[index]['USERNAME'] ?? 'No Username')),
          DataCell(Text(birthdays[index]['MOBILENO'] ?? 'No Mobile Number')),
          DataCell(Text(birthdays[index]['BIRTHDATE'] ?? 'No Birthdate')),
        ],
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
