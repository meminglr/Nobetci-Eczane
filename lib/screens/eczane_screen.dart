import 'dart:math';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:expressive_loading_indicator/expressive_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:myapp/model/yeni_eczane_model.dart';
import 'package:myapp/services/yeni_eczane_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:myapp/home_controller.dart';
import 'package:myapp/widgets/companents.dart';

class EczaneScreen extends StatefulWidget {
  final HomeController controller;
  final YeniEczaneService eczaneService;
  final Companents companents;

  const EczaneScreen({
    super.key,
    required this.controller,
    required this.eczaneService,
    required this.companents,
  });

  @override
  State<EczaneScreen> createState() => _EczaneScreenState();
}

class _EczaneScreenState extends State<EczaneScreen> {
  final List<YeniEczane> eczaneList = [];
  List<YeniEczane> sortedDataList = [];
  bool isLoading = true;
  bool isGetiingLocation = false;
  GoogleMapController? mapController;
  Set<Marker> markers = const {};
  final ValueNotifier<double> _mapHeightNotifier = ValueNotifier<double>(300);
  late final ScrollController _scrollController = ScrollController();
  CustomInfoWindowController customInfoWindowController =
      CustomInfoWindowController();
  final double _minHeight = 170;
  final double _maxHeightByListScrool = 300;
  double get _maxHeightByDrag => MediaQuery.of(context).size.height * 0.6;
  LatLng? _initialCameraPosition;
  Position? _userPosition;
  final ValueNotifier<double> _fabOffsetNotifier = ValueNotifier<double>(0.0);
  double _lastScrollOffset = 0.0;
  BitmapDescriptor? customIcon;

  Future<void> fetchData() async {
    if (widget.controller.secilenSehir != null &&
        widget.controller.secilenIlce != null) {
      final fetchedData = await widget.eczaneService.getEczane(
        widget.controller.normalizeToEnglish(widget.controller.secilenSehir!),
        widget.controller.normalizeToEnglish(widget.controller.secilenIlce!),
      );
      setState(() {
        eczaneList.clear();
        eczaneList.addAll(fetchedData);
        sortedDataList = List.from(eczaneList);
        _initializeMarkersAndCamera();
        _updateUserLocationAndSort();
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCustomMarker();
    fetchData();
    _scrollController.addListener(_onScroll);
  }

  void _zoomIn() async {
    mapController!.animateCamera(CameraUpdate.zoomIn());
  }

  void _zoomOut() {
    mapController!.animateCamera(CameraUpdate.zoomOut());
  }

  Future<void> _requestLocationPermission() async {
    isGetiingLocation = true;
    setState(() {});
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
          CameraUpdate.newLatLngZoom(_initialCameraPosition!, 5),
        );
      }
    }
    isGetiingLocation = false;
    setState(() {});
  }

