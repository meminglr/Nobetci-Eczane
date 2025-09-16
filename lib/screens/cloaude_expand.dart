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

class ClaudeExpand extends StatefulWidget {
  final HomeController controller;
  final EczaneService eczaneService;
  final Companents companents;

  const ClaudeExpand({
    super.key,
    required this.controller,
    required this.eczaneService,
    required this.companents,
  });

  @override
  State<ClaudeExpand> createState() => _ClaudeExpandState();
}

class _ClaudeExpandState extends State<ClaudeExpand>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  // Cache optimizasyonu için
  static final Map<String, BitmapDescriptor> _markerCache = {};
  static final Map<String, String> _distanceCache = {};

  final List<Data> dataList = DataList().dataList;
  List<Data> sortedDataList = [];
  GoogleMapController? mapController;
  Set<Marker> markers = const {};

  // Animation controller ile smooth animasyon
  late AnimationController _animationController;
  late Animation<double> _mapHeightAnimation;
  late Animation<double> _fabAnimation;

  late final ScrollController _scrollController = ScrollController();
  final double _minHeight = 100;
  final double _maxHeight = 300;
  LatLng? _initialCameraPosition;
  Position? _userPosition;

  // Scroll throttling için
  DateTime _lastScrollUpdate = DateTime.now();
  static const Duration _scrollThrottleDuration = Duration(
    milliseconds: 16,
  ); // 60 FPS

  // Build optimization için cached widgets
  late Widget _cachedAppBar;
  late Widget _cachedFAB;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    sortedDataList = List.from(dataList);

    // Animation controller setup
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _mapHeightAnimation = Tween<double>(begin: _maxHeight, end: _maxHeight)
        .animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _fabAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scrollController.addListener(_onScrollThrottled);

    // Cache static widgets
    _cacheStaticWidgets();

    // Initialize markers asynchronously
    _initializeMarkersAndCamera();
  }

  void _cacheStaticWidgets() {
    _cachedAppBar = AppBar(
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
    );

    _cachedFAB = widget.companents.floatingActionButton(
      context: context,
      companents: widget.companents,
      controller: widget.controller,
      onChanged: () {},
    );
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      await _updateUserLocationAndSort();
    } else if (status.isDenied || status.isPermanentlyDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              status.isPermanentlyDenied
                  ? 'Konum izni kalıcı olarak reddedildi. Lütfen ayarlarınızı kontrol edin.'
                  : 'Konum izni reddedildi. Harita varsayılan konumu gösterecek.',
            ),
          ),
        );
      }
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
        desiredAccuracy: LocationAccuracy.medium, // High yerine medium kullan
      );

      if (!mounted) return;

      _userPosition = position;

      // Distance cache temizle
      _distanceCache.clear();

      // Parallel processing için compute kullanabilirsin (isolate)
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

      await _updateMarkers(position);
    } catch (e) {
      if (_initialCameraPosition != null && mapController != null) {
        mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(_initialCameraPosition!, 10),
        );
      }
    }
  }

  Future<void> _updateMarkers(Position position) async {
    final newMarkers = <Marker>{};
    final LatLngBounds bounds = await _calculateBounds(position);

    // Batch marker creation
    for (int i = 0; i < sortedDataList.length; i++) {
      final eczane = sortedDataList[i];
      final lat = eczane.latitude;
      final lng = eczane.longitude;

      if (lat != null && lng != null) {
        final markerId = eczane.pharmacyName ?? 'Eczane_$i';

        newMarkers.add(
          Marker(
            markerId: MarkerId(markerId),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(
              title: eczane.pharmacyName,
              snippet: eczane.address,
            ),
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        markers = newMarkers;
      });

      if (mapController != null) {
        mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
      }
    }
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

    // Minimum bounds padding
    const padding = 0.01;
    return LatLngBounds(
      southwest: LatLng(minLat - padding, minLng - padding),
      northeast: LatLng(maxLat + padding, maxLng + padding),
    );
  }

  void _initializeMarkersAndCamera() {
    final newMarkers = <Marker>{};
    double sumLat = 0;
    double sumLng = 0;
    int validCount = 0;

    for (int i = 0; i < dataList.length; i++) {
      final eczane = dataList[i];
      final lat = eczane.latitude;
      final lng = eczane.longitude;

      if (lat != null && lng != null) {
        final markerId = eczane.pharmacyName ?? 'Eczane_$i';

        newMarkers.add(
          Marker(
            markerId: MarkerId(markerId),
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

    if (mounted) {
      setState(() => markers = newMarkers);
    }
  }

  void _onScrollThrottled() {
    final now = DateTime.now();
    if (now.difference(_lastScrollUpdate) < _scrollThrottleDuration) {
      return;
    }
    _lastScrollUpdate = now;

    _onScroll();
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    final newHeight = (_maxHeight - offset).clamp(_minHeight, _maxHeight);

    // Update animations
    _mapHeightAnimation =
        Tween<double>(begin: _mapHeightAnimation.value, end: newHeight).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    final fabOffset = offset > 50 ? 1.0 : 0.0;
    _fabAnimation = Tween<double>(begin: _fabAnimation.value, end: fabOffset)
        .animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );

    _animationController.forward(from: 0);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    mapController?.dispose();
    super.dispose();
  }

  Widget _buildEczaneListView() {
    return ListView.builder(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 80.0),
      itemCount: sortedDataList.length,
      cacheExtent: 500, // Cache more items for smooth scrolling
      itemBuilder: (context, index) => _OptimizedEczaneListItem(
        key: ValueKey('${sortedDataList[index].pharmacyName}_$index'),
        item: sortedDataList[index],
        eczaneService: widget.eczaneService,
        userPosition: _userPosition,
        distanceCache: _distanceCache,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // AutomaticKeepAliveClientMixin için gerekli

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AnimatedBuilder(
        animation: _fabAnimation,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, _fabAnimation.value * 100),
          child: _cachedFAB,
        ),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: AnimatedBuilder(
              animation: _mapHeightAnimation,
              builder: (context, child) => SizedBox(
                height: _mapHeightAnimation.value,
                width: double.infinity,
                child: child,
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                child: _GoogleMapWidget(
                  key: const ValueKey('google_map'),
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
          Expanded(child: _buildEczaneListView()),
        ],
      ),
    );
  }
}

class _GoogleMapWidget extends StatelessWidget {
  final Set<Marker> markers;
  final LatLng? initialCameraPosition;
  final ValueChanged<GoogleMapController> onMapCreated;

  const _GoogleMapWidget({
    super.key,
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
    compassEnabled: false,
    mapToolbarEnabled: false,
    trafficEnabled: false,
    buildingsEnabled: false,
    indoorViewEnabled: false,
  );
}

class _OptimizedEczaneListItem extends StatelessWidget {
  final Data item;
  final EczaneService eczaneService;
  final Position? userPosition;
  final Map<String, String> distanceCache;

  const _OptimizedEczaneListItem({
    super.key,
    required this.item,
    required this.eczaneService,
    this.userPosition,
    required this.distanceCache,
  });

  // Constant widgets for better performance
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
    size: 24,
  );

  static const Text _mapText = Text(
    "Harita",
    style: TextStyle(color: Color(0xFFBBDEFB), fontSize: 12),
  );

  static const Icon _callIcon = Icon(
    Icons.call_outlined,
    color: Color(0xFF81C784),
    size: 24,
  );

  static const Text _callText = Text(
    "Ara",
    style: TextStyle(color: Color(0xFF81C784), fontSize: 12),
  );

  String _getDistanceText() {
    if (userPosition == null ||
        item.latitude == null ||
        item.longitude == null) {
      return 'Mesafe bilinmiyor';
    }

    final cacheKey =
        '${item.latitude}_${item.longitude}_${userPosition!.latitude}_${userPosition!.longitude}';

    if (distanceCache.containsKey(cacheKey)) {
      return distanceCache[cacheKey]!;
    }

    final distance = Geolocator.distanceBetween(
      userPosition!.latitude,
      userPosition!.longitude,
      item.latitude!,
      item.longitude!,
    );

    final distanceText = '${(distance / 1000).toStringAsFixed(2)} km';
    distanceCache[cacheKey] = distanceText;

    return distanceText;
  }

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.all(8),
    height: 100,
    child: Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: item.latitude != null && item.longitude != null
                ? () => eczaneService.openMap(item.latitude!, item.longitude!)
                : null,
            child: Container(
              decoration: _mapDecoration,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [_mapIcon, SizedBox(height: 4), _mapText],
              ),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Container(
            decoration: _infoDecoration,
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.pharmacyName ?? 'Bilinmeyen Eczane',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  item.address ?? 'Adres Yok',
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _getDistanceText(),
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: item.phone != null
                ? () => eczaneService.makePhoneCall(item.phone!)
                : null,
            child: Container(
              decoration: _callDecoration,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [_callIcon, SizedBox(height: 4), _callText],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
