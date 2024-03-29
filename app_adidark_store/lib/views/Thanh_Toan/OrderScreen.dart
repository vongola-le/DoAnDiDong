import 'dart:math';

import 'package:app_adidark_store/items/ItemLocalNotification.dart';
import 'package:app_adidark_store/models/ClassCartUser.dart';
import 'package:app_adidark_store/models/DataCartUser.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../items/BottomMenu.dart';
import '../../items/ItemProOrder.dart';
import '../../models/ClassAddress.dart';
import 'OrderAddressScreen.dart';
import 'PaymentMethodsScreen.dart';
import '../../models/DataInvoice.dart';
import '../../models/DataProduct.dart';
import '../../models/ClassUser.dart';
import '../../models/DataProduct.dart';
import '../../models/DataNotification..dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderScreen extends StatefulWidget {
  OrderScreen(
      {super.key, required this.address, required this.payMethod, this.carts});
  Address address;
  bool payMethod;
  List<CartUser>? carts;

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  _request() async {
    await NotificationAPI.requestPermissionLocalNotification();
  }

  Future<void> showNotifi(String? title, String? body) async {
    Random random = Random();
    int id = random.nextInt(100000);
    NotificationAPI.showNotification(id: id, body: body, title: title);
  }

  @override
  void initState() {
    _request();
    super.initState();
    controller =
        AnimationController(duration: const Duration(seconds: 3), vsync: this);
    controller.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        Navigator.pop(context);
        controller.reset();
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  static Future<void> updateAllCartItemsStatus(
      List<CartUser> cartItems, String acc) async {
    for (var cartItem in cartItems) {
      cartItem.status = 0;
      await DataCartUser.updateData(cartItem, acc);
    }
  }

  void updateProduct(List<CartUser> cartItems) {
    for (var cartItem in cartItems) {
      DataProduct().updateQuantityPro(
          cartItem.idPro, cartItem.color, cartItem.size, cartItem.quantity);
    }
  }

  DateTime now = DateTime.now();
  late String Oderday = '${now.day}/${now.month}/${now.year}';
  User? user = FirebaseAuth.instance.currentUser;
  var result;
  double total = 0;
  @override
  Widget build(BuildContext context) {
    total = 0;
    for (var element in widget.carts!) {
      total += element.quantity * element.price;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Thanh toán"),
      ),
      body: SingleChildScrollView(
          child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Chi tiết sản phẩm",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const Padding(padding: EdgeInsets.only(bottom: 10)),
                    //Danh sách đơn hàng
                    for (var i = 0; i < widget.carts!.length; i++)
                      ItemProOrder(cart: widget.carts![i]),
                    const Padding(padding: EdgeInsets.only(bottom: 10)),
                    const Text(
                      "Địa chỉ nhận hàng",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const Padding(padding: EdgeInsets.only(bottom: 10)),
                    Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset:
                                  Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width / 1.5,
                              child: Text(
                                widget.address!.detail,
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                            IconButton(
                                onPressed: () async {
                                  result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              OrderAddressScreen(
                                                address: widget.address,
                                              )));
                                  // ignore: avoid_print
                                  setState(() {
                                    if (result != null) {
                                      widget.address = result;
                                    }
                                  });
                                  // print(result);
                                },
                                icon: const Icon(
                                  Icons.mode_edit_outlined,
                                  color: Color.fromARGB(255, 114, 233, 249),
                                ))
                          ],
                        )),
                    const Padding(padding: EdgeInsets.only(bottom: 10)),
                    const Text(
                      "Phương thức thanh toán",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const Padding(padding: EdgeInsets.only(bottom: 10)),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(widget.payMethod!
                                  ? Icons.credit_card
                                  : Icons.attach_money_outlined),
                              const Padding(padding: EdgeInsets.only(right: 8)),
                              Text(
                                widget.payMethod!
                                    ? "Thẻ tín dụng/Ghi nợ"
                                    : "Thanh toán khi nhận hàng",
                                style: TextStyle(
                                  fontSize: 15,
                                ),
                                textAlign: TextAlign.center,
                              )
                            ],
                          ),
                          IconButton(
                              onPressed: () async {
                                result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            PaymentMethodsScreen(
                                              payMethod: widget.payMethod,
                                            )));
                                // ignore: avoid_print
                                setState(() {
                                  if (result != null) {
                                    widget.payMethod =
                                        bool.parse(result.toString());
                                  }
                                });
                              },
                              icon: const Icon(
                                Icons.mode_edit_outlined,
                                color: Color.fromARGB(255, 114, 233, 249),
                              ))
                        ],
                      ),
                    ),
                    const Padding(padding: EdgeInsets.only(bottom: 10)),
                    const Text(
                      "Chi tiết thanh toán",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Tổng tiền hàng: ",
                            style: TextStyle(
                              fontSize: 16,
                            )),
                        Text("$total VND",
                            style: TextStyle(
                              fontSize: 16,
                            ))
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Tổng phí vận chuyển: ",
                            style: TextStyle(
                              fontSize: 16,
                            )),
                        Text("${25000} VND",
                            style: TextStyle(
                              fontSize: 16,
                            ))
                      ],
                    ),
                    const Padding(padding: EdgeInsets.only(bottom: 5)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Tổng thanh toán: ",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text("${total + 25000} VND",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold))
                      ],
                    ),
                    const Padding(padding: EdgeInsets.only(bottom: 50)),
                  ]))),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
            border: Border(top: BorderSide(width: 4, color: Colors.grey))),
        height: 70,
        width: MediaQuery.of(context).size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("Tổng thanh toán",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text("${total + 25000} VND",
                    style: TextStyle(fontSize: 18, color: Colors.red))
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(right: 10),
            ),
            GestureDetector(
              onTap: () async {
                int getnewid = await DataInvoice().getNewId(user!.uid);
                int getmaxid = await DataInvoice().getMaxId(user!.uid);
                await showDoneDialog();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BottomMenu(),
                  ),
                );
                DataInvoice().addInvoice(
                    "Chờ xác nhận",
                    getnewid,
                    user!.uid,
                    Oderday,
                    Oderday,
                    total,
                    widget.address!.detail,
                    widget.carts ?? List.empty());
                showNotifi("Trạng thái hóa đơn",
                    "Đơn hàng $getmaxid đã được đặt thành công");

                DataNotification().addNoiticationPrivate(
                    "Bạn đã đặt hàng thành công MHĐ: ${getmaxid}",
                    await DataNotification().getNewId(user!.uid),
                    user!.uid,
                    Oderday,
                    getmaxid);
                print(await DataInvoice().getMaxId(user!.uid));
                print(user!.uid);
                updateAllCartItemsStatus(
                    widget.carts ?? List.empty(), user!.uid);

                updateProduct(widget.carts ?? List.empty());
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 103, 183, 248)),
                width: 150,
                child: Text(
                  "ĐẶT HÀNG",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> showDoneDialog() async {
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/animations/login_successly.json',
              repeat: false,
              controller: controller,
              onLoaded: (composition) {
                controller.duration = composition.duration;
                controller.forward();
              },
            ),
            Text(
              "Đặt hàng thành công",
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}
