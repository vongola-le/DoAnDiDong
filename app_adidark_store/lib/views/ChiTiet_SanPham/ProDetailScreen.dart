import 'dart:math';

import 'package:app_adidark_store/items/BottomMenu.dart';
import 'package:app_adidark_store/items/ItemImgPro.dart';
import 'package:app_adidark_store/items/ItemLocalNotification.dart';
import 'package:app_adidark_store/models/ClassCartUser.dart';
import 'package:app_adidark_store/models/ClassCategories.dart';
import 'package:app_adidark_store/models/ClassManufacturer.dart';
import 'package:app_adidark_store/models/ClassProduct.dart';
import 'package:app_adidark_store/models/DataCartUser.dart';
import 'package:app_adidark_store/models/DataProduct.dart';
import 'package:app_adidark_store/views/Thanh_Toan/OrderAddressScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../items/ItemSelectedColor.dart';
import '../../items/ItemSelectedSize.dart';
import '../../items/TextWrapper.dart';

class ProDetailScreen extends StatefulWidget {
  const ProDetailScreen({super.key, this.idPro = 0});
  final int idPro;

  @override
  State<ProDetailScreen> createState() => _ProDetailScreenState();
}

class _ProDetailScreenState extends State<ProDetailScreen> {
  var snackBarSucc = const SnackBar(
    content: Text('Đã thêm vào giỏ hàng!'),
  );
  var snackBarFail = const SnackBar(
    backgroundColor: Color.fromARGB(255, 230, 117, 108),
    content: Text('Vui lòng chọn số lượng, màu và size giày!'),
  );
  int sttbuy = 0;
  int slSize = 13;
  String s =
      "dadadadadadadadadadadadadadadadadadadadadadadadadadadadadadadadadadadadadadadadadadada";
  bool isReadMore = false;
  String seledtedColorId = "";
  int seledtedSizeId = -1;

  int maxQuan = -1;

  List<CartUser> allCart = [];

  Product pro = Product(
      cate: Categories(id: -1, name: "", status: false),
      detail: Map(),
      id: -1,
      img: List.empty(),
      manu: Manufacturer(id: -1, name: "", status: false),
      name: "",
      price: 0,
      quantity: 0,
      status: 0,
      infor: "");

  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoggedIn = false;

  void checkLoginStatus() {
    _auth.authStateChanges().listen((user) {
      setState(() {
        isLoggedIn = (user != null);
      });
    });
  }

  _getData() async {
    Product product = await DataProduct.getDataById(widget.idPro);
    if (mounted) {
      setState(() {
        pro = product;
        if (seledtedColorId == "" || seledtedSizeId == -1) {
          maxQuan = pro.quantity;
        } else {
          for (var element in pro.detail[seledtedColorId]!) {
            if (maxQuan > element.quantity && element.size == seledtedSizeId) {
              maxQuan = element.quantity;
            }
          }
        }
      });
    }
  }

  _updateOrCreateCart() async {
    ///--Cần thay đổi bằng tên tài khoản người dùng-----------------
    User? user = FirebaseAuth.instance.currentUser;
    List<CartUser> allCart = await DataCartUser.getData(user!.uid);
    int newIdCart = await DataCartUser.getNewId(user.uid);
    setState(() {
      bool flag = true;
      for (var element in allCart) {
        if (element.idPro == pro.id &&
            element.size == seledtedSizeId &&
            element.color == seledtedColorId) {
          element.quantity += sttbuy;
          //-------Cần thay đổi bằng tên người dùng------------------------------------
          DataCartUser.updateData(element, user.uid);
          flag = false;
          break;
        }
      }
      if (flag) {
        //-------Cần thay đổi bằng tên người dùng------------------------------------
        CartUser newCart = CartUser(
            color: seledtedColorId,
            id: newIdCart,
            img: pro.img[0].link,
            manufucturer: pro.manu.name,
            quantity: sttbuy,
            size: seledtedSizeId,
            namePro: pro.name,
            idPro: pro.id,
            price: pro.price,
            cate: pro.cate.name,
            status: 1);
        DataCartUser.CreateData(newCart, user.uid);
      }
    });
  }

