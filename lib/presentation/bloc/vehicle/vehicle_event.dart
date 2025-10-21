import 'package:equatable/equatable.dart';
import '../../../domain/entities/vehicle.dart';
import '../../../domain/entities/vehicle_stat.dart' as vehicle_stat;

// Base Vehicle Events
abstract class VehicleEvent extends Equatable {
  const VehicleEvent();

  @override
  List<Object?> get props => [];
}

// Vehicle CRUD Events
class LoadVehicles extends VehicleEvent {}

class AddVehicle extends VehicleEvent {
  final Vehicle vehicle;

  const AddVehicle(this.vehicle);

  @override
  List<Object?> get props => [vehicle];
}

class UpdateVehicle extends VehicleEvent {
  final Vehicle vehicle;

  const UpdateVehicle(this.vehicle);

  @override
  List<Object?> get props => [vehicle];
}

class DeleteVehicleEvent extends VehicleEvent {
  final String id;

  const DeleteVehicleEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class SetPrimaryVehicleEvent extends VehicleEvent {
  final String id;

  const SetPrimaryVehicleEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class LoadVehicleDetails extends VehicleEvent {
  final String vehicleId;

  const LoadVehicleDetails(this.vehicleId);

  @override
  List<Object?> get props => [vehicleId];
}

// Vehicle Stats Events
class LoadVehicleStatsEvent extends VehicleEvent {
  final String vehicleId;

  const LoadVehicleStatsEvent(this.vehicleId);

  @override
  List<Object?> get props => [vehicleId];
}

class AddVehicleStatEvent extends VehicleEvent {
  final vehicle_stat.VehicleStat stat;

  const AddVehicleStatEvent(this.stat);

  @override
  List<Object?> get props => [stat];
}

class UpdateVehicleStatEvent extends VehicleEvent {
  final vehicle_stat.VehicleStat stat;

  const UpdateVehicleStatEvent(this.stat);

  @override
  List<Object?> get props => [stat];
}

class DeleteVehicleStatEvent extends VehicleEvent {
  final String statId;

  const DeleteVehicleStatEvent(this.statId);

  @override
  List<Object?> get props => [statId];
}

// Vehicle Photos Events
class LoadVehiclePhotosEvent extends VehicleEvent {
  final String vehicleId;

  const LoadVehiclePhotosEvent(this.vehicleId);

  @override
  List<Object?> get props => [vehicleId];
}

class AddVehiclePhotoEvent extends VehicleEvent {
  final VehiclePhoto photo;

  const AddVehiclePhotoEvent(this.photo);

  @override
  List<Object?> get props => [photo];
}

class UpdateVehiclePhotoEvent extends VehicleEvent {
  final VehiclePhoto photo;

  const UpdateVehiclePhotoEvent(this.photo);

  @override
  List<Object?> get props => [photo];
}

class DeleteVehiclePhotoEvent extends VehicleEvent {
  final String photoId;

  const DeleteVehiclePhotoEvent(this.photoId);

  @override
  List<Object?> get props => [photoId];
}

// Vehicle Documents Events
class LoadVehicleDocumentsEvent extends VehicleEvent {
  final String vehicleId;

  const LoadVehicleDocumentsEvent(this.vehicleId);

  @override
  List<Object?> get props => [vehicleId];
}

class AddVehicleDocumentEvent extends VehicleEvent {
  final VehicleDocument document;

  const AddVehicleDocumentEvent(this.document);

  @override
  List<Object?> get props => [document];
}

class UpdateVehicleDocumentEvent extends VehicleEvent {
  final VehicleDocument document;

  const UpdateVehicleDocumentEvent(this.document);

  @override
  List<Object?> get props => [document];
}

class DeleteVehicleDocumentEvent extends VehicleEvent {
  final String documentId;

  const DeleteVehicleDocumentEvent(this.documentId);

  @override
  List<Object?> get props => [documentId];
}
