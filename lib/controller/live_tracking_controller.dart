import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:customerparkapp/constant/constant.dart';
import 'package:customerparkapp/model/order_model.dart';
import 'package:customerparkapp/themes/app_them_data.dart';

class LiveTrackingController extends GetxController {
  Rx<OrderModel> orderModel = OrderModel().obs;
  RxBool isLoading = true.obs;
  RxString distance = "0.0".obs;
  late MapController mapOsmController;
  Rx<RoadInfo> roadInfo = RoadInfo().obs;
  Map<String, GeoPoint> osmMarkers = <String, GeoPoint>{};
  Image? departureOsmIcon; //OSM
  Image? destinationOsmIcon; //OSM
  Image? driverOsmIcon;
  @override
  void onInit() {
    // TODO: implement onInit
    addMarkerSetup();
    getArgument();

    super.onInit();
  }

  getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      orderModel.value = argumentData['orderModel'];
      mapOsmController = MapController(
          initPosition: GeoPoint(latitude: orderModel.value.parkingDetails!.location!.latitude!, longitude: orderModel.value.parkingDetails!.location!.longitude!),
          );
    }
    getLocation();
    isLoading.value = false;
    update();
  }

  getLocation() {
    LocationSettings locationSettings = LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: int.parse(Constant.locationUpdate.toString()));
    Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position? position) {
      if (position != null) {
        print("-->${position.latitude}--${Constant.selectedMapType}");
        print("-->${orderModel.value.parkingDetails!.location!.latitude}--${orderModel.value.parkingDetails!.location!.longitude}");
        print("-->${position.latitude}--${position.longitude}");
        if (Constant.selectedMapType != 'osm') {
          getPolyline(
              sourceLatitude: orderModel.value.parkingDetails!.location!.latitude,
              sourceLongitude: orderModel.value.parkingDetails!.location!.longitude,
              destinationLatitude: position.latitude,
              destinationLongitude: position.longitude,
              heading: position.heading);
        } else {
          getOSMPolyline(
            sourceLatitude: orderModel.value.parkingDetails!.location!.latitude,
            sourceLongitude: orderModel.value.parkingDetails!.location!.longitude,
            destinationLatitude: position.latitude,
            destinationLongitude: position.longitude,
          );
        }
        distance.value =
            calculateDistance(orderModel.value.parkingDetails!.location!.latitude, orderModel.value.parkingDetails!.location!.longitude, position.latitude, position.longitude)
                .toString();
      }
    });
  }

  RxMap<PolylineId, Polyline> polyLines = <PolylineId, Polyline>{}.obs;
  PolylinePoints polylinePoints = PolylinePoints();
  GoogleMapController? mapController;

  void getPolyline(
      {required double? sourceLatitude,
      required double? sourceLongitude,
      required double? destinationLatitude,
      required double? destinationLongitude,
      required double heading}) async {
    if (sourceLatitude != null && sourceLongitude != null && destinationLatitude != null && destinationLongitude != null) {
      List<LatLng> polylineCoordinates = [];

      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
          // Constant.mapAPIKey,
          // PointLatLng(sourceLatitude, sourceLongitude),
          // PointLatLng(destinationLatitude, sourceLongitude),
          // travelMode: TravelMode.driving,
          googleApiKey: Constant.mapAPIKey,
          request:
              PolylineRequest(origin: PointLatLng(sourceLatitude, sourceLongitude), destination: PointLatLng(destinationLatitude, destinationLongitude), mode: TravelMode.driving));

      if (result.points.isNotEmpty) {
        for (var point in result.points) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }
      }

      addMarker(latitude: sourceLatitude, longitude: sourceLongitude, id: "Destination", descriptor: destinationIcon!, rotation: 0.0);
      addMarker(latitude: destinationLatitude, longitude: destinationLongitude, id: "Departure", descriptor: departureIcon!, rotation: heading);

      _addPolyLine(polylineCoordinates, destinationLatitude: destinationLatitude, destinationLongitude: destinationLongitude, heading: heading);
      update();
    }
  }

  BitmapDescriptor? departureIcon;
  BitmapDescriptor? destinationIcon;
  RxMap<MarkerId, Marker> markers = <MarkerId, Marker>{}.obs;

  addMarkerSetup() async {
    if (Constant.selectedMapType.toString() != 'osm') {
      final Uint8List destination = await Constant().getBytesFromAsset('assets/images/ic_parking_location.png', 200);
      final Uint8List departure = await Constant().getBytesFromAsset('assets/images/ic_car_driver.png', 100);
      destinationIcon = BitmapDescriptor.fromBytes(destination);
      departureIcon = BitmapDescriptor.fromBytes(departure);
    } else {
      departureOsmIcon = Image.asset("assets/images/ic_car_driver.png", width: 40, height: 40); //OSM
      destinationOsmIcon = Image.asset("assets/images/ic_parking_location.png", width: 40, height: 40); //OSM
    }
  }

  addMarker({required double? latitude, required double? longitude, required String id, required BitmapDescriptor descriptor, required double? rotation}) {
    MarkerId markerId = MarkerId(id);
    Marker marker = Marker(markerId: markerId, icon: descriptor, position: LatLng(latitude ?? 0.0, longitude ?? 0.0), rotation: rotation ?? 0.0);
    markers[markerId] = marker;
  }

  _addPolyLine(List<LatLng> polylineCoordinates, {required double? destinationLatitude, required double? destinationLongitude, required double heading}) {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      points: polylineCoordinates,
      consumeTapEvents: true,
      startCap: Cap.roundCap,
      color: AppThemData.primary06,
      width: 8,
    );
    polyLines[id] = polyline;

    updateCameraLocation(heading: heading, destinationLongitude: destinationLongitude, destinationLatitude: destinationLatitude);
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p) / 2 + c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  Future<void> updateCameraLocation({required double? destinationLatitude, required double? destinationLongitude, required double heading}) async {
    mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(destinationLatitude!, destinationLongitude!),
          zoom: 15,
          bearing: heading,
        ),
      ),
    );
    // if (mapController == null) return;
    //
    // LatLngBounds bounds;
    //
    // if (source.latitude > destination.latitude && source.longitude > destination.longitude) {
    //   bounds = LatLngBounds(southwest: destination, northeast: source);
    // } else if (source.longitude > destination.longitude) {
    //   bounds = LatLngBounds(southwest: LatLng(source.latitude, destination.longitude), northeast: LatLng(destination.latitude, source.longitude));
    // } else if (source.latitude > destination.latitude) {
    //   bounds = LatLngBounds(southwest: LatLng(destination.latitude, source.longitude), northeast: LatLng(source.latitude, destination.longitude));
    // } else {
    //   bounds = LatLngBounds(southwest: source, northeast: destination);
    // }
    //
    // CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 10);
    //
    // return checkCameraLocation(cameraUpdate, mapController);
  }

  void getOSMPolyline({
    required double? sourceLatitude,
    required double? sourceLongitude,
    required double? destinationLatitude,
    required double? destinationLongitude,
  }) async {
    try {
      await mapOsmController.removeLastRoad();
      roadInfo.value = await mapOsmController.drawRoad(
        GeoPoint(latitude: sourceLatitude!, longitude: sourceLongitude!),
        GeoPoint(latitude: destinationLatitude!, longitude: destinationLongitude!),
        roadType: RoadType.car,
      );
      setOsmMarker(
        departure: GeoPoint(latitude: sourceLatitude, longitude: sourceLongitude),
        destination: GeoPoint(latitude: destinationLatitude, longitude: destinationLongitude),
      );
      mapOsmController.goToLocation(
        GeoPoint(latitude: destinationLatitude, longitude: destinationLongitude),

      );
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> updateOSMCameraLocation({required GeoPoint source, required GeoPoint destination}) async {
    BoundingBox bounds;

    if (source.latitude > destination.latitude && source.longitude > destination.longitude) {
      bounds = BoundingBox(
        north: source.latitude,
        south: destination.latitude,
        east: source.longitude,
        west: destination.longitude,
      );
    } else if (source.longitude > destination.longitude) {
      bounds = BoundingBox(
        north: destination.latitude,
        south: source.latitude,
        east: source.longitude,
        west: destination.longitude,
      );
    } else if (source.latitude > destination.latitude) {
      bounds = BoundingBox(
        north: source.latitude,
        south: destination.latitude,
        east: destination.longitude,
        west: source.longitude,
      );
    } else {
      bounds = BoundingBox(
        north: destination.latitude,
        south: source.latitude,
        east: destination.longitude,
        west: source.longitude,
      );
    }

    await mapOsmController.zoomToBoundingBox(bounds, paddinInPixel: 100);
  }

  setOsmMarker({required GeoPoint departure, required GeoPoint destination}) async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (osmMarkers.containsKey('Departure')) {
        await mapOsmController.removeMarker(osmMarkers['Departure']!);
      }
      await mapOsmController
          .addMarker(departure,
              markerIcon: MarkerIcon(iconWidget: departureOsmIcon),
              angle: pi / 3,
              iconAnchor: IconAnchor(
                anchor: Anchor.top,
              ))
          .then((v) {
        osmMarkers['Departure'] = departure;
      });

      if (osmMarkers.containsKey('Destination')) {
        await mapOsmController.removeMarker(osmMarkers['Destination']!);
      }

      await mapOsmController
          .addMarker(destination,
              markerIcon: MarkerIcon(iconWidget: destinationOsmIcon),
              angle: pi / 3,
              iconAnchor: IconAnchor(
                anchor: Anchor.top,
              ))
          .then((v) {
        osmMarkers['Destination'] = destination;
      });
    });
  }
}
