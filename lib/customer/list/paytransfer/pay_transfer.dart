import 'dart:convert';
import 'dart:io';

import 'package:customer_by_dart/config/config.dart';
import 'package:customer_by_dart/customer/class/class_table_check_bill.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class PayByTransfer extends StatefulWidget {
  TableCheckBill tableCheckBill;
  PayByTransfer(this.tableCheckBill);

  @override
  _PayByTransfer createState() => _PayByTransfer(tableCheckBill);
}

class _PayByTransfer extends State<PayByTransfer> {
  TableCheckBill tableCheckBill;
  _PayByTransfer(this.tableCheckBill);

  /// Key.
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  /// Parameter.
  File? _image;
  String? _nameTransfer;
  String? _telTransfer;
  int? _managerId;
  int? _numberTable;
  String? _paymentType;
  int? _tableCheckBillId;
  int? _priceTotal;
  List<File> _fileImage = [];

  @override
  void initState() {
    super.initState();
    _managerId = tableCheckBill.managerId;
    _numberTable = tableCheckBill.numberTable;
    _paymentType = tableCheckBill.paymentType;
    _tableCheckBillId = tableCheckBill.tableCheckBillId;
    _priceTotal = tableCheckBill.priceTotal;
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
          _fileImage.add(_image!);
        });
      }
    } catch (e) {}
  }

  _showDialogOnSave() {
    if(_fileImage.isEmpty){
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
              content: Text("ยืนยันการทำรายการ",style: TextStyle(fontWeight: FontWeight.bold),textAlign: TextAlign.center),
              actions: [
                Column(
                  children: [
                    Center(
                      child: Container(
                        height: 40,
                        width: MediaQuery.of(context).size.width,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.green,
                          ),
                          child: Text("ยืนยัน"),
                          onPressed: () => _onSaveTableCheckBill(),
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.red[300],
                          ),
                          child: Text("ยกเลิก"),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
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

    String _paymentStatus = "ตรวจสอบรูปภาพการโอนเงิน";
    Map params = new Map();
    params['tableCheckBillId'] = _tableCheckBillId.toString();
    params['managerId'] = _managerId.toString();
    params['numberTable'] = _numberTable.toString();
    params['paymentType'] = _paymentType;
    params['paymentStatus'] = _paymentStatus;
    params['priceTotal'] = _priceTotal.toString();
    var response = await http.post(Uri.parse("${Config.url}/tableCheckBill/updateByCustomer"),body: params,headers: {'Accept': 'Application/json; charset=UTF-8'});
    var jsonData = jsonDecode(response.body);
    var data = jsonData['data'];
    if(data != null){
      for(int i=0; i<_fileImage.length; i++){
        var multipart = await http.MultipartFile.fromPath('fileImg',_fileImage[i].path);
        var request = http.MultipartRequest('POST', Uri.parse("${Config.url}/imageSlipTransfer/save"));
        request.files.add(multipart);
        request.fields['tableCheckBillId'] = _tableCheckBillId.toString();
        request.fields['nameTransfer'] = _nameTransfer!;
        request.fields['telTransfer'] = _telTransfer!;
        request.headers.addAll({'Accept': 'Application/json; charset=UTF-8'});
        var response = await http.Response.fromStream(await request.send());
        var jsonData = jsonDecode(response.body);
        var status = jsonData['status'];
        if(status == 1 && _fileImage.length == i+1){
          ScaffoldMessenger.of(context).showSnackBar(
              new SnackBar(
                content: Text("เพิ่มรูปภาพการโอนเงินแล้ว"),
                duration: Duration(seconds: 1),
              )
          );
          Future.delayed(Duration(seconds: 1), () => Navigator.pop(context));
        }
      }
    }else{
      ScaffoldMessenger.of(context).showSnackBar(
        new SnackBar(
          content: Text("ทำรายการไม่สำเร็จ"),
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
                        Container(
                          width: MediaQuery.of(context).size.width * 0.75,
                          child: Center(
                              child: Text("เพิ่มรูปภาพการโอนเงิน",style: TextStyle(fontSize: 25,color: Colors.black),)
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        child: _fileImage.isNotEmpty
                            ? Container(
                                height: MediaQuery.of(context).size.height * 0.5,
                                width: MediaQuery.of(context).size.width * 0.8,
                                child: PageView.builder(
                                  itemCount: _fileImage.length,
                                  itemBuilder: (BuildContext context,int index) => Stack(
                                    alignment: Alignment.topRight,
                                    children: [
                                      Image.file(_fileImage[index], fit: BoxFit.fill),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(30),
                                        child: Container(
                                          color: Colors.white,
                                          child: IconButton(
                                            icon: Icon(Icons.clear,color: Colors.red),
                                            iconSize: 30,
                                            onPressed: () => setState(() {
                                              _fileImage.remove(_fileImage[index]);
                                            }),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              )
                            : Container(
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black)
                                ),
                                width: MediaQuery.of(context).size.width * 0.8,
                                height: MediaQuery.of(context).size.height * 0.5,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.image,size: 50),
                                    Text("เพิ่มรูปภาพการโอนเงิน"),
                                  ],
                                )
                            ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () => _fromGallery(),
                        child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.black)
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(Icons.add,size: 25),
                            )
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black)
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("จำนวน : $_priceTotal บาท",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25,color: Colors.blue),),
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
