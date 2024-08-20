import 'dart:convert';

import 'package:cartasiapp/core/api_client.dart';
import 'package:cartasiapp/pages/members.dart';
import 'package:cartasiapp/pages/users.dart';
import 'package:cartasiapp/widget/bottom_navigator.dart';
import 'package:cartasiapp/widget/header.dart';
import 'package:cartasiapp/widget/left_drawer.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  int _selectedIndex = 0;
  int role = 0;
  String rolename = "";
  String fullname = "";
  String profile = "";
  String url_ = "";
  List<dynamic> membersData = [];
  String users = "0";
  String members = "0";
  String communities = "0";
  String centers = "0";

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    dashboard();
    listOfMember();
  }

  void dashboard() async {
    final SharedPreferences prefs = await _prefs;
    String? userData = prefs.getString('userData');
    List<dynamic> userDataListDynamic = jsonDecode(userData!);
    List<Map<String, dynamic>> userDataList = List<Map<String, dynamic>>.from(
        userDataListDynamic.map((item) => item as Map<String, dynamic>));
    String? token = userDataList[0]['token'];
    String fullname3 = userDataList[0]['user']['first_name'];
    String rolename3 = userDataList[0]['user']['role_name'];
    String profile3 = userDataList[0]['user']['profile_picture'] ?? "";
    String url3 = userDataList[0]['base_url'];
    ApiClient apiClient = ApiClient();
    dynamic res = await apiClient.dashboard(token!);

    Map<String, dynamic> results = res;

    setState(() {
      users = results['data']['users'].toString();
      members = results['data']['members'].toString();
      communities = results['data']['communities'].toString();
      centers = results['data']['centers'].toString();
      fullname = fullname3;
      rolename = rolename3;
      profile = profile3;
      url_ = url3;
    });
  }

  void listOfMember() async {
    final SharedPreferences prefs = await _prefs;
    String? userData = prefs.getString('userData');
    List<dynamic> userDataListDynamic = jsonDecode(userData!);
    List<Map<String, dynamic>> userDataList = List<Map<String, dynamic>>.from(
        userDataListDynamic.map((item) => item as Map<String, dynamic>));
    String? token = userDataList[0]['token'];
    int role2 = userDataList[0]['user']['role'];
    ApiClient apiClient = ApiClient();
    dynamic res = await apiClient.listOfMember(token!);

    setState(() {
      membersData = res['data'];
      role = role2;
    });
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
          setState(() {});
        },
      ),
      drawer: const LeftDrawer(),
      body: Dashboard(
        users: users,
        members: members,
        communities: communities,
        centers: centers,
        membersData: membersData,
        fullname: fullname,
        profile: profile,
        rolename: rolename,
        url_: url_,
      ),
      bottomNavigationBar: BottomNavigator(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

class Dashboard extends StatelessWidget {
  final String users;
  final String members;
  final String communities;
  final String centers;
  final String fullname;
  final String profile;
  final String rolename;
  final String url_;
  final List<dynamic> membersData;

  const Dashboard({
    super.key,
    required this.users,
    required this.members,
    required this.communities,
    required this.centers,
    required this.membersData,
    required this.fullname,
    required this.profile,
    required this.rolename,
    required this.url_,
  });

  @override
  Widget build(BuildContext context) {
    // Extract the first 5 members data
    List<dynamic> subset =
        membersData.length > 5 ? membersData.sublist(0, 5) : membersData;
    return Container(
      color: const Color.fromARGB(255, 225, 222, 222),
      child: ListView(
        children: <Widget>[
          Container(
            height: 300,
            padding: const EdgeInsets.all(16),
            child: Container(
              color: Colors.blue.shade900,
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  profile.isNotEmpty
                      ? Container(
                          width: 100.0, // Set the width you want
                          height: 100.0, // Set the height you want
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle, // Circular shape
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26, // Shadow color
                                blurRadius: 10.0, // Spread of the shadow
                                offset: Offset(0, 5), // Position of the shadow
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.network(
                              url_ + '/' + profile,
                              fit: BoxFit
                                  .cover, // Fit the image within the container
                            ),
                          ),
                        )
                      : const CircleAvatar(
                          radius: 40,
                          child: Icon(Icons.person, size: 40),
                          backgroundColor: Colors.white,
                        ),
                  const SizedBox(height: 8),
                  Text(
                    fullname,
                    style: const TextStyle(
                      color: Colors.orange,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    rolename,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 150, // Set a fixed height for the PageView
            child: PageView(
              controller: PageController(viewportFraction: 0.8),
              children: <Widget>[
                _buildSummaryCard('MANAGE MEMBERS', members, context),
                _buildSummaryCard('MANAGE USERS', users, context),
                _buildSummaryCard('MANAGE COMMUNITIES', communities, context),
                _buildSummaryCard('MANAGE CENTERS', centers, context),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const Center(child: Text('Recently joined member')),
                Column(
                  children: subset.map((member) {
                    return Card(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  '${member['first_name']} ${member['last_name']}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const Spacer(),
                                Text(
                                  member['status'] == 0
                                      ? "Pending"
                                      : member['status'] == 1
                                          ? "Accepted"
                                          : "Rejected",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: member['status'] == 0
                                        ? Colors.blue
                                        : member['status'] == 2
                                            ? Colors.red
                                            : Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Text(
                                  'Category',
                                  style: TextStyle(fontSize: 14),
                                ),
                                const Spacer(),
                                Text(member['category_name'] ?? "N/A"),
                              ],
                            ),
                            Row(
                              children: [
                                const Text(
                                  'Community',
                                  style: TextStyle(fontSize: 14),
                                ),
                                const Spacer(),
                                Text(member['community_name'] ?? "N/A"),
                              ],
                            ),
                            Text(
                              member['created_at'].substring(0, 10),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, BuildContext context) {
    return GestureDetector(
      onTap: () {
        // print(title);
        if (title == 'MANAGE MEMBERS') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Members()),
          );
        } else if (title == 'MANAGE USERS') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Users()),
          );
        }
        // Add other navigation logic here if needed
      },
      child: Card(
        child: Container(
          width: 150, // Set the desired width for the Card
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
