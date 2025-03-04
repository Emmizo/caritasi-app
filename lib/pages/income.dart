import 'dart:convert';

import 'package:cartasiapp/core/api_client.dart';
import 'package:cartasiapp/widget/header.dart';
import 'package:cartasiapp/widget/left_drawer.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Income extends StatefulWidget {
  const Income({super.key});

  @override
  State<Income> createState() => _IncomeState();
}

class _IncomeState extends State<Income> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  int _selectedIndex = 5;
  int role = 0;
  String amount = '0';
  List<dynamic> incomeData = [];
  late AnimationController _controller;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    listOfIncome();

    // Initialize the animation controller for the blinking effect
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true); // Repeating the animation back and forth
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose of the controller when not needed
    super.dispose();
  }

  void listOfIncome() async {
    final SharedPreferences prefs = await _prefs;
    String? userData = prefs.getString('userData');
    List<dynamic> userDataListDynamic = jsonDecode(userData!);
    List<Map<String, dynamic>> userDataList = List<Map<String, dynamic>>.from(
        userDataListDynamic.map((item) => item as Map<String, dynamic>));
    String? token = userDataList[0]['token'];
    int role2 = userDataList[0]['user']['role'];
    ApiClient apiClient = ApiClient();
    dynamic res = await apiClient.listOfIncome(token!);

    setState(() {
      incomeData = res['data']['incomes'];
      amount = res['data']['amount'].toString();
      // Access the list of incomes
      role = role2;
      // Apply conditional logic based on role and source_id for each income
      for (var income in incomeData) {
        double amount2 = double.parse(
            income['amount_per_each']); // Parsing the amount to double

        if (income['source_id'] == 1) {
          income['calculated_amount'] = (role == 2 || role == 4)
              ? 0.0
              : (role == 5)
                  ? amount2 * 3 / 4
                  : (role == 3)
                      ? amount2 - (amount2 * 3 / 4)
                      : amount;
        } else if (income['source_id'] == 2) {
          income['calculated_amount'] = (role == 2 || role == 5)
              ? amount2 / 2
              : (role == 4 || role == 3)
                  ? 0.0
                  : amount2;
        } else if (income['source_id'] == 3) {
          income['calculated_amount'] = amount2;
        }
      }
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
          setState(() {
            // Handle data passed from Header if needed
          });
        },
      ),
      drawer: const LeftDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: incomeData.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: incomeData.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Income Source
                                Text(
                                  incomeData[index]['income_source'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Center Name
                                Text(
                                  "Center: ${incomeData[index]['center_name']}",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Community Name
                                Text(
                                  "Community: ${incomeData[index]['community_name']}",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 8),

                                // Date (updated_at) and User Name
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Updated at:",
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        Text(
                                          incomeData[index]['updated_at']
                                              .split('T')[0], // Date part
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Created by:",
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        Text(
                                          "${incomeData[index]['user_first_name']} ${incomeData[index]['user_last_name']}",
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),

                                // Status
                                Row(
                                  children: [
                                    const Spacer(),
                                    Text(
                                      "amount: ${incomeData[index]['calculated_amount']}",
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Amount displayed at the top right corner ONLY for the first card
                          if (index == 0)
                            Positioned(
                              top: 40,
                              right: 16,
                              child: AnimatedBuilder(
                                animation: _controller,
                                builder: (context, child) {
                                  return Opacity(
                                    opacity: _controller.value,
                                    child: Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        "$amount RWF",
                                        style: TextStyle(
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
