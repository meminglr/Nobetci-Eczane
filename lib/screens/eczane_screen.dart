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
  bool isMapFullHeight = false;

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

      for (int i = 0; i < sortedDataList.length; i++) {
        final eczane = sortedDataList[i];
        final lat = eczane.latitude;
        final lng = eczane.longitude;
        if (lat != null && lng != null) {
          final markerPosition = LatLng(lat, lng);
          newMarkers.add(
            Marker(
              markerId: MarkerId(
                eczane.name ?? 'Eczane_${Random().nextInt(1000)}',
              ),
              icon: customIcon ?? BitmapDescriptor.defaultMarker,
              position: markerPosition,
              infoWindow: InfoWindow.noText,
              onTap: () {
                customInfoWindowController.addInfoWindow!(
                  _EczaneListItem(
                    item: eczane,
                    eczaneService: widget.eczaneService,
                    userPosition: _userPosition,
                    isCompact: true,
                    isNearest: i == 0,
                  ),
                  markerPosition,
                );
              },
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
      isNearest: index == 0,
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
                      customInfoWindowController.googleMapController =
                          controller;
                      _requestLocationPermission();
                    },
                    onTap: (position) {
                      customInfoWindowController.hideInfoWindow!();
                    },
                    onCameraMove: (position) {
                      customInfoWindowController.onCameraMove!();
                    },
                  ),

                  CustomInfoWindow(
                    height: 100,
                    width: 300,
                    offset: 50,

                    controller: customInfoWindowController,
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
                  Positioned(
                    left: 5,
                    top: 5,
                    child: FloatingActionButton.small(
                      onPressed: () {
                        isMapFullHeight = !isMapFullHeight;
                        setState(() {});
                        if (isMapFullHeight) {
                          _mapHeightNotifier.value = _minHeight;
                        } else {
                          _mapHeightNotifier.value = _maxHeightByDrag;
                        }
                      },
                      backgroundColor: Colors.white,
                      child: isMapFullHeight
                          ? Icon(Icons.arrow_downward, color: Colors.black)
                          : Icon(Icons.arrow_upward, color: Colors.black),
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
            margin: EdgeInsets.all(3),
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

// Removed redundant custom info window widget in favor of reusing _EczaneListItem

class _GoogleMapWidget extends StatelessWidget {
  final Set<Marker> markers;
  final LatLng? initialCameraPosition;
  final ValueChanged<GoogleMapController> onMapCreated;
  final ValueChanged<LatLng>? onTap;
  final ValueChanged<CameraPosition>? onCameraMove;

  const _GoogleMapWidget({
    required this.markers,
    required this.initialCameraPosition,
    required this.onMapCreated,
    this.onTap,
    this.onCameraMove,
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
    onTap: onTap,
    onCameraMove: onCameraMove,
  );
}

class _EczaneListItem extends StatelessWidget {
  final YeniEczane item;
  final YeniEczaneService eczaneService;
  final Position? userPosition;
  final bool isCompact;
  final bool isNearest;

  const _EczaneListItem({
    required this.item,
    required this.eczaneService,
    this.userPosition,
    this.isCompact = false,
    this.isNearest = false,
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
    "Yol Tarifi",
    maxLines: 1,

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
  Widget build(BuildContext context) => isCompact
      ? _buildCompact(context)
      : Padding(
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
                          ? () => eczaneService.openMap(
                              item.latitude!,
                              item.longitude!,
                            )
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
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8),
                                ),
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
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.name ?? 'Bilinmeyen Eczane',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              item.address ?? 'Adres Yok',
                              style: const TextStyle(fontSize: 10),
                            ),
                            SizedBox(height: 5),
                            if (isNearest)
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.red[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.redAccent,
                                    width: 0.8,
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                child: const Text(
                                  'En Yakın',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
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

extension on _EczaneListItem {
  Widget _buildCompact(BuildContext context) => Material(
    elevation: 5,
    borderRadius: BorderRadius.all(Radius.circular(12)),
    color: Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name ?? 'Eczane',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                Text(
                  item.address ?? 'Adres yok',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: Colors.black87),
                ),

                Row(
                  spacing: 4,
                  children: [
                    if (isNearest)
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0, bottom: 4.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.redAccent,
                              width: 0.6,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          child: const Text(
                            'En Yakın',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                    Padding(
                      padding: const EdgeInsets.only(top: 2.0, bottom: 4.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.blueAccent,
                            width: 0.6,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        child: Text(
                          _getDistanceText(),
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              spacing: 4,
              children: [
                Expanded(
                  child: IconButton(
                    onPressed: item.latitude != null && item.longitude != null
                        ? () => eczaneService.openMap(
                            item.latitude!,
                            item.longitude!,
                          )
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.blue[100],
                    ),
                    icon: const Icon(Icons.directions_outlined),
                  ),
                ),
                Expanded(
                  child: IconButton(
                    onPressed: item.phone != null
                        ? () => eczaneService.makePhoneCall(item.phone!)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.green[100],
                    ),
                    icon: const Icon(Icons.call_outlined),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
