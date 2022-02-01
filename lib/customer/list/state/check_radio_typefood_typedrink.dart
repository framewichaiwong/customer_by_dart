
import 'package:customer_by_dart/customer/class/class_other_menu.dart';
import 'package:flutter/material.dart';

class CheckRadioTypeFoodAndTypeDrink extends StatefulWidget {
  String _showOtherStatus;
  List<OtherMenu> _listOtherMenuSelect;
  ValueSetter _valueSetterSelectRadio;
  CheckRadioTypeFoodAndTypeDrink(this._showOtherStatus,this._listOtherMenuSelect,this._valueSetterSelectRadio);

  @override
  State<StatefulWidget> createState() => _CheckRadioTypeFoodAndTypeDrink(_showOtherStatus,_listOtherMenuSelect,_valueSetterSelectRadio);
}

class _CheckRadioTypeFoodAndTypeDrink extends State<CheckRadioTypeFoodAndTypeDrink> {
  String _showOtherStatus;
  List<OtherMenu> _listOtherMenuSelect;
  ValueSetter _valueSetterSelectRadio;
  _CheckRadioTypeFoodAndTypeDrink(this._showOtherStatus,this._listOtherMenuSelect,this._valueSetterSelectRadio);

  int? valRadio;
  List<String> showText = [];
  List<OtherMenu> _listOther = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    for(int i=0; i<_listOtherMenuSelect.length; i++){
      if(_showOtherStatus == _listOtherMenuSelect[i].otherStatus){
        _listOther.add(_listOtherMenuSelect[i]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(), /// ไม่ต้องเลื่อนหน้าจอ
      shrinkWrap: true,
      itemCount: _listOther.length,
      itemBuilder: (BuildContext context, int index) => Container(
        child: ListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_listOther[index].otherMenuName),
              Text("+${_listOther[index].otherMenuPrice.toString()} บาท"),
            ],
          ),
          leading: Radio(
            value: index,
            groupValue: valRadio,
            onChanged: (int? value) => setState(() {
              valRadio = value;
              _valueSetterSelectRadio(_listOther[index]);
            }),
          ),
        ),
      ),
    );
  }
}