import 'package:drop_down_list/drop_down_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myapp/home_controller.dart';
import 'package:myapp/home_page.dart';

class TutoriolPage extends StatefulWidget {
  const TutoriolPage({super.key});

  @override
  State<TutoriolPage> createState() => _TutoriolPageState();
}

class _TutoriolPageState extends State<TutoriolPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller.illeriGetir().then((onValue) => controller.modelToString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      body: Center(
        child: Column(
          spacing: 5,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Nöbetçi Eczane",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 50,
              ),
            ),
            FilledButton(
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
                      controller.secilenIlinIlceleriniGetir(
                        controller.secilenSehir!,
                      );
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
                style: TextStyle(color: Colors.red, fontSize: 25),
              ),
            ),
            FilledButton(
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
                      controller.saveData();
                      setState(() {});
                      Navigator.push(
                        context,
                        CupertinoPageRoute(builder: (context) => HomePage()),
                      );
                    },
                  ),
                ).showModal(context);
              },
              child: Text(
                controller.secilenIlce == null
                    ? "İlçe Seçiniz"
                    : controller.secilenIlce!,
                style: TextStyle(color: Colors.red, fontSize: 25),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
