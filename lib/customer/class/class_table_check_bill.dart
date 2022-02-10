
import 'class_image_slip_transfer.dart';

class TableCheckBill {
  int tableCheckBillId;
  int managerId;
  int numberTable;
  String paymentType;
  String paymentStatus;
  int priceTotal;
  String date;
  String time;
  List<ImageSlipTransfer> imageSlipTransfer = [];
  TableCheckBill(this.tableCheckBillId,this.managerId,this.numberTable,this.paymentType,this.paymentStatus,this.priceTotal,this.date,this.time,this.imageSlipTransfer);
}