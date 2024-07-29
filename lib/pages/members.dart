import 'dart:convert';

import 'package:cartasiapp/core/api_client.dart';
import 'package:cartasiapp/widget/bottom_navigator.dart';
import 'package:cartasiapp/widget/header.dart';
import 'package:cartasiapp/widget/left_drawer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Members extends StatefulWidget {
  const Members({super.key});

  @override
  State<Members> createState() => _MembersState();
}

class _MembersState extends State<Members> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  int role = 0;
  int _selectedIndex = 1;
  List<dynamic> membersData = [];
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    listOfMember();
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
    // print(" hello ${_selectedIndex}");
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
            children: membersData.map((member) {
              return Column(
                children: [
                  MemberCard(
                    id: member['memberId'],
                    title: '${member['first_name']} ${member['last_name']}',
                    service: member['description'] ?? 'No description',
                    date: 'Date of Birth: ${member['birth_day']}',
                    time: 'Phone: ${member['phone']}',
                    approval: member['status'] == 0
                        ? "Wait"
                        : member['status'] == 1
                            ? "Approved"
                            : "Rejected",
                    author:
                        '${member['user_first_name']} ${member['user_last_name']}',
                    role: role,
                  ),
                  const SizedBox(height: 8),
                ],
              );
            }).toList(),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigator(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
      floatingActionButton: role == 2
          ? FloatingActionButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: AddMemberForm(onFormSubmitted: listOfMember),
                    );
                  },
                );
              },
              child: Icon(Icons.add),
            )
          : Container(),
    );
  }
}

class MemberCard extends StatefulWidget {
  final int id;
  final String title;
  final String service;
  final String date;
  final String time;
  final String approval;
  final String author;
  final VoidCallback? onShowFormModal;
  final Function? onFormSubmitted;
  final int role;
  const MemberCard({
    super.key,
    required this.id,
    required this.title,
    required this.service,
    required this.date,
    required this.time,
    required this.approval,
    this.onShowFormModal,
    this.onFormSubmitted,
    required this.author,
    required this.role,
  });
  @override
  _MemberCardState createState() => _MemberCardState();
}

