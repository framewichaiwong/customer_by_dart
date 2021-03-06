import 'package:customer_by_dart/customer/class/class_other_menu.dart';
import 'package:flutter/material.dart';

class CheckBoxOnDialogTypeFoodAndTypeDrink extends StatefulWidget {
  String _showOtherStatus;
  List<OtherMenu> _listOtherMenuNotSelect;
  ValueSetter _valueSetterAddOtherMenu;
  ValueSetter _valueSetterRemoveOtherMenu;
  CheckBoxOnDialogTypeFoodAndTypeDrink(this._showOtherStatus,this._listOtherMenuNotSelect,this._valueSetterAddOtherMenu,this._valueSetterRemoveOtherMenu);

  @override
  State<StatefulWidget> createState() => _CheckBoxOnDialogTypeFoodAndTypeDrink(_showOtherStatus,_listOtherMenuNotSelect,_valueSetterAddOtherMenu,_valueSetterRemoveOtherMenu);
}

class _CheckBoxOnDialogTypeFoodAndTypeDrink extends State<CheckBoxOnDialogTypeFoodAndTypeDrink> {
  String _showOtherStatus;
  List<OtherMenu> _listOtherMenuNotSelect;
  ValueSetter _valueSetterAddOtherMenu;
  ValueSetter _valueSetterRemoveOtherMenu;
  _CheckBoxOnDialogTypeFoodAndTypeDrink(this._showOtherStatus,this._listOtherMenuNotSelect,this._valueSetterAddOtherMenu,this._valueSetterRemoveOtherMenu);

  List<bool> _isCheckBox = [];
  List<OtherMenu> _listOther = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _listOtherMenuNotSelect.forEach((element) {
      _isCheckBox.add(false);
    });

    for(int i=0; i<_listOtherMenuNotSelect.length; i++){
      if(_showOtherStatus.substring(3) == _listOtherMenuNotSelect[i].otherStatus){
        _listOther.add(_listOtherMenuNotSelect[i]);
      }
    }
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
      itemCount: _listOther.length,
      itemBuilder: (BuildContext context, int index) => Container(
        child: _listOther[index].otherStatusSale == "ขาย"
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Checkbox(
                    value: _isCheckBox[index],
                    onChanged: (value) => setState(() {
                      _isCheckBox[index] = value!;
                      // checkValueFromIsCheckBox();
                      if(value == true){
                        _valueSetterAddOtherMenu(_listOther[index]); /// Add other_menu to cart.
                      }else{
                        _valueSetterRemoveOtherMenu(_listOther[index]); /// Remove other_menu from cart.
                      }
                    }),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.45,
                          child: Text(_listOther[index].otherMenuName),
                        ),
                        SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.15,
                          child: Text("+${_listOther[index].otherMenuPrice.toString()}",textAlign: TextAlign.right),
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
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.45,
                          child: Row(
                            children: [
                              Text(_listOther[index].otherMenuName),
                              Text("[${_listOther[index].otherStatusSale}]",style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                        SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.15,
                          child: Text("+${_listOther[index].otherMenuPrice.toString()}",textAlign: TextAlign.right),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.15,
                          child: Text("บาท"),
                        )
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}