import 'package:customer_by_dart/customer/class/class_menu_cart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MenuProvider extends ChangeNotifier {
  /// Menu_Cart.
  List<MenuCart> cartMenu = [];
  List<String> _forCheckName = [];

  void addMenuToCart(addMenu,forCheckName) async {
    // String? checkName;
    bool checkName = _forCheckName.contains(forCheckName); /// เช็คว่ามีค่าใน List หรือไม่.
    if (checkName != true) {
      cartMenu.add(addMenu);
      _forCheckName.add(forCheckName);
    }else{
      for(int i=0; i<_forCheckName.length; i++){
        if(_forCheckName[i] == forCheckName){
          int oldNumberMenu = cartMenu[i].numberMenu;
          num newNumberMenu = oldNumberMenu + addMenu.numberMenu;
          cartMenu[i].numberMenu = newNumberMenu.toInt();
        }
      }
    }
    notifyListeners();
  }

  /*void addMenuToCart(addMenu){
    cartMenu.add(addMenu);
    notifyListeners();
  }*/

  void removeMenuTFromCart(removeMenu,forCheckNameRemove){
    cartMenu.remove(removeMenu);
    _forCheckName.remove(forCheckNameRemove);
    notifyListeners();
  }

  void clearAllMenuFromCart(){
    cartMenu.clear();
    _forCheckName.clear();
    notifyListeners();
  }

  void addNumberToCart(int index){
    cartMenu[index].numberMenu += 1;
    notifyListeners();
  }

  void removeNumberToCart(int index){
    if(cartMenu[index].numberMenu > 1){
      cartMenu[index].numberMenu -= 1;
    }
    notifyListeners();
  }

  //get getCartLength => this.cart.length;
}