  _buyPro() async {
    User? user = FirebaseAuth.instance.currentUser;
    int newIdCart = await DataCartUser.getNewId(user!.uid);
    List<CartUser> carts = [
      CartUser(
          color: seledtedColorId,
          id: newIdCart,
          img: pro.img[0].link,
          manufucturer: pro.manu.name,
          quantity: sttbuy,
          size: seledtedSizeId,
          namePro: pro.name,
          idPro: pro.id,
          price: pro.price,
          cate: pro.cate.name,
          status: 1),
    ];
    // ignore: use_build_context_synchronously
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OrderAddressScreen(carts: carts),
        ));
  }

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
    _getData();
    _request();
    checkLoginStatus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 5), () {
      _getData();
    });
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text(
            "Chi tiết sản phẩm",
            style: TextStyle(fontWeight: FontWeight.w800, color: Colors.black),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              CarouselSlider(
                  options: CarouselOptions(
                    viewportFraction: 0.9,
                    initialPage: 0,
                    enableInfiniteScroll: true,
                    reverse: false,
                    scrollDirection: Axis.horizontal,
                  ),
                  items: [
                    for (var i = 0; i < pro.img.length; i++)
                      ItemImgPro(linkImg: pro.img[i].link)
                  ]),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //Tên
                      Text(
                        pro.name,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w800),
                      ),
                      //Hãng, loại
                      Text("${pro.manu.name} | Giày ${pro.cate.name}",
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w500)),
                      Row(
                        children: [
                          Row(
                            children: [
                              //Số sao
                              for (var i = 0; i <= 4; i++)
                                Icon(
                                  Icons.star,
                                  color: Colors.yellow,
                                )
                            ],
                          ),
                          //Số review
                          Text("(100k Reviews)", style: TextStyle(fontSize: 15))
                        ],
                      ),
                      //Giá tiền, số lượng chọn
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          //Số tiền sản phẩm
                          Text(
                            pro.price.toString(),
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  if (sttbuy > 0) {
                                    setState(() {
                                      if (sttbuy > 0) {
                                        sttbuy--;
                                      }
                                    });
                                  }
                                },
                                child: Container(
                                  height: 30,
                                  width: 30,
                                  alignment: Alignment.center,
                                  decoration: const BoxDecoration(
                                      color: Color.fromARGB(255, 241, 240, 240),
                                      shape: BoxShape.circle),
                                  child: const Icon(
                                    Icons.remove,
                                    size: 15,
                                  ),
                                ),
                              ),
                              const Padding(padding: EdgeInsets.only(right: 5)),
                              Text(sttbuy < 10 ? "0$sttbuy" : "$sttbuy",
                                  style: TextStyle(fontSize: 17)),
                              const Padding(padding: EdgeInsets.only(left: 5)),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (maxQuan > sttbuy) {
                                      sttbuy++;
                                    }
                                  });
                                },
                                child: Container(
                                  height: 30,
                                  width: 30,
                                  alignment: Alignment.center,
                                  decoration: const BoxDecoration(
                                      color: Color.fromARGB(255, 241, 240, 240),
                                      shape: BoxShape.circle),
                                  child: const Icon(
                                    Icons.add,
                                    size: 15,
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      const Padding(padding: EdgeInsets.only(top: 15)),
                      const Divider(
                        color: Colors.black,
                        height: 2,
                      ),

                      //Thông tin sản phẩm
                      TextWrapper(text: pro.infor),

                      const Padding(padding: EdgeInsets.only(bottom: 10)),
                      const Divider(
                        color: Colors.black,
                        height: 2,
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Colors",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w800)),
                          Text(
                            "Số lượng: $maxQuan",
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          )
                        ],
                      ),
                      //Chọn màu

                      Column(
                        children: [
                          //Số lượng màu
                          if (pro.detail.length < 6)
                            Row(
                              children: [
                                for (int i = 0; i < pro.detail.length; i++)
                                  ItemSelectedColor(
                                    idColor: pro.detail.keys.elementAt(i),
                                    idSelected: seledtedColorId,
                                    selected: () {
                                      setState(() {
                                        if (seledtedColorId ==
                                            pro.detail.keys.elementAt(i)) {
                                          seledtedColorId = "";
                                          seledtedSizeId = -1;
                                        } else {
                                          seledtedColorId =
                                              pro.detail.keys.elementAt(i);
                                          seledtedSizeId = -1;
                                        }
                                      });
                                    },
                                  )
                              ],
                            )
                          else
                            Row(
                              children: [
                                for (int i = 0; i < 6; i++)
                                  ItemSelectedColor(
                                    idColor: pro.detail.keys.elementAt(i),
                                    idSelected: seledtedColorId,
                                    selected: () {
                                      if (seledtedColorId ==
                                          pro.detail.keys.elementAt(i)) {
                                        setState(() {
                                          seledtedColorId = "";
                                          seledtedSizeId = -1;
                                        });
                                      } else {
                                        setState(() {
                                          seledtedColorId =
                                              pro.detail.keys.elementAt(i);
                                          seledtedSizeId = -1;
                                        });
                                      }
                                    },
                                  )
                              ],
                            ),
                          Row(
                            children: [
                              for (int i = 6; i < pro.detail.length; i++)
                                ItemSelectedColor(
                                  idColor: pro.detail.keys.elementAt(i),
                                  idSelected: seledtedColorId,
                                  selected: () {
                                    if (seledtedColorId ==
                                        pro.detail.keys.elementAt(i)) {
                                      setState(() {
                                        seledtedColorId = "";
                                        seledtedSizeId = -1;
                                      });
                                    } else {
                                      setState(() {
                                        seledtedColorId =
                                            pro.detail.keys.elementAt(i);
                                        seledtedSizeId = -1;
                                      });
                                    }
                                  },
                                )
                            ],
                          )
                        ],
                      ),

                      Text("Size",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w800)),

                      Column(
                        children: [
                          //Số lượng Size
                          for (var i = 0;
                              i <
                                  (seledtedColorId != ""
                                          ? pro.detail[seledtedColorId]!.length
                                          : slSize) /
                                      6.ceil();
                              i++)
                            Row(
                              children: [
                                for (var j = i * 6;
                                    j < i * 6 + 6 &&
                                        j <
                                            (seledtedColorId != ""
                                                ? pro.detail[seledtedColorId]!
                                                    .length
                                                : slSize);
                                    j++)
                                  ItemSelectedSize(
                                    idSize: (seledtedColorId != ""
                                        ? pro.detail[seledtedColorId]![j].size
                                        : j + 30),
                                    idSelected: seledtedSizeId,
                                    selected: () {
                                      if (seledtedSizeId ==
                                          (seledtedColorId != ""
                                              ? pro.detail[seledtedColorId]![j]
                                                  .size
                                              : j + 30)) {
                                        setState(() {
                                          seledtedSizeId = -1;
                                          maxQuan = pro.quantity;
                                        });
                                      } else {
                                        setState(() {
                                          seledtedSizeId = seledtedColorId != ""
                                              ? pro.detail[seledtedColorId]![j]
                                                  .size
                                              : j + 30;
                                          maxQuan = seledtedColorId != ""
                                              ? pro.detail[seledtedColorId]![j]
                                                  .quantity
                                              : pro.quantity;
                                          if (sttbuy > maxQuan) {
                                            sttbuy = maxQuan;
                                          }
                                        });
                                      }
                                    },
                                  )
                              ],
                            )
                        ],
                      ),
                    ]),
              )
            ],
          ),
        ),
        bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Padding(
              padding: EdgeInsets.only(top: 10.0, bottom: 10),
              child: Row(
                children: [
                  if (isLoggedIn)
                    if (pro.quantity > 0)
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (seledtedColorId == "" ||
                                    seledtedSizeId == -1 ||
                                    sttbuy <= 0) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBarFail);
                                } else {
                                  _buyPro();
                                }
                              },
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: seledtedColorId == "" ||
                                            seledtedSizeId == -1 ||
                                            sttbuy <= 0
                                        ? Colors.grey
                                        : const Color(0xFFADDDFF)),
                                height: 50,
                                width: 200,
                                child: const Text(
                                  "MUA NGAY",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                if (seledtedColorId == "" ||
                                    seledtedSizeId == -1 ||
                                    sttbuy <= 0) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBarFail);
                                } else {
                                  _updateOrCreateCart();
                                  showNotifi(
                                      "Bạn vừa thêm sản phẩm mới vào giỏ hàng",
                                      "Tên: ${pro.name}, ${seledtedColorId == "a" ? "Màu: Đen" : seledtedColorId == "b" ? "Màu: Trắng" : seledtedColorId == "c" ? "Màu: Vàng" : seledtedColorId == "d" ? "Màu: Xanh dương" : seledtedColorId == "e" ? "Màu: Xám" : seledtedColorId == "f" ? "Màu: Nâu" : seledtedColorId == "g" ? "Màu: Cam" : seledtedColorId == "h" ? "Màu: Tím" : seledtedColorId == "j" ? "Màu: Xanh lá" : "Màu: Hồng"} ,Size: $seledtedSizeId, Số lượng: $sttbuy, Giá:${sttbuy * pro.price}");
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBarSucc);
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: seledtedColorId == "" ||
                                            seledtedSizeId == -1 ||
                                            sttbuy <= 0
                                        ? Colors.grey
                                        : const Color(0xFFADDDFF)),
                                height: 50,
                                width: 120,
                                child: const Icon(
                                  Icons.shopping_cart,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    else
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 50,
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.red),
                          height: 50,
                          width: 200,
                          child: const Text(
                            "HẾT HÀNG",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                  else
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const BottomMenu(pageindex: 3),
                            ));
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 50,
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          padding: EdgeInsets.all(5),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: const Color(0xFFADDDFF)),
                          height: 60,
                          width: MediaQuery.of(context).size.width - 30,
                          child: const Text(
                            "ĐĂNG NHẬP HOẶC ĐĂNG KÝ ĐỂ TIẾP TỤC",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    )
                ],
              ),
            )));
  }
}
