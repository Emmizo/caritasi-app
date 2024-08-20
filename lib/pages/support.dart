import 'dart:convert';

import 'package:cartasiapp/core/api_client.dart';
import 'package:cartasiapp/widget/bottom_navigator.dart';
import 'package:cartasiapp/widget/header.dart';
import 'package:cartasiapp/widget/left_drawer.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Support extends StatefulWidget {
  const Support({super.key});

  @override
  State<Support> createState() => _SupportState();
}

class _SupportState extends State<Support> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  int role = 0;
  int _selectedIndex = 2;
  List<dynamic> membersData = [];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    listOfSupport();
  }

  void listOfSupport() async {
    final SharedPreferences prefs = await _prefs;
    String? userData = prefs.getString('userData');
    List<dynamic> userDataListDynamic = jsonDecode(userData!);
    List<Map<String, dynamic>> userDataList = List<Map<String, dynamic>>.from(
        userDataListDynamic.map((item) => item as Map<String, dynamic>));
    String? token = userDataList[0]['token'];
    int role2 = userDataList[0]['user']['role'];
    ApiClient apiClient = ApiClient();
    dynamic res = await apiClient.listOfSupports(token!);

    setState(() {
      membersData = res['data'];
      role = role2;
    });
  }

  Widget buildListItem(Map<String, dynamic> data) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "${data['first_name'] ?? ''} ${data['last_name'] ?? ''}",
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  "Amount: ${data['amount']} Frw",
                  style: TextStyle(
                    fontSize: 16.0,
                    color: data['statuses'] == 0
                        ? Colors.blue
                        : data['statuses'] == 1
                            ? Colors.green
                            : Colors.amber[700],
                  ),
                )
              ],
            ),
            const SizedBox(height: 8.0),
            const Text(
              "Description",
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.grey,
              ),
            ),
            Text(
              data['description'] ?? '',
              style: const TextStyle(
                fontSize: 16.0,
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Date of Birth:",
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      data['bod'] ?? '',
                      style: const TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Phone:",
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      data['phone'] ?? '',
                      style: const TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Text(
              data['statuses'] == 0
                  ? "Wait"
                  : data['statuses'] == 1
                      ? "Paid"
                      : "Not Paid",
              style: TextStyle(
                fontSize: 16.0,
                color: data['statuses'] == 0
                    ? Colors.blue
                    : data['statuses'] == 1
                        ? Colors.green
                        : Colors.red,
              ),
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                Text(
                  "Created by: ${data['user_first_name'] ?? ''} ${data['user_last_name'] ?? ''}",
                  style: const TextStyle(
                    fontSize: 14.0,
                    color: Colors.grey,
                  ),
                ),
                const Spacer(),
                Text("Category: ${data['category_name']}")
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      appBar: Header(
        scaffoldKey: _scaffoldKey,
        selectedIndex: _selectedIndex,
        onDataPassed: (data) {
          setState(() {
            // print(_dataFromHeader);
          });
        },
      ),
      drawer: LeftDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: membersData.isEmpty
                ? [Text("No data found")]
                : membersData.map((data) => buildListItem(data)).toList(),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigator(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
