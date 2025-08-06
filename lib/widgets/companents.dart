import 'package:drop_down_list/drop_down_list.dart';
import 'package:flutter/material.dart';
import 'package:myapp/home_controller.dart';
import 'package:myapp/model/eczane_model.dart';
import 'package:myapp/services/eczane_service.dart';

class Companents {
  FutureBuilder<List<Data>> future(
    EczaneService eczaneService,
    String il,
    String ilce,
  ) {
    return FutureBuilder(
      future: eczaneService.getEczane(il, ilce),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final eczaneler = snapshot.data!;
          return ListView.builder(
            physics: BouncingScrollPhysics(),
            itemCount: eczaneler.length,
            itemBuilder: (context, index) {
              var item = eczaneler[index];
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

  FilledButton ilceSelectButton(
    BuildContext context,
    HomeController controller,
    VoidCallback onChanged,
  ) {
    return FilledButton(
      onPressed: () {
        DropDownState(
          dropDown: DropDown(
            searchHintText: "İlçe Ara",
            data: controller.yeniIcelerListesi,
            onSelected: (ilceSelectedItem) {
              controller.secilenIlce = ilceSelectedItem[0].data;
              controller.saveData();
              onChanged();
            },
          ),
        ).showModal(context);
      },
      child: Text(
        controller.secilenIlce == null
            ? "İlçe Seçiniz"
            : controller.secilenIlce!,
      ),
    );
  }

  FilledButton ilSelectButton(
    BuildContext context,
    HomeController controller,
    VoidCallback onChanged,
  ) {
    return FilledButton(
      onPressed: () {
        DropDownState(
          dropDown: DropDown(
            searchHintText: "Şehir Ara",
            data: controller.yeniIllerListesi,
            onSelected: (ilSelectedItem) {
              controller.secilenSehir = ilSelectedItem[0].data;
              controller.secilenIlce = null;
              controller.secilenIlinIlceleriniGetir(controller.secilenSehir!);
              controller.saveData();
              onChanged();
            },
          ),
        ).showModal(context);
      },
      child: Text(
        controller.secilenSehir == null
            ? "Şehir Seçiniz"
            : controller.secilenSehir!,
      ),
    );
  }

  FilledButton firstScreenIlce(
    BuildContext context,
    HomeController controller,
    VoidCallback onChanged,
  ) {
    return FilledButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(Colors.white),
      ),
      onPressed: () {
        DropDownState(
          dropDown: DropDown(
            searchHintText: "İlçe Ara",
            data: controller.yeniIcelerListesi,
            onSelected: (ilceSelectedItem) async {
              controller.secilenIlce = await ilceSelectedItem[0].data;
              controller.isFirst = false;
              controller.saveData();
              onChanged();
            },
          ),
        ).showModal(context);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          controller.secilenIlce == null
              ? "İlçe Seçiniz"
              : controller.secilenIlce!,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.red,
            fontSize: 25,
          ),
        ),
      ),
    );
  }

  FilledButton firstScreenIl(
    BuildContext context,
    HomeController controller,
    VoidCallback onChanged,
  ) {
    return FilledButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(Colors.white),
      ),
      onPressed: () {
        DropDownState(
          dropDown: DropDown(
            searchHintText: "Şehir Ara",
            data: controller.yeniIllerListesi,
            onSelected: (ilSelectedItem) {
              controller.secilenSehir = ilSelectedItem[0].data;
              controller.secilenIlce = null;
              controller.secilenIlinIlceleriniGetir(controller.secilenSehir!);
              controller.saveData();
              onChanged();
            },
          ),
        ).showModal(context);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          controller.secilenSehir == null
              ? "Şehir Seçiniz"
              : controller.secilenSehir!,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.red,
            fontSize: 25,
          ),
        ),
      ),
    );
  }

  Container floatingActionButton({
    required BuildContext context,
    required HomeController controller,
    required Companents companents,
    required VoidCallback onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white, // Beyaz arkaplan
        borderRadius: BorderRadius.circular(20), // Yuvarlak köşeler
        boxShadow: [
          BoxShadow(
            // İstersen hafif gölge ekleyebilirsin
            color: Colors.black26,
            blurRadius: 15,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          companents.ilSelectButton(context, controller, () {
            onChanged();
          }),
          SizedBox(width: 5), // spacing yerine SizedBox kullandım
          companents.ilceSelectButton(context, controller, () {
            onChanged();
          }),
        ],
      ),
    );
  }
}
