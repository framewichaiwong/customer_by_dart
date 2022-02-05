import 'dart:convert';
import 'dart:io';

import 'package:customer_by_dart/config/config.dart';
import 'package:customer_by_dart/customer/class/class_order.dart';
import 'package:customer_by_dart/customer/class/class_user_manager.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class PayByTransfer extends StatefulWidget {
  UserManager userManager;
  int numberTable;
  List<ListOrder> listOrderByCheckStatusForShowTotalPrice;
  PayByTransfer(this.userManager,this.numberTable,this.listOrderByCheckStatusForShowTotalPrice);

  @override
  _PayByTransfer createState() => _PayByTransfer(userManager,numberTable,listOrderByCheckStatusForShowTotalPrice);
}

class _PayByTransfer extends State<PayByTransfer> {
  UserManager userManager;
  int numberTable;
  List<ListOrder> listOrderByCheckStatusForShowTotalPrice;
  _PayByTransfer(this.userManager,this.numberTable,this.listOrderByCheckStatusForShowTotalPrice);

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  /// Parameter.
  File? _image;
  String? _nameTransfer;
  String? _telTransfer;
  int? _managerId;
  int? _numberTable;
  int? _priceTotal;

  @override
  void initState() {
    super.initState();
    _managerId = userManager.managerId;
    _numberTable = numberTable;
    _priceTotal = listOrderByCheckStatusForShowTotalPrice.map((list) => (list.numberMenu * list.priceMenu) + (list.orderOtherMenu.length<=0 ?0 :list.orderOtherMenu.map((e) => e.orderOtherPrice * list.numberMenu).reduce((value, element) => value + element))).reduce((value, element) => value + element);
  }

  _fromGallery() async {
    try {
      var image = await ImagePicker().getImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        imageQuality: 100,
      );
      if (image!.path.isNotEmpty) {
        setState(() {
          _image = File(image.path);
        });
      }
    } catch (e) {}
  }

  _showDialogOnSave() {
    if(_image == null){
      ScaffoldMessenger.of(context).showSnackBar(
        new SnackBar(
          content: Text("กรุณาเลือกรูปภาพสลิปการโอนเงิน...!"),
          duration: Duration(seconds: 1),
        )
      );
    }else{
      if(_formKey.currentState!.validate()){
        _formKey.currentState!.save();
        return showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              content: Text("ยืนยันการทำรายการ",textAlign: TextAlign.center),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      child: Text("ยืนยัน"),
                      onPressed: () => _onSaveTableCheckBill(),
                    ),
                    ElevatedButton(
                      child: Text("ยกเลิก"),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                )
              ],
            )
        );
      }
    }
  }

  _onSaveTableCheckBill() async{
    Navigator.pop(context);

    String _paymentType = "ชำระด้วยเงินโอน";
    String _paymentStatus = "ยังไม่จ่าย";
    Map params = new Map();
    params['managerId'] = _managerId.toString();
    params['numberTable'] = _numberTable.toString();
    params['paymentType'] = _paymentType;
    params['paymentStatus'] = _paymentStatus;
    params['priceTotal'] = _priceTotal.toString();
    var response = await http.post(Uri.parse("${Config.url}/tableCheckBill/save"),body: params,headers: {'Accept': 'Application/json; charset=UTF-8'});
    var jsonData = jsonDecode(response.body);
    var data = jsonData['data'];
    if(data != null){
      var multipart = await http.MultipartFile.fromPath('fileImg',_image!.path);
      var request = http.MultipartRequest('POST', Uri.parse("${Config.url}/imageSlipTransfer/save"));
      request.files.add(multipart);
      request.fields['tableCheckBillId'] = data['tableCheckBillId'].toString();
      request.fields['nameTransfer'] = _nameTransfer!;
      request.fields['telTransfer'] = _telTransfer!;
      request.headers.addAll({'Accept': 'Application/json; charset=UTF-8'});
      var response = await http.Response.fromStream(await request.send());
      var jsonData = jsonDecode(response.body);
      var status = jsonData['status'];
      if(status == 1){
        ScaffoldMessenger.of(context).showSnackBar(
          new SnackBar(
            content: Text("เรียกชำระเงินแล้ว"),
            duration: Duration(seconds: 1),
          )
        );
        Future.delayed(Duration(seconds: 1), () => Navigator.pop(context));
      }else{
        ScaffoldMessenger.of(context).showSnackBar(
          new SnackBar(
            content: Text("เรียกไม่สำเร็จ..!!"),
            duration: Duration(seconds: 1),
          )
        );
      }
    }else{
      ScaffoldMessenger.of(context).showSnackBar(
        new SnackBar(
          content: Text("รูปภาพผิดพลาด...!!"),
          duration: Duration(seconds: 1),
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Card(
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: ListView(
              children: [
                Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back_ios),
                          onPressed: () => Navigator.pop(context),
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            color: Colors.red[300],
                            child: Center(
                                child: Text("จ่ายด้วยการโอน",style: TextStyle(fontSize: 25,color: Colors.white),)
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        child: _image != null
                            ? Stack(
                              alignment: Alignment.topRight,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black),
                                  ),
                                  width: MediaQuery.of(context).size.width * 0.8,
                                  height: MediaQuery.of(context).size.height * 0.5,
                                  child: Image.file(_image!,fit: BoxFit.fill),
                                ),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(30),
                                  child: Container(
                                    color: Colors.white,
                                    child: IconButton(
                                      icon: Icon(Icons.clear,color: Colors.red),
                                      iconSize: 30,
                                      onPressed: () => setState(() {
                                        _image = null;
                                      }),
                                    ),
                                  ),
                                )
                              ],
                            )
                            : GestureDetector(
                              onTap: () => _fromGallery(),
                              child: Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black)
                                  ),
                                  width: MediaQuery.of(context).size.width * 0.8,
                                  height: MediaQuery.of(context).size.height * 0.5,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.image,size: 50),
                                      Text("เพิ่มรูปภาพสลิปการโอนเงิน"),
                                    ],
                                  )
                              ),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("จำนวน : $_priceTotal บาท",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25,color: Colors.blue),),
                      )
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.black)
                          ),
                          child: ListTile(
                              title: Row(
                                children: [
                                  Text("ชื่อผู้โอน : "),
                                  Expanded(
                                    child: TextFormField(
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                      ),
                                      onSaved: (name) {
                                        _nameTransfer = name;
                                      },
                                      validator: (name) {
                                        if(name!.isEmpty){
                                          return "กรุณากรอก ชื่อ-สกุล ผู้โอน";
                                        }else{
                                          return null;
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              )
                          )
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.black)
                        ),
                        child: ListTile(
                          title: Row(
                            children: [
                              Text("เบอร์โทร : "),
                              Expanded(
                                child: TextFormField(
                                  decoration: InputDecoration(
                                      border: InputBorder.none
                                  ),
                                  keyboardType: TextInputType.number,
                                  maxLength: 10,
                                  onSaved: (tel) {
                                    _telTransfer = tel;
                                  },
                                  validator: (tel) {
                                    if(tel!.isEmpty){
                                      return "กรุณากรอกเบอร์โทรศัพท์";
                                    }else if(tel.length < 10){
                                      return "กรอกให้ครบ 10 ตัว";
                                    }else{
                                      return null;
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.green,
                        ),
                        child: Text("บันทึก"),
                        onPressed: () => _showDialogOnSave(),
                      ),
                    ),
                  ],
                ),
              ],
            )
          ),
        ),
      ),
    );
  }
}
