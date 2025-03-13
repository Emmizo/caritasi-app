import 'dart:convert';

import 'package:cartasiapp/core/api_client.dart';
import 'package:cartasiapp/pages/forgot_password.dart';
import 'package:cartasiapp/pages/home.dart';
import 'package:cartasiapp/provider/login_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late Future<String> accessToken;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();
    loginUsers();
    prefsData();
  }

  prefsData() {
    _prefs.then((SharedPreferences prefs) {
      String? userData = prefs.getString('userData');

      if (userData != null && userData.isNotEmpty) {
        try {
          List<dynamic> userDataMap = jsonDecode(userData);
          String? accessToken = userDataMap[0]['token'];

          // print("Data token: $userDataMap");

          if (accessToken != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Home(),
              ),
            );
          }
        } catch (e) {
          // Handle the decoding error appropriately
        }
      }
    });
  }

  // Future<void> loggedIn() async {}
  Future<void> loginUsers() async {
    if (_formKey.currentState!.validate()) {
      //show snackbar to indicate loading
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Center(child: Text('Processing Data')),
        backgroundColor: Colors.green.shade300,
      ));

      ApiClient apiClient = ApiClient();
      dynamic res = await apiClient.login(
        emailController.text,
        passwordController.text,
      );
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      //if there is no error, get the user's accesstoken and pass it to HomeScreen
      print("$res[0] new");

      if (res[0]['status'] == 200) {
        res is List;

        // print(res[0]['user']);
        // print(res[0]['token']);
        if (res != null) {
          String accessToken = res[0]['token'];
          await context.read<LoginData>().setUserInfo(accessToken);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const Home(),
            ),
          );
        }
      } else {
        //if an error occurs, show snackbar with error message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Center(child: Text(res[0]['message'])),
          backgroundColor: Colors.red.shade300,
        ));
      }
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email';
    }
    // Regular expression for basic email validation
    final RegExp emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Login'),
      ),
      body: Form(
        key: _formKey,
        child: SizedBox(
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              children: [
                const Center(
                  child: Image(
                    image: AssetImage('assets/logo.png'),
                    width: 150,
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  "Welcome to",
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "NYUNDO PARISH",
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.normal),
                ),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Email',
                  ),
                  validator: _validateEmail,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  obscureText: true,
                  controller: passwordController,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'password',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter password';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 3, 63, 113)),
                    onPressed: loginUsers,
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                    // height: 20,
                    ),
                SizedBox(
                  height: 50,
                  child: Center(
                    child: Row(
                      children: [
                        const Text("forgot password?"),
                        const SizedBox(width: 10),
                        GestureDetector(
                            child: const Text(
                              "click here",
                              style: TextStyle(color: Colors.blue),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const ForgotPassword()),
                              );
                            })
                      ],
                    ),
                  ),
                ),
                const Divider(
                  color: Colors.grey,
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 30),
                  child: Text(
                    "Is this your first time here?",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Text(
                  "For full access to this site, you first need to contact admin",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
