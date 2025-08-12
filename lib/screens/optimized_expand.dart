import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:myapp/home_controller.dart';
import 'package:myapp/model/eczane_model.dart';
import 'package:myapp/services/eczane_service.dart';
import 'package:myapp/widgets/companents.dart';
import 'package:myapp/widgets/example_list.dart';

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
  final List<Data> dataList = DataList().dataList;
  List<Data> sortedDataList = [];
  GoogleMapController? mapController;
  Set<Marker> markers = const {};
  final ValueNotifier<double> _mapHeightNotifier = ValueNotifier<double>(300);
  late final ScrollController _scrollController = ScrollController();
  final double _minHeight = 100;
  final double _maxHeight = 300;
  LatLng? _initialCameraPosition;
  Position? _userPosition;

  @override
  void initState() {
    super.initState();
    sortedDataList = List.from(dataList);
    _scrollController.addListener(_onScroll);
    _initializeMarkersAndCamera();
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      await _updateUserLocationAndSort();
    } else if (status.isDenied || status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status.isPermanentlyDenied
                ? 'Konum izni kalıcı olarak reddedildi. Lütfen ayarlarınızı kontrol edin.'
                : 'Konum izni reddedildi. Harita varsayılan konumu gösterecek.',
          ),
        ),
      );
      if (_initialCameraPosition != null && mapController != null) {
        mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(_initialCameraPosition!, 10),
        );
      }
    }
  }

  Future<void> _updateUserLocationAndSort() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (_initialCameraPosition != null && mapController != null) {
          mapController!.animateCamera(
            CameraUpdate.newLatLngZoom(_initialCameraPosition!, 10),
          );
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _userPosition = position;

      sortedDataList = List.from(dataList)
        ..sort((a, b) {
          if (a.latitude == null || a.longitude == null) return 1;
          if (b.latitude == null || b.longitude == null) return -1;
          final distanceA = Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
            a.latitude!,
            a.longitude!,
          );
          final distanceB = Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
            b.latitude!,
            b.longitude!,
          );
          return distanceA.compareTo(distanceB);
        });

      final newMarkers = <Marker>{};
      for (final eczane in sortedDataList) {
        final lat = eczane.latitude;
        final lng = eczane.longitude;
        if (lat != null && lng != null) {
          newMarkers.add(
            Marker(
              markerId: MarkerId(
                eczane.pharmacyName ?? 'Eczane_${Random().nextInt(1000)}',
              ),
              position: LatLng(lat, lng),
              infoWindow: InfoWindow(
                title: eczane.pharmacyName,
                snippet: eczane.address,
              ),
            ),
          );
        }
      }

      setState(() {
        markers = newMarkers;
      });

      if (mapController != null) {
        mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(position.latitude, position.longitude),
            14,
          ),
        );
      }
    } catch (e) {
      if (_initialCameraPosition != null && mapController != null) {
        mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(_initialCameraPosition!, 10),
        );
      }
    }
  }

  void _initializeMarkersAndCamera() {
    final newMarkers = <Marker>{};
    double sumLat = 0;
    double sumLng = 0;
    int validCount = 0;

    for (final eczane in dataList) {
      final lat = eczane.latitude;
      final lng = eczane.longitude;
      if (lat != null && lng != null) {
        newMarkers.add(
          Marker(
            markerId: MarkerId(
              eczane.pharmacyName ?? 'Eczane_${Random().nextInt(1000)}',
            ),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(
              title: eczane.pharmacyName,
              snippet: eczane.address,
            ),
          ),
        );
        sumLat += lat;
        sumLng += lng;
        validCount++;
      }
    }

    _initialCameraPosition = validCount > 0
        ? LatLng(sumLat / validCount, sumLng / validCount)
        : const LatLng(39.0, 35.0);

    setState(() => markers = newMarkers);
  }

  void _onScroll() {
    _mapHeightNotifier.value = (_maxHeight - _scrollController.offset).clamp(
      _minHeight,
      _maxHeight,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _mapHeightNotifier.dispose();
    mapController?.dispose();
    super.dispose();
  }

  Widget _eczaneListView() => ListView.builder(
    controller: _scrollController,
    physics: const BouncingScrollPhysics(),
    itemCount: sortedDataList.length,
    itemBuilder: (context, index) => _EczaneListItem(
      item: sortedDataList[index],
      eczaneService: widget.eczaneService,
      userPosition: _userPosition,
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    floatingActionButton: widget.companents.floatingActionButton(
      context: context,
      companents: widget.companents,
      controller: widget.controller,
      onChanged: () {},
    ),
    backgroundColor: Colors.white,
    appBar: AppBar(
      scrolledUnderElevation: 0,
      centerTitle: true,
      title: const Text(
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
          padding: const EdgeInsets.all(8),
          child: ValueListenableBuilder<double>(
            valueListenable: _mapHeightNotifier,
            builder: (context, height, _) => AnimatedContainer(
              duration: const Duration(milliseconds: 16),
              curve: Curves.linear,
              height: height,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                child: _GoogleMapWidget(
                  markers: markers,
                  initialCameraPosition: _initialCameraPosition,
                  onMapCreated: (controller) {
                    mapController = controller;
                    _requestLocationPermission();
                  },
                ),
              ),
            ),
          ),
        ),
        Expanded(child: _eczaneListView()),
      ],
    ),
  );
}

