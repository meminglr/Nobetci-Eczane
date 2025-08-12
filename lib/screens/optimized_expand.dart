import 'dart:math';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:myapp/home_controller.dart';
import 'package:myapp/model/eczane_model.dart';
import 'package:myapp/services/eczane_service.dart';
import 'package:myapp/widgets/companents.dart';
import 'package:myapp/widgets/example_list.dart';
import 'package:geolocator/geolocator.dart';

class OptimizedExpand extends StatefulWidget {
  final HomeController controller;
  final EczaneService eczaneService;
  final Companents companents;

  const OptimizedExpand({
    super.key,
    required this.controller,
    required this.eczaneService,
    required this.companents,
  });

  @override
  State<OptimizedExpand> createState() => _OptimizedExpandState();
}

class _OptimizedExpandState extends State<OptimizedExpand> {
  List<Data> dataList = DataList().dataList;
  List<Data> eczaneListesi = [];
  bool isLoading = false;
  GoogleMapController? mapController;
  Set<Marker> markers = {};
  final _mapHeightNotifier = ValueNotifier<double>(300);
  late ScrollController _scrollController;
  final double _minHeight = 100;
  final double _maxHeight = 300;

  @override
  void initState() {
    super.initState();
    requestLocationPermission();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  Future<void> requestLocationPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      goToMyLocation(mapController);
    }
  }

  Future<void> goToMyLocation(dynamic mapcontroller) async {
    Position position = await Geolocator.getCurrentPosition(
      // ignore: deprecated_member_use
      desiredAccuracy: LocationAccuracy.high,
    );
    mapcontroller?.animateCamera(
      CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)),
    );
  }

  void _onScroll() {
    final newHeight = (_maxHeight - _scrollController.offset).clamp(
      _minHeight,
      _maxHeight,
    );
    _mapHeightNotifier.value = newHeight; // Synchronous update
  }

  Future<void> _loadEczaneler() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    final result = await widget.eczaneService.getEczane(
      widget.controller.normalizeToEnglish(
        widget.controller.secilenSehir ?? '',
      ),
      widget.controller.normalizeToEnglish(widget.controller.secilenIlce ?? ''),
    );
    if (!mounted) return;

    final newMarkers = <Marker>{};
    for (var eczane in dataList) {
      if (eczane.latitude != null && eczane.longitude != null) {
        newMarkers.add(
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
      eczaneListesi = result;
      markers = newMarkers;
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _mapHeightNotifier.dispose();
    mapController?.dispose();
    super.dispose();
  }

  Widget eczaneListView(List<Data> dataList) {
    return ListView.builder(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      itemCount: dataList.length,
      itemBuilder: (context, index) {
        return _EczaneListItem(
          item: dataList[index],
          eczaneService: widget.eczaneService,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: widget.companents.floatingActionButton(
        context: context,
        companents: widget.companents,
        controller: widget.controller,
        onChanged: _loadEczaneler,
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
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ValueListenableBuilder<double>(
              valueListenable: _mapHeightNotifier,
              builder: (context, height, child) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 16), // 60 FPS
                  curve: Curves.linear,
                  height: height,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    child: _GoogleMapWidget(
                      dataList: dataList,
                      markers: markers,
                      onMapCreated: (controller) => mapController = controller,
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : eczaneListView(dataList),
          ),
        ],
      ),
    );
  }
}

class _GoogleMapWidget extends StatelessWidget {
  final List<Data> dataList;
  final Set<Marker> markers;
  final ValueChanged<GoogleMapController> onMapCreated;

  const _GoogleMapWidget({
    required this.dataList,
    required this.markers,
    required this.onMapCreated,
  });

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: onMapCreated,
      initialCameraPosition: CameraPosition(
        target: LatLng(
          dataList.isNotEmpty ? dataList.first.latitude ?? 0 : 0,
          dataList.isNotEmpty ? dataList.first.longitude ?? 0 : 0,
        ),
        zoom: 13,
      ),
      markers: markers,
      myLocationEnabled: true,
      zoomControlsEnabled: false,
    );
  }
}

class _EczaneListItem extends StatelessWidget {
  final Data item;
  final EczaneService eczaneService;

  const _EczaneListItem({required this.item, required this.eczaneService});

  static const _mapDecoration = BoxDecoration(
    color: Colors.blue,
    borderRadius: BorderRadius.horizontal(
      left: Radius.circular(20),
      right: Radius.circular(5),
    ),
  );

  static const _infoDecoration = BoxDecoration(
    color: Color(0xFFF5F5F5), // Colors.grey[100]
    borderRadius: BorderRadius.all(Radius.circular(5)),
  );

  static const _callDecoration = BoxDecoration(
    color: Colors.green,
    borderRadius: BorderRadius.horizontal(
      right: Radius.circular(20),
      left: Radius.circular(5),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: 100,
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: GestureDetector(
                onTap: item.latitude != null && item.longitude != null
                    ? () =>
                          eczaneService.openMap(item.latitude!, item.longitude!)
                    : null,
                child: Container(
                  decoration: _mapDecoration,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.map_outlined,
                        color: Color(0xFFBBDEFB),
                      ), // Colors.blue[100]
                      Text(
                        "Harita",
                        style: TextStyle(color: Color(0xFFBBDEFB)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                decoration: _infoDecoration,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.pharmacyName ?? 'Bilinmeyen Eczane',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        item.address ?? 'Adres Yok',
                        style: const TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: GestureDetector(
                onTap: item.phone != null
                    ? () => eczaneService.makePhoneCall(item.phone!)
                    : null,
                child: Container(
                  decoration: _callDecoration,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.call_outlined,
                        color: Color(0xFF81C784),
                      ), // Colors.green[100]
                      Text("Ara", style: TextStyle(color: Color(0xFF81C784))),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
