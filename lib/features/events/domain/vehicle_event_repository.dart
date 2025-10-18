import 'vehicle_event.dart';

abstract class VehicleEventRepository {
  Stream<List<VehicleEvent>> watchEvents({String? vehicleId});

  Future<List<VehicleEvent>> fetchEvents({String? vehicleId});

  Future<void> saveEvent(VehicleEvent event);

  Future<void> deleteEvent(String id);
}
