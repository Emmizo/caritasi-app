import 'dart:convert';

import 'package:cartasiapp/core/api_client.dart';
import 'package:cartasiapp/widget/header.dart';
import 'package:cartasiapp/widget/left_drawer.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Users extends StatefulWidget {
  const Users({super.key});

  @override
  State<Users> createState() => _UsersState();
}

class _UsersState extends State<Users> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  int role = 0;
  int _selectedIndex = 4;
  List<dynamic> membersData = [];
  List<dynamic> filteredMembers = [];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    listOfUser();
  }

  void listOfUser() async {
    final SharedPreferences prefs = await _prefs;
    String? userData = prefs.getString('userData');
    if (userData != null) {
      List<dynamic> userDataListDynamic = jsonDecode(userData);
      List<Map<String, dynamic>> userDataList = List<Map<String, dynamic>>.from(
          userDataListDynamic.map((item) => item as Map<String, dynamic>));
      String? token = userDataList[0]['token'];
      int role2 = userDataList[0]['user']['role'];
      ApiClient apiClient = ApiClient();
      dynamic res = await apiClient.listOfUsers(token!);

      setState(() {
        membersData = res['data'];
        filteredMembers = membersData;
        role = role2;
      });
    }
  }

  void filterSearchResults(String query) {
    if (query.isNotEmpty) {
      setState(() {
        filteredMembers = membersData
            .where((member) =>
                member['first_name']
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                member['last_name']
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                member['email'].toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    } else {
      setState(() {
        filteredMembers = membersData;
      });
    }
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
            // Handle data passed from Header if needed
          });
        },
      ),
      drawer: const LeftDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: filterSearchResults,
                decoration: const InputDecoration(
                  labelText: "Search",
                  hintText: "Search by name or email",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25.0)),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredMembers.length,
                itemBuilder: (context, index) {
                  var member = filteredMembers[index];
                  return UserCard(
                    id: member['id'],
                    firstName: member['first_name'],
                    lastName: member['last_name'],
                    email: member['email'],
                    centerName: member['center_name'] ?? "",
                    roleName: member['role_name'] ?? "",
                    communityName: member['community_name'] ?? "",
                    isActive: member['status'],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // bottomNavigationBar: BottomNavigator(
      //   selectedIndex: _selectedIndex,
      //   onItemTapped: _onItemTapped,
      // ),
    );
  }
}

class UserCard extends StatelessWidget {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String centerName;
  final String roleName;
  final String communityName;
  final String isActive;

  const UserCard({
    super.key,
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.centerName,
    required this.roleName,
    required this.communityName,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  firstName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  lastName,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  email,
                  style: const TextStyle(fontSize: 16),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Centrale: $centerName',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Community: $communityName',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(roleName),
                    Text(
                      isActive == "1" ? 'Active' : 'Deactive',
                      style: TextStyle(
                        fontSize: 16,
                        color: isActive == "1" ? Colors.green : Colors.red,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
