import 'package:customer_by_dart/customer/class/class_menu.dart';
import 'package:customer_by_dart/customer/class/class_other_menu.dart';
import 'package:flutter/material.dart';

class CheckBoxOnDialogTypeFoodAndTypeDrink extends StatefulWidget {
  List<OtherMenu> _listOtherMenuNotSelect;
  ValueSetter _valueSetterAddOtherMenu;
  ValueSetter _valueSetterRemoveOtherMenu;
  CheckBoxOnDialogTypeFoodAndTypeDrink(this._listOtherMenuNotSelect,this._valueSetterAddOtherMenu,this._valueSetterRemoveOtherMenu);

  @override
  State<StatefulWidget> createState() => _CheckBoxOnDialogTypeFoodAndTypeDrink(_listOtherMenuNotSelect,_valueSetterAddOtherMenu,_valueSetterRemoveOtherMenu);
}

class _CheckBoxOnDialogTypeFoodAndTypeDrink extends State<CheckBoxOnDialogTypeFoodAndTypeDrink> {
  List<OtherMenu> _listOtherMenuNotSelect;
  ValueSetter _valueSetterAddOtherMenu;
  ValueSetter _valueSetterRemoveOtherMenu;
  _CheckBoxOnDialogTypeFoodAndTypeDrink(this._listOtherMenuNotSelect,this._valueSetterAddOtherMenu,this._valueSetterRemoveOtherMenu);

  List<bool> _isCheckBox = [];
  bool _valueFromIsCheckBox = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _listOtherMenuNotSelect.forEach((element) {
      _isCheckBox.add(false);
    });
  }

  /// Check for show text.
  checkValueFromIsCheckBox(){
    _valueFromIsCheckBox = _isCheckBox.contains(true);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60 * _listOtherMenuNotSelect.length.toDouble(), /// Use height from otherMenu.length.
      width: MediaQuery.of(context).size.width,
      child: ListView.builder(
        physics: NeverScrollableScrollPhysics(), /// ไม่ต้องเลื่อนหน้าจอ
        shrinkWrap: true,
        itemCount: _listOtherMenuNotSelect.length,
        itemBuilder: (BuildContext context, int index) => Container(
          child: ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_listOtherMenuNotSelect[index].otherMenuName),
                Text("+${_listOtherMenuNotSelect[index].otherMenuPrice.toString()} บาท"),
              ],
            ),
            leading: Checkbox(
              value: _isCheckBox[index],
              onChanged: (value) => setState(() {
                _isCheckBox[index] = value!;
                checkValueFromIsCheckBox();
                if(value == true){
                  _valueSetterAddOtherMenu(_listOtherMenuNotSelect[index]); /// Add other_menu to cart.
                }else{
                  _valueSetterRemoveOtherMenu(_listOtherMenuNotSelect[index]); /// Remove other_menu from cart.
                }
              }),
            ),
          ),
        ),
      ),
    );
  }
}