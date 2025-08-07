import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:myapp/home_controller.dart';
import 'package:myapp/model/eczane_model.dart';
import 'package:myapp/services/eczane_service.dart';
import 'package:myapp/widgets/companents.dart';
import 'package:myapp/widgets/example_list.dart';

class SliverScreen2 extends StatefulWidget {
  final HomeController controller;
  final EczaneService eczaneService;
  final Companents companents;

  const SliverScreen2({
    super.key,
    required this.controller,
    required this.eczaneService,
    required this.companents,
  });
  @override
  State<SliverScreen2> createState() => _SliverScreen2State();
}

class _SliverScreen2State extends State<SliverScreen2> {
  List<Data> dataList = DataList().dataList;
  List<Data> eczaneListesi = [];
  bool isLoading = true;
  GoogleMapController? mapController;
  Set<Marker> markers = {};

  Future<void> _loadEczaneler() async {
    eczaneListesi = [];
    var result = await widget.eczaneService.getEczane(
      widget.controller.normalizeToEnglish(widget.controller.secilenSehir!),
      widget.controller.normalizeToEnglish(widget.controller.secilenIlce!),
    );
    eczaneListesi = result;

    markers.clear();
    for (var eczane in dataList) {
      if (eczane.latitude != null && eczane.longitude != null) {
        markers.add(
          Marker(
            markerId: MarkerId(
              eczane.pharmacyName ?? Random().nextInt(1000).toString(),
            ),
            position: LatLng(eczane.latitude!, eczane.longitude!),
            infoWindow: InfoWindow(title: eczane.pharmacyName),
          ),
        );
      }
    }

    setState(() {
      setState(() {
        isLoading = false;
      });
    }); // ✅ Liste güncellenince UI yenilenir
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
      body: NestedScrollView(
        physics: BouncingScrollPhysics(),

        headerSliverBuilder:
            (context, innerBoxIsScrolled) => [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                scrolledUnderElevation: 0,
                pinned: true,
                toolbarHeight: 100,
                expandedHeight: 300,
                collapsedHeight: 100,
                flexibleSpace: FlexibleSpaceBar(
                  background: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    child: GoogleMap(
                      onMapCreated:
                          (controller) => mapController = controller,
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                          dataList.first.latitude!,
                          dataList.first.longitude!,
                        ),
                        zoom: 13,
                      ),
                      markers: markers,
                      myLocationEnabled: true,
                    ),
                  ),
                ),
              ),
            ],
        body: eczaneListView(dataList),
      ),
    );
  }

  //***************************************************************// */

  ListView eczaneListView(List<Data> dataList) {
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      itemCount: dataList.length,
      itemBuilder: (context, index) {
        var item = dataList[index];
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
                      widget.eczaneService.openMap(
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
                      widget.eczaneService.makePhoneCall(item.phone!);
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
