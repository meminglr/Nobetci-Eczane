import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:myapp/home_controller.dart';
import 'package:myapp/model/eczane_model.dart';
import 'package:myapp/services/eczane_service.dart';
import 'package:myapp/widgets/companents.dart';
import 'package:myapp/widgets/example_list.dart';

class MainScrenn extends StatefulWidget {
  final HomeController controller;
  final EczaneService eczaneService;
  final Companents companents;

  const MainScrenn({
    super.key,
    required this.controller,
    required this.eczaneService,
    required this.companents,
  });
  @override
  State<MainScrenn> createState() => _MainScrennState();
}

class _MainScrennState extends State<MainScrenn> {
  List<Data> eczaneListesi = [];
  bool isLoading = true;
  Future<void> _loadEczaneler() async {
    eczaneListesi = [];
    var result = await widget.eczaneService.getEczane(
      widget.controller.normalizeToEnglish(widget.controller.secilenSehir!),
      widget.controller.normalizeToEnglish(widget.controller.secilenIlce!),
    );
    eczaneListesi = result;
    setState(() {
      setState(() {
        isLoading = false;
      });
    }); // ✅ Liste güncellenince UI yenilenir
  }

  @override
  void initState() {
    super.initState();
    _loadEczaneler();
  }

  @override
  Widget build(BuildContext context) {
    List<Data> dataList = DataList().dataList;
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: widget.companents.floatingActionButton(
        context: context,
        companents: widget.companents,
        controller: widget.controller,
        onChanged: () {
          _loadEczaneler();
          setState(() {});
        },
      ),
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
            if (widget.controller.secilenSehir == null)
              Text("İl Bilgisi Girin")
            else if (widget.controller.secilenIlce == null)
              Text("İlçe Bilgisi Girin")
            else
              Expanded(
                child: widget.companents.future(
                  widget.eczaneService,
                  widget.controller.normalizeToEnglish(
                    widget.controller.secilenSehir!,
                  ),
                  widget.controller.normalizeToEnglish(
                    widget.controller.secilenIlce!,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
