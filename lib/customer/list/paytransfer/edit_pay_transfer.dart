
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:customer_by_dart/config/config.dart';
import 'package:customer_by_dart/customer/class/class_image_slip_transfer.dart';
import 'package:customer_by_dart/customer/class/class_table_check_bill.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class EditPayTransfer extends StatefulWidget {
  TableCheckBill tableCheckBill;
  EditPayTransfer(this.tableCheckBill);


  @override
  _EditPayTransferState createState() => _EditPayTransferState(tableCheckBill);
}

class _EditPayTransferState extends State<EditPayTransfer> {
  TableCheckBill tableCheckBill;
  _EditPayTransferState(this.tableCheckBill);

  /// Key.
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  int? _tableCheckBillId;
  int? _managerId;
  int? _numberTable;
  String? _paymentType;
  int? _priceTotal;
  String? _nameTransfer;
  String? _telTransfer;

  File? _image;
  List<File?> _fileImage = [];
  List<int?> _deleteImageId = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tableCheckBillId = tableCheckBill.tableCheckBillId;
    _managerId = tableCheckBill.managerId;
    _numberTable = tableCheckBill.numberTable;
    _paymentType = tableCheckBill.paymentType;
    _priceTotal = tableCheckBill.priceTotal;
    for(int i=0; i<tableCheckBill.imageSlipTransfer.length; i++){
      _nameTransfer = tableCheckBill.imageSlipTransfer[i].nameTransfer;
      _telTransfer = tableCheckBill.imageSlipTransfer[i].telTransfer;
    }
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
          /// Add image to List<fileImage>.
          _fileImage.insert(0, _image!);
          /// Add image to byte for show slide.
          var byteImg = _image!.readAsBytesSync();
          var random = new Random();
          ImageSlipTransfer imgSlip = new ImageSlipTransfer(random.nextInt(100), _nameTransfer!, _telTransfer!, _tableCheckBillId!, byteImg);
          tableCheckBill.imageSlipTransfer.insert(0, imgSlip);
        });
      }
    } catch (e) {}
  }

  _buttonRemoveImage(ImageSlipTransfer e){
    /// Check image_id == 0
    if(e.imageSlipId == 0){
      /// Add image to byte for show slide.
      tableCheckBill.imageSlipTransfer.removeWhere((element) => element.imageSlipId == e.imageSlipId);
      /// Add image to List<fileImage>.
      _fileImage.remove(e.imageSlip);
    }else{
      /// Add image_id for delete old image in data_base.
      _deleteImageId.add(e.imageSlipId);
      /// Add image to byte for show slide.
      tableCheckBill.imageSlipTransfer.removeWhere((element) => element.imageSlipId == e.imageSlipId);
    }
  }

  _showDialogPayEdit(){
    if(_fileImage.isEmpty && tableCheckBill.imageSlipTransfer.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        new SnackBar(
          content: Text("กรุณาเลือกรูปภาพการโอนเงิน"),
        )
      );
    }else{
      if(_formKey.currentState!.validate()){
        _formKey.currentState!.save();

        return showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              content: Text("แก้ไขรูปภาพการโอนเงิน",textAlign: TextAlign.center),
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
                          onPressed: () => _buttonEdit(),
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
                          child: Text("ย้อนกลับ"),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            )
        );
      }
    }
  }

  _buttonEdit() async{
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
      bool checkEditImage = await _editImageSlipTransfer();
      if(checkEditImage == true){
        ScaffoldMessenger.of(context).showSnackBar(
          new SnackBar(
            duration: Duration(seconds: 1),
            content: Text("แก้ไขรูปภาพการโอนเงินสำเร็จ"),
          )
        );
        Future.delayed(Duration(seconds: 1), () => Navigator.pop(context));
      }
    }
  }

  Future<bool> _editImageSlipTransfer() async{
    if(_deleteImageId.length > 0 && _fileImage.length > 0){
      /// delete image.
      _deleteImageId.forEach((element) async{
        await http.post(Uri.parse("${Config.url}/imageSlipTransfer/remove/$element"),headers: {'Accept': 'Application/json; charset=UTF-8'});
      });
      /// add image.
      _fileImage.forEach((element) async{
        var request = http.MultipartRequest("POST",Uri.parse("${Config.url}/imageSlipTransfer/save"));
        var multipart = await http.MultipartFile.fromPath("fileImg",element!.path);
        request.files.add(multipart);
        request.fields['nameTransfer'] = _nameTransfer!;
        request.fields['telTransfer'] = _telTransfer.toString();
        request.fields['tableCheckBillId'] = _tableCheckBillId.toString();
        request.headers.addAll({'Accept': 'Application/json; charset=UTF-8'});
        await http.Response.fromStream(await request.send());
      });
      return true;
    }else if(_deleteImageId.length > 0 && _fileImage.length <= 0){
      /// delete image.
      _deleteImageId.forEach((element) async{
        await http.post(Uri.parse("${Config.url}/imageSlipTransfer/remove/$element"),headers: {'Accept': 'Application/json; charset=UTF-8'});
      });
      return true;
    }else if(_deleteImageId.length <= 0 && _fileImage.length > 0){
      /// add image.
      _fileImage.forEach((element) async{
        var request = http.MultipartRequest("POST",Uri.parse("${Config.url}/imageSlipTransfer/save"));
        var multipart = await http.MultipartFile.fromPath("fileImg",element!.path);
        request.files.add(multipart);
        request.fields['nameTransfer'] = _nameTransfer!;
        request.fields['telTransfer'] = _telTransfer.toString();
        request.fields['tableCheckBillId'] = _tableCheckBillId.toString();
        request.headers.addAll({'Accept': 'Application/json; charset=UTF-8'});
        await http.Response.fromStream(await request.send());
      });
      return true;
    }else if(_deleteImageId.length <= 0 && _fileImage.length <= 0){
      return true;
    }
    return false;
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
                                child: Text("จ่ายด้วยการโอน",style: TextStyle(fontSize: 25,color: Colors.black),)
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          child: tableCheckBill.imageSlipTransfer.length > 0
                              ? Container(
                                  height: MediaQuery.of(context).size.height * 0.5,
                                  width: MediaQuery.of(context).size.width * 0.8,
                                  child: PageView.builder(
                                    itemCount: tableCheckBill.imageSlipTransfer.length,
                                    itemBuilder: (BuildContext context,int index) => Stack(
                                      alignment: Alignment.topRight,
                                      children: [
                                          Image.memory(tableCheckBill.imageSlipTransfer[index].imageSlip, fit: BoxFit.fill),
                                           ClipRRect(
                                              borderRadius: BorderRadius.circular(30),
                                              child: Container(
                                                 color: Colors.white,
                                                 child: IconButton(
                                                     icon: Icon(Icons.clear,color: Colors.red),
                                                     iconSize: 30,
                                                     onPressed: () => setState(() {
                                                         _buttonRemoveImage(tableCheckBill.imageSlipTransfer[index]);
                                                     }),
                                                 ),
                                              ),
                                           )
                                      ],
                                    ),
                                  ),
                                )
                              // ? Container(
                              //     height: MediaQuery.of(context).size.height * 0.5,
                              //     width: MediaQuery.of(context).size.width * 0.8,
                              //     child: CarouselSlider(
                              //       options: CarouselOptions(
                              //         height: MediaQuery.of(context).size.height,
                              //         viewportFraction: 1,
                              //       ),
                              //       items: tableCheckBill.imageSlipTransfer.map((e) {
                              //         return Builder(
                              //           builder: (BuildContext context) {
                              //             return Card(
                              //                 child: Stack(
                              //                   alignment: Alignment.topRight,
                              //                   children: [
                              //                     Image.memory(e.imageSlip, fit: BoxFit.fill),
                              //                     ClipRRect(
                              //                       borderRadius: BorderRadius.circular(30),
                              //                       child: Container(
                              //                         color: Colors.white,
                              //                         child: IconButton(
                              //                           icon: Icon(Icons.clear,color: Colors.red),
                              //                           iconSize: 30,
                              //                           onPressed: () => setState(() {
                              //                             _buttonRemoveImage(e);
                              //                           }),
                              //                         ),
                              //                       ),
                              //                     )
                              //                   ],
                              //                 )
                              //             );
                              //           },
                              //         );
                              //       }).toList(),
                              //     ),
                              //   )
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
                                      Text("เพิ่มรูปภาพสลิปการโอนเงิน"),
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
                                        controller: TextEditingController(text: _nameTransfer),
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
                                    controller: TextEditingController(text: _telTransfer),
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
                          onPressed: () => _showDialogPayEdit(),
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
