import 'dart:convert';

import 'package:cartasiapp/provider/login_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Header extends StatefulWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Function(List<Map<String, dynamic>>) onDataPassed;
  final int selectedIndex;
  const Header(
      {super.key,
      required this.scaffoldKey,
      required this.selectedIndex,
      required this.onDataPassed});

  @override
  State<Header> createState() => _HeaderState();
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _HeaderState extends State<Header> {
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
              widget.onDataPassed(userInfo);
            });
          }
        }
      } catch (e) {
        // Handle the decoding error appropriately
        print("Error decoding JSON: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Padding(
          padding: EdgeInsets.fromLTRB(0, 0, 20.0, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.list),
                onPressed: () {
                  widget.scaffoldKey.currentState?.openDrawer();
                },
              ),
              Text(
                widget.selectedIndex == 0
                    ? 'Dashboard'
                    : widget.selectedIndex == 1
                        ? 'List of Beneficiaries'
                        : widget.selectedIndex == 2
                            ? 'List of Supported '
                            : widget.selectedIndex == 3
                                ? 'List of Supported'
                                : widget.selectedIndex == 4
                                    ? 'List of Users'
                                    : widget.selectedIndex == 5
                                        ? "Grant"
                                        : "",
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                ),
              ),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: GestureDetector(
                  onTap: () {
                    widget.scaffoldKey.currentState
                        ?.openEndDrawer(); // Open the end drawer
                    getUserResult;
                  },
                  child: Center(
                    child: Text(
                      getInitials(userInfo.isNotEmpty
                          ? userInfo[0]['user']['first_name']
                          : ''),
                      style: const TextStyle(
                          color: Color.fromARGB(255, 136, 133, 133)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String getInitials(String fullname) {
    if (fullname.isEmpty) {
      return ''; // Return empty string if name is empty
    } else {
      List<String> names = fullname.split(' ');
      if (names.length == 1) {
        return names[0]
            .substring(0, 1)
            .toUpperCase(); // Return first character if only one word
      } else {
        String initials = '';
        for (var name in names) {
          if (name.isNotEmpty) {
            initials += name.substring(0, 1).toUpperCase();
          }
        }
        return initials;
      }
    }
  }
}
