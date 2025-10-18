import 'dart:async';

import 'package:driveit_app/features/events/domain/vehicle_event.dart';
import 'package:driveit_app/features/events/domain/vehicle_event_repository.dart';

class InMemoryVehicleEventRepository implements VehicleEventRepository {
  InMemoryVehicleEventRepository({List<VehicleEvent>? seed})
    : _controller = StreamController<List<VehicleEvent>>.broadcast() {
    _events = seed ?? [];
    _emit();
  }

  late List<VehicleEvent> _events;
  final StreamController<List<VehicleEvent>> _controller;

  List<VehicleEvent> get _sortedEvents =>
      [..._events]..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));

  void _emit() {
    if (_controller.hasListener) {
      _controller.add(_sortedEvents);
    }
  }

  List<VehicleEvent> _filterEvents(
    List<VehicleEvent> events,
    String? vehicleId,
  ) {
    if (vehicleId == null) return [...events];
    return events.where((event) => event.vehicleId == vehicleId).toList();
  }

  @override
  Stream<List<VehicleEvent>> watchEvents({String? vehicleId}) {
    return Stream<List<VehicleEvent>>.multi((listener) {
      void emit(List<VehicleEvent> events) {
        final filtered = _filterEvents(events, vehicleId);
        filtered.sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
        listener.add(filtered);
      }

      emit(_events);
      final subscription = _controller.stream.listen(
        emit,
        onError: listener.addError,
      );
      listener.onCancel = () => subscription.cancel();
    });
  }

  @override
  Future<List<VehicleEvent>> fetchEvents({String? vehicleId}) async {
    final filtered = _filterEvents(_events, vehicleId);
    filtered.sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    return filtered;
  }

  @override
  Future<void> saveEvent(VehicleEvent event) async {
    final index = _events.indexWhere((item) => item.id == event.id);
    if (index >= 0) {
      _events = [
        ..._events.sublist(0, index),
        event,
        ..._events.sublist(index + 1),
      ];
    } else {
      _events = [..._events, event];
    }
    _emit();
  }

  @override
  Future<void> deleteEvent(String id) async {
    _events = _events.where((event) => event.id != id).toList();
    _emit();
  }
}
