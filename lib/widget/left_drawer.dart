import 'dart:convert';

import 'package:cartasiapp/pages/home.dart';
import 'package:cartasiapp/pages/income.dart';
import 'package:cartasiapp/pages/login.dart';
import 'package:cartasiapp/pages/members.dart';
import 'package:cartasiapp/pages/support.dart';
import 'package:cartasiapp/pages/users.dart';
import 'package:cartasiapp/provider/login_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LeftDrawer extends StatefulWidget {
  const LeftDrawer({super.key});

  @override
  State<LeftDrawer> createState() => _LeftDrawerState();
}

class _LeftDrawerState extends State<LeftDrawer> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  List<Map<String, dynamic>> userInfo = [];

  @override
  void initState() {
    super.initState();
    getUserResult();
  }

  void getUserResult() async {
    final SharedPreferences prefs = await _prefs;
    String? userData = prefs.getString('userData');
    // print(userData);

    if (userData != null && userData.isNotEmpty) {
      try {
        // Decode the JSON string into a List<dynamic>
        List<dynamic> userDataListDynamic = jsonDecode(userData);

        // Cast the List<dynamic> to List<Map<String, dynamic>>
        List<Map<String, dynamic>> userDataList =
            List<Map<String, dynamic>>.from(userDataListDynamic
                .map((item) => item as Map<String, dynamic>));

        // Access the token from the first user map
        String? token = userDataList[0]['token'];

        if (token != null) {
          await context.read<LoginData>().setUserInfo(token);

          if (mounted) {
            setState(() {
              final loginData = Provider.of<LoginData>(context, listen: false);
              // print("login data $loginData");
              userInfo = loginData.getUserData;

              // print("Hi $userInfo");
            });
          }
        }
      } catch (e) {
        // Handle the decoding error appropriately
        print("Error decoding JSON: $e");
      }
    }
  }

  logOut() async {
    final SharedPreferences prefs = await _prefs;
    // await prefs.remove('token');
    await prefs.remove('userData');
    Navigator.push(
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute(
        builder: (context) => const Login(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 222, 66, 9),
            ),
            margin: EdgeInsets.zero,
            padding: EdgeInsets.zero,
            child: Container(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  userInfo.isNotEmpty
                      ? userInfo[0]['user']['first_name']
                      : "Unknown",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('Dashboard'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Home(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Manage Beneficiaries'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Members(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.money_sharp),
                  title: const Text('Manage Grant'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Income(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.support),
                  title: const Text('Manage Support'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Support(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Manage users'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Users(),
                      ),
                    );
                  },
                ),
                const Divider(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                ),
                color: Colors.red,
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.logout,
                  color: Colors.white,
                ),
                title: const Text(
                  'Log out',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  logOut();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
