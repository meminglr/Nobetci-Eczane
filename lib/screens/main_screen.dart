import 'package:flutter/material.dart';
import 'package:myapp/home_controller.dart';
import 'package:myapp/services/eczane_service.dart';
import 'package:myapp/widgets/companents.dart';

class MainScrenn extends StatefulWidget {
  final HomeController controller;
  final EczaneService eczaneService;
  final Companents companents;

  MainScrenn({
    super.key,
    required this.controller,
    required this.eczaneService,
    required this.companents,
  });

  @override
  State<MainScrenn> createState() => _MainScrennState();
}

class _MainScrennState extends State<MainScrenn> {
  @override
  Widget build(BuildContext context) {
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
              children: [
                widget.companents.ilSelectButton(
                  context,
                  widget.controller,
                  () {
                    setState(() {});
                  },
                ),
                widget.companents.ilceSelectButton(
                  context,
                  widget.controller,
                  () {
                    setState(() {
                    });
                  },
                ),
              ],
            ),

            widget.controller.secilenIlce != null
                ? Expanded(
                  child: widget.companents.Future(
                    widget.eczaneService,
                    widget.controller.normalizeToEnglish(
                      widget.controller.secilenSehir!,
                    ),
                    widget.controller.normalizeToEnglish(
                      widget.controller.secilenIlce!,
                    ),
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
}
