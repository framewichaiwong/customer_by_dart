import 'package:customer_by_dart/customer/class/class_menu.dart';
import 'package:customer_by_dart/customer/class/class_other_menu.dart';
import 'package:flutter/material.dart';

class CheckBoxOnDialogTypeFoodAndTypeDrink extends StatefulWidget {
  Menu menu;
  List<OtherMenu> otherMenu;
  ValueSetter _valueSetterAddOtherMenu;
  ValueSetter _valueSetterRemoveOtherMenu;
  CheckBoxOnDialogTypeFoodAndTypeDrink(this.menu,this.otherMenu,this._valueSetterAddOtherMenu,this._valueSetterRemoveOtherMenu);

  @override
  State<StatefulWidget> createState() => _CheckBoxOnDialogTypeFoodAndTypeDrink(menu,otherMenu,_valueSetterAddOtherMenu,_valueSetterRemoveOtherMenu);
}

class _CheckBoxOnDialogTypeFoodAndTypeDrink extends State<CheckBoxOnDialogTypeFoodAndTypeDrink> {
  Menu menu;
  List<OtherMenu> otherMenu;
  ValueSetter _valueSetterAddOtherMenu;
  ValueSetter _valueSetterRemoveOtherMenu;
  _CheckBoxOnDialogTypeFoodAndTypeDrink(this.menu,this.otherMenu,this._valueSetterAddOtherMenu,this._valueSetterRemoveOtherMenu);

  List<bool> _isCheckBox = [];
  bool _valueFromIsCheckBox = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    otherMenu.forEach((element) {
      _isCheckBox.add(false);
    });
  }

  /// Check for show text.
  checkValueFromIsCheckBox(){
    _valueFromIsCheckBox = _isCheckBox.contains(true);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          child: otherMenu.length == 0
              ? null
              : menu.categoryName=="ก๋วยเตี๋ยว"||menu.categoryName=="ผัดไทย"||menu.categoryName=="ราดหน้า"||menu.categoryName=="บะหมี่"
                ? _valueFromIsCheckBox==true
                  ? Text("เลือกเส้น")
                  : Text("*เลือกเส้น",style: TextStyle(color: Colors.red))
                : Text("เมนูเพิ่มเติม (เลือกหรือไม่เลือกก็ได้)"),
        ),
        Container(
          height: 60 * otherMenu.length.toDouble(), /// Use height from otherMenu.length.
          width: MediaQuery.of(context).size.width,
          child: ListView.builder(
            physics: NeverScrollableScrollPhysics(), /// ไม่ต้องเลื่อนหน้าจอ
            shrinkWrap: true,
            itemCount: otherMenu.length,
            itemBuilder: (BuildContext context, int index) => Container(
              child: ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(otherMenu[index].otherMenuName),
                    Text("+${otherMenu[index].otherMenuPrice.toString()} บาท"),
                  ],
                ),
                leading: Checkbox(
                  value: _isCheckBox[index],
                  onChanged: (value) => setState(() {
                    _isCheckBox[index] = value!;
                    checkValueFromIsCheckBox();
                    if(value == true){
                      _valueSetterAddOtherMenu(otherMenu[index]); /// Add other_menu to cart.
                    }else{
                      _valueSetterRemoveOtherMenu(otherMenu[index]); /// Remove other_menu from cart.
                    }
                  }),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}