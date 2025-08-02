import 'package:flutter/material.dart';
import 'package:myapp/model/eczane_model.dart';
import 'package:myapp/services/eczane_service.dart';
import 'package:url_launcher/url_launcher.dart';

class Widgets {
  FutureBuilder<List<Data>> Future(
    EczaneService eczaneService,
    String il,
    String ilce,
  ) {
    return FutureBuilder(
      future: eczaneService.getEczane(il, ilce),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var item = snapshot.data![index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 100,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: InkWell(
                          borderRadius: BorderRadius.horizontal(
                            left: Radius.circular(20),
                          ),
                          onTap: () {
                            eczaneService.openMap(
                              item.latitude!,
                              item.longitude!,
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.horizontal(
                                left: Radius.circular(20),
                                right: Radius.circular(5),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.map_outlined,
                                  color: Colors.blue[100],
                                ),
                                Text(
                                  "Harita",
                                  style: TextStyle(color: Colors.blue[100]),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),

                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.pharmacyName!,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  item.address!,
                                  style: TextStyle(fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: InkWell(
                          borderRadius: BorderRadius.horizontal(
                            right: Radius.circular(20),
                          ),
                          onTap: () {
                            eczaneService.makePhoneCall(item.phone!);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.horizontal(
                                right: Radius.circular(20),

                                left: Radius.circular(5),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.call_outlined,
                                  color: Colors.green[100],
                                ),
                                Text(
                                  "Ara",
                                  style: TextStyle(color: Colors.green[100]),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }


  
}
