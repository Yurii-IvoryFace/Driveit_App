import 'package:equatable/equatable.dart';
import '../../../domain/entities/vehicle.dart';
import '../../../domain/entities/vehicle_stat.dart' as vehicle_stat;

// Base Vehicle States
abstract class VehicleState extends Equatable {
  const VehicleState();

  @override
  List<Object?> get props => [];
}

// Vehicle List States
class VehicleInitial extends VehicleState {}

class VehicleLoading extends VehicleState {}

class VehicleLoaded extends VehicleState {
  final List<Vehicle> vehicles;

  const VehicleLoaded(this.vehicles);

  @override
  List<Object?> get props => [vehicles];
}

class VehicleError extends VehicleState {
  final String message;

  const VehicleError(this.message);

  @override
  List<Object?> get props => [message];
}

// Vehicle Details States
class VehicleDetailsLoading extends VehicleState {
  final String vehicleId;

  const VehicleDetailsLoading(this.vehicleId);

  @override
  List<Object?> get props => [vehicleId];
}

class VehicleDetailsLoaded extends VehicleState {
  final Vehicle vehicle;
  final List<vehicle_stat.VehicleStat> stats;
  final List<VehiclePhoto> photos;
  final List<VehicleDocument> documents;

  const VehicleDetailsLoaded({
    required this.vehicle,
    required this.stats,
    required this.photos,
    required this.documents,
  });

  @override
  List<Object?> get props => [vehicle, stats, photos, documents];
}

class VehicleDetailsError extends VehicleState {
  final String message;

  const VehicleDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}

// Vehicle Stats States
class VehicleStatsLoading extends VehicleState {
  final String vehicleId;

  const VehicleStatsLoading(this.vehicleId);

  @override
  List<Object?> get props => [vehicleId];
}

class VehicleStatsLoaded extends VehicleState {
  final String vehicleId;
  final List<vehicle_stat.VehicleStat> stats;

  const VehicleStatsLoaded({required this.vehicleId, required this.stats});

  @override
  List<Object?> get props => [vehicleId, stats];
}

class VehicleStatsError extends VehicleState {
  final String message;

  const VehicleStatsError(this.message);

  @override
  List<Object?> get props => [message];
}

// Vehicle Photos States
class VehiclePhotosLoading extends VehicleState {
  final String vehicleId;

  const VehiclePhotosLoading(this.vehicleId);

  @override
  List<Object?> get props => [vehicleId];
}

class VehiclePhotosLoaded extends VehicleState {
  final String vehicleId;
  final List<VehiclePhoto> photos;

  const VehiclePhotosLoaded({required this.vehicleId, required this.photos});

  @override
  List<Object?> get props => [vehicleId, photos];
}

class VehiclePhotosError extends VehicleState {
  final String message;

  const VehiclePhotosError(this.message);

  @override
  List<Object?> get props => [message];
}

// Vehicle Documents States
class VehicleDocumentsLoading extends VehicleState {
  final String vehicleId;

  const VehicleDocumentsLoading(this.vehicleId);

  @override
  List<Object?> get props => [vehicleId];
}

class VehicleDocumentsLoaded extends VehicleState {
  final String vehicleId;
  final List<VehicleDocument> documents;

  const VehicleDocumentsLoaded({
    required this.vehicleId,
    required this.documents,
  });

  @override
  List<Object?> get props => [vehicleId, documents];
}

class VehicleDocumentsError extends VehicleState {
  final String message;

  const VehicleDocumentsError(this.message);

  @override
  List<Object?> get props => [message];
}