class _GoogleMapWidget extends StatelessWidget {
  final Set<Marker> markers;
  final LatLng? initialCameraPosition;
  final ValueChanged<GoogleMapController> onMapCreated;

  const _GoogleMapWidget({
    required this.markers,
    required this.initialCameraPosition,
    required this.onMapCreated,
  });

  @override
  Widget build(BuildContext context) => GoogleMap(
    onMapCreated: onMapCreated,
    initialCameraPosition: CameraPosition(
      target: initialCameraPosition ?? const LatLng(39.0, 35.0),
      zoom: 10,
    ),
    markers: markers,
    myLocationEnabled: true,
    zoomControlsEnabled: false,
  );
}

class _EczaneListItem extends StatelessWidget {
  final Data item;
  final EczaneService eczaneService;
  final Position? userPosition;

  const _EczaneListItem({
    required this.item,
    required this.eczaneService,
    this.userPosition,
  });

  static const BoxDecoration _mapDecoration = BoxDecoration(
    color: Colors.blue,
    borderRadius: BorderRadius.horizontal(
      left: Radius.circular(20),
      right: Radius.circular(5),
    ),
  );

  static const BoxDecoration _infoDecoration = BoxDecoration(
    color: Color(0xFFF5F5F5),
    borderRadius: BorderRadius.all(Radius.circular(5)),
  );

  static const BoxDecoration _callDecoration = BoxDecoration(
    color: Colors.green,
    borderRadius: BorderRadius.horizontal(
      right: Radius.circular(20),
      left: Radius.circular(5),
    ),
  );

  static const Icon _mapIcon = Icon(
    Icons.map_outlined,
    color: Color(0xFFBBDEFB),
  );
  static const Text _mapText = Text(
    "Harita",
    style: TextStyle(color: Color(0xFFBBDEFB)),
  );
  static const Icon _callIcon = Icon(
    Icons.call_outlined,
    color: Color(0xFF81C784),
  );
  static const Text _callText = Text(
    "Ara",
    style: TextStyle(color: Color(0xFF81C784)),
  );

  String _getDistanceText() {
    if (userPosition == null ||
        item.latitude == null ||
        item.longitude == null) {
      return 'Mesafe bilinmiyor';
    }
    final distance = Geolocator.distanceBetween(
      userPosition!.latitude,
      userPosition!.longitude,
      item.latitude!,
      item.longitude!,
    );
    return '${(distance / 1000).toStringAsFixed(2)} km';
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(8),
    child: SizedBox(
      height: 100,
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: item.latitude != null && item.longitude != null
                  ? () => eczaneService.openMap(item.latitude!, item.longitude!)
                  : null,
              child: Container(
                decoration: _mapDecoration,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [_mapIcon, _mapText],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              decoration: _infoDecoration,
              child: Padding(
                padding: const EdgeInsets.all(8),
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
                    Text(
                      _getDistanceText(),
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
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
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [_callIcon, _callText],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
