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
  // bool _valueFromIsCheckBox = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _listOtherMenuNotSelect.forEach((element) {
      _isCheckBox.add(false);
    });
  }

  /// Check for show text.
  // checkValueFromIsCheckBox(){
  //   _valueFromIsCheckBox = _isCheckBox.contains(true);
  // }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(), /// ไม่ต้องเลื่อนหน้าจอ
      shrinkWrap: true,
      itemCount: _listOtherMenuNotSelect.length,
      itemBuilder: (BuildContext context, int index) => Container(
        child: _listOtherMenuNotSelect[index].otherStatusSale == "ขาย"
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Checkbox(
                    value: _isCheckBox[index],
                    onChanged: (value) => setState(() {
                      _isCheckBox[index] = value!;
                      // checkValueFromIsCheckBox();
                      if(value == true){
                        _valueSetterAddOtherMenu(_listOtherMenuNotSelect[index]); /// Add other_menu to cart.
                      }else{
                        _valueSetterRemoveOtherMenu(_listOtherMenuNotSelect[index]); /// Remove other_menu from cart.
                      }
                    }),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.45,
                          child: Text(_listOtherMenuNotSelect[index].otherMenuName),
                        ),
                        SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.15,
                          child: Text("+${_listOtherMenuNotSelect[index].otherMenuPrice.toString()}",textAlign: TextAlign.right),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.15,
                          child: Text("บาท"),
                        )
                      ],
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Checkbox(
                    value: false,
                    onChanged: null,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.3,
                    child: Wrap(
                      children: [
                        Text("${_listOtherMenuNotSelect[index].otherMenuName}"),
                        Text("[${_listOtherMenuNotSelect[index].otherStatusSale}]",style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.1,
                    child: Text("+${_listOtherMenuNotSelect[index].otherMenuPrice.toString()}",textAlign: TextAlign.right),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.11,
                    child: Text("บาท"),
                  ),
                ],
              ),
      ),
    );
  }
}