  Future<void> _updateUserLocationAndSort() async {
    isGetiingLocation = true;
    setState(() {});
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

      sortedDataList = List.from(eczaneList)
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
      final LatLngBounds bounds = await _calculateBounds(position);

      for (final eczane in sortedDataList) {
        final lat = eczane.latitude;
        final lng = eczane.longitude;
        if (lat != null && lng != null) {
          newMarkers.add(
            Marker(
              markerId: MarkerId(
                eczane.name ?? 'Eczane_${Random().nextInt(1000)}',
              ),
              icon: customIcon ?? BitmapDescriptor.defaultMarker,
              position: LatLng(lat, lng),
              infoWindow: InfoWindow(
                title: eczane.name,
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
        mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
      }
    } catch (e) {
      if (_initialCameraPosition != null && mapController != null) {
        mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(_initialCameraPosition!, 10),
        );
      }
    }
    isGetiingLocation = false;
    setState(() {});
  }

  Future<LatLngBounds> _calculateBounds(Position position) async {
    double minLat = position.latitude;
    double maxLat = position.latitude;
    double minLng = position.longitude;
    double maxLng = position.longitude;

    for (final eczane in sortedDataList) {
      final lat = eczane.latitude;
      final lng = eczane.longitude;
      if (lat != null && lng != null) {
        minLat = min(minLat, lat);
        maxLat = max(maxLat, lat);
        minLng = min(minLng, lng);
        maxLng = max(maxLng, lng);
      }
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  Future<void> _loadCustomMarker() async {
    customIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(48, 48)),
      "assets/icons/marker.png",
    );
    setState(() {});
  }

  void _initializeMarkersAndCamera() {
    double sumLat = 0;
    double sumLng = 0;
    int validCount = 0;

    for (final eczane in eczaneList) {
      final lat = eczane.latitude;
      final lng = eczane.longitude;
      if (lat != null && lng != null) {
        sumLat += lat;
        sumLng += lng;
        validCount++;
      }
    }

    _initialCameraPosition = validCount > 0
        ? LatLng(sumLat / validCount, sumLng / validCount)
        : const LatLng(39.0, 35.0);
  }

  void _onScroll() {
    _mapHeightNotifier.value =
        (_maxHeightByListScrool - _scrollController.offset).clamp(
          _minHeight,
          _maxHeightByListScrool,
        );

    final currentOffset = _scrollController.offset;
    if (currentOffset > _lastScrollOffset && currentOffset > 0) {
      _fabOffsetNotifier.value = 100.0; // Aşağı kaydırıldığında FAB kaybolur
    } else if (currentOffset < _lastScrollOffset) {
      _fabOffsetNotifier.value = 0.0; // Yukarı kaydırıldığında FAB görünür
    }
    _lastScrollOffset = currentOffset;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _mapHeightNotifier.dispose();
    _fabOffsetNotifier.dispose();
    mapController?.dispose();
    customInfoWindowController.dispose();
    super.dispose();
  }

  Widget _eczaneListView() => ListView.builder(
    controller: _scrollController,
    physics: const BouncingScrollPhysics(),
    padding: const EdgeInsets.only(bottom: 80.0), // FAB boyutuna eşdeğer boşluk
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
    floatingActionButton: ValueListenableBuilder<double>(
      valueListenable: _fabOffsetNotifier,
      builder: (context, offset, _) => AnimatedSlide(
        offset: Offset(0, offset / 50),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: widget.companents.floatingActionButton(
          context: context,
          companents: widget.companents,
          controller: widget.controller,
          onChanged2: () {
            isLoading = true;
            setState(() {
              fetchData();
            });
          },
          onChanged: () {
            setState(() {});
          },
        ),
      ),
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
            builder: (context, height, child) => AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeInOut,
              height: height,
              width: double.infinity,
              child: child, // child zaten tek seferlik oluşturulan map widget
            ),
            // child parametresi sadece bir kez oluşturulur, rebuild sırasında tekrar oluşturulmaz
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  _GoogleMapWidget(
                    markers: markers,
                    initialCameraPosition: _initialCameraPosition,
                    onMapCreated: (controller) {
                      mapController = controller;
                      _requestLocationPermission();
                    },
                  ),

                  Positioned(
                    top: 5,
                    right: 5,
                    child: FloatingActionButton.small(
                      onPressed: _updateUserLocationAndSort,
                      backgroundColor: Colors.blue[50],
                      child: isGetiingLocation
                          ? CircularProgressIndicator(
                              strokeWidth: 3,
                              padding: EdgeInsets.all(10),
                              color: Colors.blue,
                            )
                          : Icon(Icons.my_location, color: Colors.blue),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 5,
                    child: Column(
                      children: [
                        CustomInfoWindow(
                          controller: customInfoWindowController,
                          height: 200,
                          width: 200,
                          offset: 50,
                        ),
                        FloatingActionButton.small(
                          heroTag: "zoomIn",
                          onPressed: _zoomIn,
                          backgroundColor: Colors.white,
                          child: const Icon(Icons.add, color: Colors.black),
                        ),
                        FloatingActionButton.small(
                          heroTag: "zoomOut",
                          onPressed: _zoomOut,
                          backgroundColor: Colors.white,
                          child: const Icon(Icons.remove, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onVerticalDragUpdate: (details) {
            _mapHeightNotifier.value =
                (_mapHeightNotifier.value + details.delta.dy).clamp(
                  _minHeight,
                  _maxHeightByDrag,
                );
          },
          child: Container(
            height: 5,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        if (widget.controller.secilenSehir == null)
          Text(
            "İl Bilgisi Girin",
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.w700,
              fontSize: 30,
            ),
          )
        else if (widget.controller.secilenIlce == null)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on_outlined, color: Colors.red, size: 50),
                  Text(
                    "İlçe Bilgisi Girin",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w700,
                      fontSize: 30,
                    ),
                  ),
                ],
              ),
            ),
          )
        else if (isLoading)
          Expanded(
            child: Center(
              child: SizedBox(
                height: 100,
                width: 100,
                child: ExpressiveLoadingIndicator(
                  color: Colors.red,
                  // Accessibility
                  semanticsLabel: 'Loading',
                  semanticsValue: 'In progress',
                ),
              ),
            ),
          )
        else
          Expanded(child: _eczaneListView()),
        /*  Expanded(
          child: isLoading
              ? Center(
                  child: SizedBox(
                    height: 100,
                    width: 100,
                    child: ExpressiveLoadingIndicator(
                      color: Colors.red,
                      // Accessibility
                      semanticsLabel: 'Loading',
                      semanticsValue: 'In progress',
                    ),
                  ),
                )
              : _eczaneListView(),
        ),*/
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
      zoom: 4,
    ),
    markers: markers,
    myLocationEnabled: true,
    zoomControlsEnabled: false,
    myLocationButtonEnabled: false,
    mapType: MapType.normal,
    trafficEnabled: false,
    buildingsEnabled: false,
    indoorViewEnabled: false,
    scrollGesturesEnabled: true,
    zoomGesturesEnabled: true,
  );
}

class _EczaneListItem extends StatelessWidget {
  final YeniEczane item;
  final YeniEczaneService eczaneService;
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

  static final Icon _mapIcon = Icon(
    Icons.map_outlined,
    color: Colors.blue[100],
  );
  static final Text _mapText = Text(
    "Harita",
    style: TextStyle(color: Colors.blue[100]),
  );
  static final Icon _callIcon = Icon(
    Icons.call_outlined,
    color: Colors.green[100],
  );
  static final Text _callText = Text(
    "Ara",
    style: TextStyle(color: Colors.green[100]),
  );

  String _getDistanceText() {
    if (userPosition == null ||
        item.latitude == null ||
        item.longitude == null) {
      return '-.-- km';
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
    child: ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 100),
      child: IntrinsicHeight(
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
                    children: [
                      _mapIcon,
                      _mapText,
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blue[300],
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          child: Text(
                            _getDistanceText(),
                            style: TextStyle(
                              color: Colors.blue[100],
                              fontSize: 10,
                            ),
                          ),
                        ),
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
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name ?? 'Bilinmeyen Eczane',
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
                    children: [_callIcon, _callText],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
