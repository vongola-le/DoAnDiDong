import 'package:app_adidark_store/models/ClassProduct.dart';
import 'package:app_adidark_store/models/ClassUser.dart';
import 'package:app_adidark_store/models/DataNotification..dart';
import 'package:app_adidark_store/models/DataProduct.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountSetting extends StatefulWidget {
  const AccountSetting({super.key});

  @override
  State<AccountSetting> createState() => _AccountSettingState();
}

class _AccountSettingState extends State<AccountSetting> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  late String email;
  late String fullName;
  late String password;
  late String address;

  Users user = Users(fullName: "", email: "", password: "",  address: {
      "home": null,
      "company": null,
      "etc": null,
    },);

  final _user = FirebaseAuth.instance.currentUser;

  final CollectionReference users =
      FirebaseFirestore.instance.collection('Users');

  Future<void> updateUser(var key, var value) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setString(key, value);
    if (key != "Password")
      var update = users
          .doc(_user?.uid)
          .update({key: value})
          .then((value) => print("User Updated"))
          .catchError((error) => print("Failed to update user: $error"));
  }

  Future<void> changeEmail(String newEmail) async {
    try {
      // Thay đổi email của người dùng
      await _user!.updateEmail(newEmail);

      print('Email changed successfully to: ${_user?.email}');
    } catch (error) {
      print('Failed to change email: $error');
    }
  }

  Future<void> changePassword(String newPass) async {
    try {
      // Thay đổi email của người dùng
      await _user!.updatePassword(newPass);

      print('Password changed successfully to: ${user.password}');
    } catch (error) {
      print('Failed to change email: $error');
    }
  }

  Future<void> getUserDetailInfo() async {
    final SharedPreferences prefs = await _prefs;
    DocumentReference<Map<String, dynamic>> documentReference =
        FirebaseFirestore.instance.collection("Users").doc(_user?.uid);

    try {
      // Lấy dữ liệu từ Firestore
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await documentReference.get();

      // Đảm bảo rằng tài liệu tồn tại và có dữ liệu
      if (documentSnapshot.exists) {
        // Lấy tất cả các trường (fields) từ tài liệu
        Map<String, dynamic> documentData = documentSnapshot.data()!;

        documentData.forEach((key, value) async {
          await prefs.setString(key, value);
        });
      } else {
        print('Document does not exist');
      }
    } catch (e) {
      print('Error getting document fields: $e');
    }

    email = prefs.getString("Email") ?? "";
    fullName = prefs.getString("FullName") ?? "";
    password = prefs.getString("Password") ?? "";
    address = prefs.getString("Address") ?? "";

    user = Users(
      fullName: fullName,
      email: email,
      password: password,
       address: {
      "home": null,
      "company": null,
      "etc": null,
    },
    );
  }

  void _modelBottomSheetMenu(int stt) {
    TextEditingController txtName = TextEditingController(text: "");
    TextEditingController txtEmail = TextEditingController(text: "");
    TextEditingController txtCurPass = TextEditingController(text: "");
    TextEditingController txtNewPass = TextEditingController(text: "");
    TextEditingController txtAddress = TextEditingController(text: "");

    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Column(
            children: [
              if (stt == 1)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      TextField(
                        controller: txtName,
                        decoration: InputDecoration(
                          hintText: "Nhập tên người dùng",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              updateUser("FullName", txtName.text.trim());
                              user.fullName = fullName;
                              Navigator.pop(context);
                            });
                          },
                          child: Text(
                            "Xác nhận",
                            style: TextStyle(color: Colors.black),
                          ),
                          style: ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll(
                                  Color.fromRGBO(203, 233, 255, 1))),
                        ),
                      ),
                    ],
                  ),
                ),
              if (stt == 2)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      TextField(
                        controller: txtEmail,
                        decoration: InputDecoration(
                          hintText: "Nhập email",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              changeEmail(txtEmail.text.trim());
                              updateUser("Email", _user?.email);
                              user.email = email;
                              Navigator.pop(context);
                            });
                          },
                          child: Text(
                            "Xác nhận",
                            style: TextStyle(color: Colors.black),
                          ),
                          style: ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll(
                                  Color.fromRGBO(203, 233, 255, 1))),
                        ),
                      ),
                    ],
                  ),
                ),
              if (stt == 3)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      TextField(
                        controller: txtCurPass,
                        decoration: InputDecoration(
                          hintText: "Nhập mật khẩu hiện tại",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        obscureText: true,
                      ),
                      Padding(padding: const EdgeInsets.all(5)),
                      TextField(
                        controller: txtNewPass,
                        decoration: InputDecoration(
                          hintText: "Nhập mật khẩu mới",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        obscureText: true,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ElevatedButton(
                          onPressed: () {
                            if (txtCurPass.text.trim() == password)
                              setState(() {
                                changePassword(txtNewPass.text.trim());
                                updateUser("Password", txtNewPass.text.trim());
                                user.password = password;
                                Navigator.pop(context);
                              });
                          },
                          child: Text(
                            "Xác nhận",
                            style: TextStyle(color: Colors.black),
                          ),
                          style: ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll(
                                  Color.fromRGBO(203, 233, 255, 1))),
                        ),
                      ),
                    ],
                  ),
                ),
              if (stt == 4)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      TextField(
                        controller: txtAddress,
                        decoration: InputDecoration(
                          hintText: user.address?["Home"],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              updateUser("Address", txtAddress.text.trim());
                              user.address = user.address?["Home"];
                              Navigator.pop(context);
                            });
                          },
                          child: Text(
                            "Xác nhận",
                            style: TextStyle(color: Colors.black),
                          ),
                          style: ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll(
                                  Color.fromRGBO(203, 233, 255, 1))),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        });
  }

  DatabaseReference _database = FirebaseDatabase.instance.ref();
  List<Product> pros = [];

  _getData() async {
    List<Product> pros2 = await DataProduct.getAllData();
    setState(() {
      pros = pros2;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseFirestore.instance
        .collection("Users")
        .doc(_user?.uid)
        .snapshots()
        .listen((event) {
      setState(() {
        getUserDetailInfo();
      });
    });

    _database.child('Products').onChildAdded.listen((event) {
      setState(() {
        _getData();

        DataNotification.createMainData(pros.last);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Cài đặt thông tin",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Tên người dùng",
                          style: TextStyle(fontSize: 20),
                        ),
                        FutureBuilder(
                          future: getUserDetailInfo(),
                          builder: (BuildContext context,
                              AsyncSnapshot<void> snapshot) {
                            switch (snapshot.connectionState) {
                              case ConnectionState.none:
                              case ConnectionState.waiting:
                                return const CircularProgressIndicator();
                              case ConnectionState.active:
                              case ConnectionState.done:
                                if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  return Row(
                                    children: [
                                      Text(
                                        user.fullName ?? "",
                                        style: TextStyle(fontSize: 20),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: GestureDetector(
                                          onTap: () {
                                            _modelBottomSheetMenu(1);
                                          },
                                          child: Icon(Icons.edit_outlined),
                                        ),
                                      )
                                    ],
                                  );
                                }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                    child: const Divider(
                      height: 1,
                      color: Colors.grey,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Email",
                          style: TextStyle(fontSize: 20),
                        ),
                        FutureBuilder(
                          future: getUserDetailInfo(),
                          builder: (BuildContext context,
                              AsyncSnapshot<void> snapshot) {
                            switch (snapshot.connectionState) {
                              case ConnectionState.none:
                              case ConnectionState.waiting:
                                return const CircularProgressIndicator();
                              case ConnectionState.active:
                              case ConnectionState.done:
                                if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  return Row(
                                    children: [
                                      Text(
                                        user.email.replaceRange(
                                            1,
                                            user.email.lastIndexOf("@"),
                                            "*****"),
                                        style: TextStyle(fontSize: 20),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: GestureDetector(
                                          onTap: () {
                                            _modelBottomSheetMenu(2);
                                          },
                                          child: Icon(Icons.edit_outlined),
                                        ),
                                      )
                                    ],
                                  );
                                }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                    child: const Divider(
                      height: 1,
                      color: Colors.grey,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Đổi mật khẩu",
                          style: TextStyle(fontSize: 20),
                        ),
                        FutureBuilder(
                          future: getUserDetailInfo(),
                          builder: (BuildContext context,
                              AsyncSnapshot<void> snapshot) {
                            switch (snapshot.connectionState) {
                              case ConnectionState.none:
                              case ConnectionState.waiting:
                                return const CircularProgressIndicator();
                              case ConnectionState.active:
                              case ConnectionState.done:
                                if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  return Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        _modelBottomSheetMenu(3);
                                      },
                                      child: Icon(Icons.edit_outlined),
                                    ),
                                  );
                                }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                    child: const Divider(
                      height: 1,
                      color: Colors.grey,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Đổi địa chỉ",
                          style: TextStyle(fontSize: 20),
                        ),
                        FutureBuilder(
                          future: getUserDetailInfo(),
                          builder: (BuildContext context,
                              AsyncSnapshot<void> snapshot) {
                            switch (snapshot.connectionState) {
                              case ConnectionState.none:
                              case ConnectionState.waiting:
                                return const CircularProgressIndicator();
                              case ConnectionState.active:
                              case ConnectionState.done:
                                if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  return Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        _modelBottomSheetMenu(4);
                                      },
                                      child: Icon(Icons.edit_outlined),
                                    ),
                                  );
                                }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                    child: const Divider(
                      height: 1,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
