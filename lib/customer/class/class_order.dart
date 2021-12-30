import 'package:customer_by_dart/customer/class/class_order_other_menu.dart';

class ListOrder {
  int orderId;
  int numberMenu;
  int numberTable;
  String nameMenu;
  int priceMenu;
  int managerId;
  String makeStatus;
  List<OrderOtherMenu> orderOtherMenu;
  ListOrder(this.orderId,this.numberMenu,this.numberTable,this.nameMenu,this.priceMenu,this.managerId,this.makeStatus,this.orderOtherMenu);
}