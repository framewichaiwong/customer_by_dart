import 'package:customer_by_dart/customer/class/class_user_manager.dart';
import 'package:flutter/material.dart';

class ResInformation extends StatefulWidget {
  List<UserManager> userManager;
  ResInformation(this.userManager);

  @override
  State<StatefulWidget> createState() => _ResInformation(userManager);
}

class _ResInformation extends State<ResInformation> {
  List<UserManager> userManager;
  _ResInformation(this.userManager);

  /// Widget.
  Text headerText(String string){
    return Text("$string",style: TextStyle(color: Colors.white,fontSize: 25),textAlign: TextAlign.center);
  }
  Text bodyText(String string){
    return Text("$string",style: TextStyle(color: Colors.white,fontSize:20));
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: SafeArea(
        child: Card(
          color: Colors.blueGrey[300],
          child: ListView(
            children: [
              Stack(
                alignment: Alignment.topLeft,
                children: [
                  Column( /// ใช้เพื่อขยายพื้นที่เต็มจอ
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white,width: 3),
                        ),
                        height: MediaQuery.of(context).size.height * 0.25,
                        width: MediaQuery.of(context).size.width,
                        child: Image.memory(userManager[0].picture,fit: BoxFit.fitWidth),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.08),
                      Container(
                        // color: Colors.purpleAccent,
                        width: MediaQuery.of(context).size.width,
                        child: headerText("ร้าน : ${userManager[0].nameRestaurant}"),
                      ),
                      Divider(
                        color: Colors.grey[800],
                        thickness: 2,
                        height: 2,
                        indent: 10,
                        endIndent: 10,
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                      Container(
                        // color: Colors.amber,
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            bodyText("ที่อยู่ร้าน"),
                            bodyText("${userManager[0].address}"),
                            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                            bodyText("ผู้ก่อตั้ง"),
                            bodyText("คุณ ${userManager[0].name}  ${userManager[0].surName}"),
                            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                            bodyText("เบอร์โทร : ${userManager[0].tel}"),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.2,
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                      ),
                      color: Colors.white,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.25,
                        child: Image.asset("images_for_app/homepage_icon/restaurant_1.png",fit: BoxFit.fitWidth),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}