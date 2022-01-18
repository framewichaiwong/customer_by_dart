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

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: SafeArea(
        child: Card(
          color: Colors.red[100],
          child: ListView(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        width: 400,
                        color: Colors.red[300],
                        child: Center(
                          child: Text("ร้าน : " + "${userManager[0].nameRestaurant}",style: TextStyle(fontSize: 25,color: Colors.white),),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 25),
                  Container(
                    width: 400,
                    height: 250,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.memory(
                        userManager[0].picture,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      color: Colors.purple[100],
                      child: ListTile(
                        title: Text(
                          "เจ้าของร้าน : คุณ ${userManager[0].name} ${userManager[0].surName}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                        color: Colors.purple[200],
                        child: ListTile(
                          title: Text(
                            "เบอร์โทร : " + "${userManager[0].tel}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        )
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      color: Colors.purple[100],
                      child: ListTile(
                        title: Row(
                          children: [
                            Text(
                              "ที่อยู่ : ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 25,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                "${userManager[0].address}",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
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