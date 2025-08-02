import 'dart:convert';
import 'package:drop_down_list/model/selected_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:myapp/home_controller.dart';
import 'package:myapp/model/eczane_model.dart';
import 'package:myapp/model/sehir_model.dart';
import 'package:myapp/services/eczane_service.dart';
import 'package:myapp/widgets/example_list.dart';
import 'package:myapp/widgets/widgets.dart';
import 'package:drop_down_list/drop_down_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    controller.loadData();
    controller.illeriGetir().then((onValue) => controller.modelToString());
  }

  @override
  Widget build(BuildContext context) {
    EczaneService eczaneService = EczaneService();
    List<Data> datalist = DataList().dataList;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,

        centerTitle: true,
        title: Text(
          "Nöbetçi Eczane",
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.w700,
            fontSize: 30,
          ),
        ),
        actions: [],
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 5,
              children: [ilSelectButton(context), ilceSelectButton(context)],
            ),

            controller.secilenIlce != null
                ? Expanded(
                  child: Widgets().Future(
                    eczaneService,
                    controller.normalizeToEnglish(controller.secilenSehir!),
                    controller.normalizeToEnglish(controller.secilenIlce!),
                  ),
                ) /*EczaneItem(data: datalist, eczaneService: eczaneService),
                )*/
                : Text("Konum Bilgisi Girin"),
            //EczaneItem(),
          ],
        ),
      ),
    );
  }

  FilledButton ilceSelectButton(BuildContext context) {
    return FilledButton(
      onPressed: () {
        DropDownState(
          dropDown: DropDown(
            searchHintText: "İlçe Ara",
            data: controller.yeniIcelerListesi,
            onSelected: (ilceSelectedItem) {
              controller.secilenIlce = ilceSelectedItem[0].data;
              controller.saveData();
              setState(() {});
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

  FilledButton ilSelectButton(BuildContext context) {
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
              setState(() {});
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
}

class EczaneItem extends StatelessWidget {
  final List<Data> data;

  final EczaneService eczaneService;

  const EczaneItem({
    super.key,
    required this.data,
    required this.eczaneService,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        var item = data[index];
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
                      eczaneService.openMap(item.latitude!, item.longitude!);
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
                          Icon(Icons.map_outlined, color: Colors.blue[100]),
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
                          Text(item.address!, style: TextStyle(fontSize: 10)),
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
                          Icon(Icons.call_outlined, color: Colors.green[100]),
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
  }
}