class _MemberCardState extends State<MemberCard> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  int status = 0;

  @override
  Widget build(BuildContext context) {
    void _showAlertDialog(String title, String message, bool isSuccess) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                  if (isSuccess) {
                    Navigator.of(context).pop(); // Close the form page
                    // widget.onFormSubmitted();
                  }
                },
              ),
            ],
          );
        },
      );
    }

    void _submitForm2() async {
      final SharedPreferences prefs = await _prefs;
      String? userData = prefs.getString('userData');
      List<dynamic> userDataListDynamic = jsonDecode(userData!);
      List<Map<String, dynamic>> userDataList = List<Map<String, dynamic>>.from(
          userDataListDynamic.map((item) => item as Map<String, dynamic>));

      String token = userDataList[0]['token'];

      int memberId = widget.id;
      // print("status ${status} and member ${memberId}");
      ApiClient apiClient = ApiClient();
      dynamic res = await apiClient.approveMember(
        memberId,
        status,
        token,
      );

      if (res['status'] == 200) {
        print(res);
        _showAlertDialog(
            'Success', "${widget.title} wishes ${res["msg"]}", true);
      } else {
        _showAlertDialog(
            'Error', "${widget.title} wishes ${res["msg"]}", false);
      }
      print(res);
      Navigator.pop(context);
    }

    void _showAlertDialog3() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Attention"),
            content: Text("Do you want to accept or Decline ${widget.title}?"),
            actions: <Widget>[
              Row(
                children: [
                  TextButton(
                    child: const Text(
                      'Accept',
                      style: TextStyle(color: Colors.green),
                    ),
                    onPressed: () {
                      setState(() {
                        status = 1;
                        //memberId = widget.id;
                      });
                      _submitForm2();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Members()),
                      );
                    },
                  ),
                  const Spacer(),
                  TextButton(
                    child: const Text(
                      'Decline',
                      style: TextStyle(color: Colors.red),
                    ),
                    onPressed: () {
                      setState(() {
                        status = 2;
                        //memberId = widget.id;
                      });
                      _submitForm2();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Members()),
                      );
                      // Navigator.of(context).pop();
                      // if (isSuccess) {
                      //   Navigator.of(context).pop(); // Close the form page
                      //   // widget
                      //   //     .onFormSubmitted(); // Call the callback to refresh data
                      // }
                    },
                  ),
                ],
              ),
            ],
          );
        },
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                widget.role == 3 && widget.approval == "Approved" ||
                        widget.role == 4 && widget.approval == "Approved" ||
                        widget.role == 5 && widget.approval == "Approved"
                    ? ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: FormModal(
                                  name: widget.title,
                                  memberId: widget.id,
                                ),
                              );
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green, // Background color
                        ),
                        child: const Text(
                          'Add support',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    : Container()
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Description',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
              ),
            ),
            Text(
              widget.service,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Date',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      widget.date,
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Time',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      widget.time,
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                GestureDetector(
                  onTap: widget.role == 5 && widget.approval == "Wait"
                      ? _showAlertDialog3
                      : widget.role == 4 && widget.approval == "Wait"
                          ? _showAlertDialog3
                          : widget.role == 3 && widget.approval == "Wait"
                              ? _showAlertDialog3
                              : null,
                  child: Text(
                    widget.approval,
                    style: TextStyle(
                      fontSize: 14,
                      color: widget.approval == "Wait"
                          ? Colors.blue
                          : widget.approval == "Rejected"
                              ? Colors.red
                              : Colors.green,
                    ),
                  ),
                ),
                Text(
                  "Created by: ${widget.author}",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AddMemberForm extends StatefulWidget {
  final Function onFormSubmitted;
  const AddMemberForm({super.key, required this.onFormSubmitted});

  @override
  _AddMemberFormState createState() => _AddMemberFormState();
}

class _AddMemberFormState extends State<AddMemberForm> {
  final _formKey = GlobalKey<FormState>();

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _hospitalController = TextEditingController();
  final _schoolNameController = TextEditingController();
  final _sdmsCodeController = TextEditingController();
  final _otherSupportController = TextEditingController();
  DateTime? _selectedDate;

  List<Category> categories = [];
  int? _selectedCategoryId;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    _hospitalController.dispose();
    _schoolNameController.dispose();
    _sdmsCodeController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    listOfCategory();
  }

  void listOfCategory() async {
    ApiClient apiClient = ApiClient();
    dynamic res = await apiClient.listOfCategory();
    List<dynamic> data = res['data'];
    setState(() {
      categories = data
          .map((item) => Category(item['id'], item['category_name']))
          .toList();
    });
  }

  void _showAlertDialog(String title, String message, bool isSuccess) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                if (isSuccess) {
                  Navigator.of(context).pop(); // Close the form page
                  widget.onFormSubmitted(); // Call the callback to refresh data
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _submitForm() async {
    final SharedPreferences prefs = await _prefs;
    String? userData = prefs.getString('userData');
    List<dynamic> userDataListDynamic = jsonDecode(userData!);
    List<Map<String, dynamic>> userDataList = List<Map<String, dynamic>>.from(
        userDataListDynamic.map((item) => item as Map<String, dynamic>));

    if (_formKey.currentState!.validate()) {
      String firstName = _firstNameController.text;
      String lastName = _lastNameController.text;
      String address = _addressController.text;
      String phone = _phoneController.text;
      String description = _descriptionController.text;
      String birthDate = _selectedDate != null
          ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
          : 'Not set';
      int categoryId = _selectedCategoryId ?? -1;
      // String categoryName =
      //     categories.firstWhere((category) => category.id == categoryId).name;
      String hospital = _hospitalController.text;
      String schoolName = _schoolNameController.text;
      String sdmsCode = _sdmsCodeController.text;
      String otherSupport = _otherSupportController.text;
      String token = userDataList[0]['token'];
      ApiClient apiClient = ApiClient();
      dynamic res = await apiClient.addMember(
        firstName,
        lastName,
        address,
        phone,
        description,
        birthDate,
        categoryId,
        hospital,
        schoolName,
        sdmsCode,
        otherSupport,
        token,
      );
      print(res['status'] == 200);
      if (res['status'] == 200) {
        _showAlertDialog('Success', 'New member added successfully', true);
      } else {
        _showAlertDialog('Error', 'Failed to add new member', false);
      }
      // print(res);
      // Navigator.pop(context);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Manage Members - Add',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(labelText: 'First Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter first name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(labelText: 'Last Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter last name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter address';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<int>(
                value: _selectedCategoryId,
                items: categories.map((Category category) {
                  return DropdownMenuItem<int>(
                    value: category.id,
                    child: Text(category.name),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  setState(() {
                    _selectedCategoryId = newValue;
                  });
                },
                decoration: InputDecoration(labelText: 'Category'),
                validator: (value) {
                  if (value == null) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              if (_selectedCategoryId != null) ...[
                if (_selectedCategoryId ==
                    1) // Assuming 1 is the ID for "Patient"
                  TextFormField(
                    controller: _hospitalController,
                    decoration: InputDecoration(labelText: 'Hospital'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter hospital name';
                      }
                      return null;
                    },
                  ),
                if (_selectedCategoryId ==
                    2) // Assuming 2 is the ID for "Student"
                  Column(
                    children: [
                      TextFormField(
                        controller: _schoolNameController,
                        decoration: InputDecoration(labelText: 'School Name'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter school name';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _sdmsCodeController,
                        decoration: InputDecoration(labelText: 'SDMS Code'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter SDMS code';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                if (_selectedCategoryId == 3)
                  TextFormField(
                    controller: _otherSupportController,
                    decoration:
                        InputDecoration(labelText: 'Explain Other Support'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter other suppport';
                      }
                      return null;
                    },
                  ),
              ],
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Birth Of Date',
                        hintText: 'dd/mm/yyyy',
                      ),
                      onTap: () => _selectDate(context),
                      controller: TextEditingController(
                        text: _selectedDate != null
                            ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                            : '',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select birth date';
                        }
                        return null;
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ],
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text('Save'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FormModal extends StatefulWidget {
  final String name;

  final int? memberId;
  const FormModal({super.key, required this.name, this.memberId});
  @override
  _FormModalState createState() => _FormModalState();
}

class _FormModalState extends State<FormModal> {
  final _formKey = GlobalKey<FormState>();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final _reasonsController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _reasonsController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _showAlertDialog(String title, String message, bool isSuccess) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                if (isSuccess) {
                  Navigator.of(context).pop(); // Close the form page
                  //widget.onFormSubmitted(); // Call the callback to refresh data
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _submitForm2() async {
    final SharedPreferences prefs = await _prefs;
    String? userData = prefs.getString('userData');
    List<dynamic> userDataListDynamic = jsonDecode(userData!);
    List<Map<String, dynamic>> userDataList = List<Map<String, dynamic>>.from(
        userDataListDynamic.map((item) => item as Map<String, dynamic>));

    if (_formKey.currentState!.validate()) {
      String reason = _reasonsController.text;
      String amount = _amountController.text;

      String token = userDataList[0]['token'];
      int memberId = widget.memberId ?? 0;
      ApiClient apiClient = ApiClient();
      dynamic res = await apiClient.addSupport(
        reason,
        amount,
        memberId,
        token,
      );
      print(res['status'] == 201);
      if (res['status'] == 201) {
        _showAlertDialog('Success', 'New support added successfully', true);
      } else {
        _showAlertDialog('Error', 'Failed to add new support', false);
      }
      // print(res);
      // Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16.0,
        right: 16.0,
        top: 16.0,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${widget.name}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _reasonsController,
              decoration: const InputDecoration(
                labelText: 'Reasons',
                border: OutlineInputBorder(),
              ),
              maxLines: null,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a reason';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                hintText: 'Amount in Rwandan Franc',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Close'),
                ),
                ElevatedButton(
                  onPressed: _submitForm2,
                  child: const Text('Save'),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class Category {
  final int id;
  final String name;

  Category(this.id, this.name);
}
