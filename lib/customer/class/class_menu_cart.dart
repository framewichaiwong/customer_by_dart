import 'package:customer_by_dart/customer/class/class_other_menu.dart';

class MenuCart {
  int menuId;
  String nameMenu;
  int priceMenu;
  String typeMenu;
  int managerId;
  int numberMenu;//number of menu
  List<OtherMenu> otherMenu;
  MenuCart(this.menuId,this.nameMenu,this.priceMenu,this.typeMenu,this.managerId,this.numberMenu,this.otherMenu);

}