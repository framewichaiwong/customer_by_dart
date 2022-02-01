import 'package:customer_by_dart/customer/class/class_other_menu.dart';
import 'package:flutter/material.dart';

import 'check_dialog_typefood_typedrink.dart';
import 'check_radio_typefood_typedrink.dart';

class ListViewForOtherMenu extends StatefulWidget {
  List<OtherMenu> _listOtherMenuNotSelect;
  List<OtherMenu> _listOtherMenuSelect;
  List<String> _showOtherStatus;
  ValueSetter _valueSetterAddOtherMenu;
  ValueSetter _valueSetterRemoveOtherMenu;
  ValueSetter _valueSetterSelectRadio;
  ListViewForOtherMenu(this._listOtherMenuNotSelect,this._listOtherMenuSelect,this._showOtherStatus,this._valueSetterAddOtherMenu,this._valueSetterRemoveOtherMenu,this._valueSetterSelectRadio);

  @override
  _ListViewForOtherMenuState createState() => _ListViewForOtherMenuState(_listOtherMenuNotSelect,_listOtherMenuSelect,_showOtherStatus,_valueSetterAddOtherMenu,_valueSetterRemoveOtherMenu,_valueSetterSelectRadio);
}

class _ListViewForOtherMenuState extends State<ListViewForOtherMenu> {
  List<OtherMenu> _listOtherMenuNotSelect;
  List<OtherMenu> _listOtherMenuSelect;
  List<String> _showOtherStatus;
  ValueSetter _valueSetterAddOtherMenu;
  ValueSetter _valueSetterRemoveOtherMenu;
  ValueSetter _valueSetterSelectRadio;
  _ListViewForOtherMenuState(this._listOtherMenuNotSelect,this._listOtherMenuSelect,this._showOtherStatus,this._valueSetterAddOtherMenu,this._valueSetterRemoveOtherMenu,this._valueSetterSelectRadio);

  List<String?>  checkByStatus = [];
  List<OtherMenu?> checkBySelectRadio = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    for(int i=0; i< _showOtherStatus.length; i++){
      if(!_showOtherStatus[i].contains("เลือกหรือไม่เลือกก็ได้")){
        checkBySelectRadio.add(null);
        checkByStatus.add(null);
      }
    }


  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 65 * (_listOtherMenuNotSelect.length + _listOtherMenuSelect.length).toDouble(),
      height: 600,
      width: MediaQuery.of(context).size.width,
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: _showOtherStatus.length,
        itemBuilder: (BuildContext context, int index) => Container(
          child: _showOtherStatus[index].contains("เลือกหรือไม่เลือกก็ได้")
              ? Column(
            children: [
              Text("${_showOtherStatus[index]}"),
              Container(
                child: _listOtherMenuNotSelect.isEmpty
                    ? null
                    : CheckBoxOnDialogTypeFoodAndTypeDrink(
                  _listOtherMenuNotSelect,
                      (addOtherMenu) => setState(() => _valueSetterAddOtherMenu(addOtherMenu)),
                      (removeOtherMenu) => setState(() => _valueSetterRemoveOtherMenu(removeOtherMenu)),
                ),
              ),
            ],
          )
              : Column(
            children: [
              Container(
                child: checkByStatus.contains(_showOtherStatus[index])
                    ? Text("${_showOtherStatus[index]}")
                    : Text("*${_showOtherStatus[index]}",style: TextStyle(color: Colors.red),),
              ),
              Container(
                child: _listOtherMenuSelect.isEmpty
                    ? null
                    : CheckRadioTypeFoodAndTypeDrink(
                  _showOtherStatus[index],
                  _listOtherMenuSelect,
                      (selectOtherMenu) => setState(() {
                    // _valueSetterSelectRadio(selectOtherMenu); /// data between page.
                    // checkBySelectRadio[index] = selectOtherMenu;
                    // checkByStatus[index] = selectOtherMenu.otherStatus;
                    for(int i=0; i<checkBySelectRadio.length; i++){
                      checkBySelectRadio[index] = selectOtherMenu;
                      checkByStatus[index] = selectOtherMenu.otherStatus;
                      if(checkBySelectRadio[i] != null){
                        if(checkBySelectRadio.length == i+1){
                          _valueSetterSelectRadio(checkBySelectRadio); /// data between page.
                        }
                      }
                    }
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}