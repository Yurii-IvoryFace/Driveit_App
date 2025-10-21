import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/vehicle_usecases.dart';
import 'vehicle_event.dart';
import 'vehicle_state.dart';

// BLoC
class VehicleBloc extends Bloc<VehicleEvent, VehicleState> {
  // Vehicle CRUD use cases
  final GetVehicles getVehicles;
  final SaveVehicle saveVehicle;
  final DeleteVehicle deleteVehicle;
  final SetPrimaryVehicle setPrimaryVehicle;
  final GetPrimaryVehicle getPrimaryVehicle;
  final WatchVehiclesWithStats watchVehiclesWithStats;
  final GetVehicleWithPhotos getVehicleWithPhotos;
  final GetVehicleWithDocuments getVehicleWithDocuments;

  // Vehicle Stats use cases
  final AddVehicleStat addVehicleStat;
  final UpdateVehicleStat updateVehicleStat;
  final DeleteVehicleStat deleteVehicleStat;
  final GetVehicleStats getVehicleStats;
  final WatchVehicleStats watchVehicleStats;

  // Vehicle Photos use cases
  final AddVehiclePhoto addVehiclePhoto;
  final UpdateVehiclePhoto updateVehiclePhoto;
  final DeleteVehiclePhoto deleteVehiclePhoto;
  final GetVehiclePhotos getVehiclePhotos;
  final WatchVehiclePhotos watchVehiclePhotos;

  // Vehicle Documents use cases
  final AddVehicleDocument addVehicleDocument;
  final UpdateVehicleDocument updateVehicleDocument;
  final DeleteVehicleDocument deleteVehicleDocument;
  final GetVehicleDocuments getVehicleDocuments;
  final WatchVehicleDocuments watchVehicleDocuments;

  VehicleBloc({
    required this.getVehicles,
    required this.saveVehicle,
    required this.deleteVehicle,
    required this.setPrimaryVehicle,
    required this.getPrimaryVehicle,
    required this.watchVehiclesWithStats,
    required this.getVehicleWithPhotos,
    required this.getVehicleWithDocuments,
    required this.addVehicleStat,
    required this.updateVehicleStat,
    required this.deleteVehicleStat,
    required this.getVehicleStats,
    required this.watchVehicleStats,
    required this.addVehiclePhoto,
    required this.updateVehiclePhoto,
    required this.deleteVehiclePhoto,
    required this.getVehiclePhotos,
    required this.watchVehiclePhotos,
    required this.addVehicleDocument,
    required this.updateVehicleDocument,
    required this.deleteVehicleDocument,
    required this.getVehicleDocuments,
    required this.watchVehicleDocuments,
  }) : super(VehicleInitial()) {
    // Vehicle CRUD events
    on<LoadVehicles>(_onLoadVehicles);
    on<AddVehicle>(_onAddVehicle);
    on<UpdateVehicle>(_onUpdateVehicle);
    on<DeleteVehicleEvent>(_onDeleteVehicle);
    on<SetPrimaryVehicleEvent>(_onSetPrimaryVehicle);
    on<LoadVehicleDetails>(_onLoadVehicleDetails);

    // Vehicle Stats events
    on<LoadVehicleStatsEvent>(_onLoadVehicleStats);
    on<AddVehicleStatEvent>(_onAddVehicleStat);
    on<UpdateVehicleStatEvent>(_onUpdateVehicleStat);
    on<DeleteVehicleStatEvent>(_onDeleteVehicleStat);

    // Vehicle Photos events
    on<LoadVehiclePhotosEvent>(_onLoadVehiclePhotos);
    on<AddVehiclePhotoEvent>(_onAddVehiclePhoto);
    on<UpdateVehiclePhotoEvent>(_onUpdateVehiclePhoto);
    on<DeleteVehiclePhotoEvent>(_onDeleteVehiclePhoto);

    // Vehicle Documents events
    on<LoadVehicleDocumentsEvent>(_onLoadVehicleDocuments);
    on<AddVehicleDocumentEvent>(_onAddVehicleDocument);
    on<UpdateVehicleDocumentEvent>(_onUpdateVehicleDocument);
    on<DeleteVehicleDocumentEvent>(_onDeleteVehicleDocument);
  }

  // Vehicle CRUD event handlers
  Future<void> _onLoadVehicles(
    LoadVehicles event,
    Emitter<VehicleState> emit,
  ) async {
    emit(VehicleLoading());
    try {
      final vehicles = await getVehicles();
      emit(VehicleLoaded(vehicles));
    } catch (e) {
      emit(VehicleError(e.toString()));
    }
  }

  Future<void> _onAddVehicle(
    AddVehicle event,
    Emitter<VehicleState> emit,
  ) async {
    try {
      await saveVehicle(event.vehicle);
      final vehicles = await getVehicles();
      emit(VehicleLoaded(vehicles));
    } catch (e) {
      emit(VehicleError(e.toString()));
    }
  }

  Future<void> _onUpdateVehicle(
    UpdateVehicle event,
    Emitter<VehicleState> emit,
  ) async {
    try {
      await saveVehicle(event.vehicle);
      final vehicles = await getVehicles();
      emit(VehicleLoaded(vehicles));
    } catch (e) {
      emit(VehicleError(e.toString()));
    }
  }

  Future<void> _onDeleteVehicle(
    DeleteVehicleEvent event,
    Emitter<VehicleState> emit,
  ) async {
    try {
      await deleteVehicle(event.id);
      final vehicles = await getVehicles();
      emit(VehicleLoaded(vehicles));
    } catch (e) {
      emit(VehicleError(e.toString()));
    }
  }

  Future<void> _onSetPrimaryVehicle(
    SetPrimaryVehicleEvent event,
    Emitter<VehicleState> emit,
  ) async {
    try {
      await setPrimaryVehicle(event.id);
      final vehicles = await getVehicles();
      emit(VehicleLoaded(vehicles));
    } catch (e) {
      emit(VehicleError(e.toString()));
    }
  }

  Future<void> _onLoadVehicleDetails(
    LoadVehicleDetails event,
    Emitter<VehicleState> emit,
  ) async {
    emit(VehicleDetailsLoading(event.vehicleId));
    try {
      final vehicleWithPhotos = await getVehicleWithPhotos(event.vehicleId);
      final vehicleWithDocuments = await getVehicleWithDocuments(
        event.vehicleId,
      );
      final stats = await getVehicleStats(event.vehicleId);

      if (vehicleWithPhotos != null && vehicleWithDocuments != null) {
        emit(
          VehicleDetailsLoaded(
            vehicle: vehicleWithPhotos.vehicle,
            stats: stats,
            photos: vehicleWithPhotos.photos,
            documents: vehicleWithDocuments.documents,
          ),
        );
      } else {
        emit(VehicleDetailsError('Vehicle not found'));
      }
    } catch (e) {
      emit(VehicleDetailsError(e.toString()));
    }
  }

  // Vehicle Stats event handlers
  Future<void> _onLoadVehicleStats(
    LoadVehicleStatsEvent event,
    Emitter<VehicleState> emit,
  ) async {
    emit(VehicleStatsLoading(event.vehicleId));
    try {
      final stats = await getVehicleStats(event.vehicleId);
      emit(VehicleStatsLoaded(vehicleId: event.vehicleId, stats: stats));
    } catch (e) {
      emit(VehicleStatsError(e.toString()));
    }
  }

  Future<void> _onAddVehicleStat(
    AddVehicleStatEvent event,
    Emitter<VehicleState> emit,
  ) async {
    try {
      await addVehicleStat(event.stat);
      final stats = await getVehicleStats(event.stat.vehicleId);
      emit(VehicleStatsLoaded(vehicleId: event.stat.vehicleId, stats: stats));
    } catch (e) {
      emit(VehicleStatsError(e.toString()));
    }
  }

  Future<void> _onUpdateVehicleStat(
    UpdateVehicleStatEvent event,
    Emitter<VehicleState> emit,
  ) async {
    try {
      await updateVehicleStat(event.stat);
      final stats = await getVehicleStats(event.stat.vehicleId);
      emit(VehicleStatsLoaded(vehicleId: event.stat.vehicleId, stats: stats));
    } catch (e) {
      emit(VehicleStatsError(e.toString()));
    }
  }

  Future<void> _onDeleteVehicleStat(
    DeleteVehicleStatEvent event,
    Emitter<VehicleState> emit,
  ) async {
    try {
      await deleteVehicleStat(event.statId);
      // Note: We need the vehicleId to reload stats, but it's not in the event
      // This is a limitation of the current design
      emit(VehicleStatsError('Cannot reload stats without vehicleId'));
    } catch (e) {
      emit(VehicleStatsError(e.toString()));
    }
  }

  // Vehicle Photos event handlers
  Future<void> _onLoadVehiclePhotos(
    LoadVehiclePhotosEvent event,
    Emitter<VehicleState> emit,
  ) async {
    emit(VehiclePhotosLoading(event.vehicleId));
    try {
      final photos = await getVehiclePhotos(event.vehicleId);
      emit(VehiclePhotosLoaded(vehicleId: event.vehicleId, photos: photos));
    } catch (e) {
      emit(VehiclePhotosError(e.toString()));
    }
  }

  Future<void> _onAddVehiclePhoto(
    AddVehiclePhotoEvent event,
    Emitter<VehicleState> emit,
  ) async {
    try {
      await addVehiclePhoto(event.photo);
      final photos = await getVehiclePhotos(event.photo.vehicleId);
      emit(
        VehiclePhotosLoaded(vehicleId: event.photo.vehicleId, photos: photos),
      );
    } catch (e) {
      emit(VehiclePhotosError(e.toString()));
    }
  }

  Future<void> _onUpdateVehiclePhoto(
    UpdateVehiclePhotoEvent event,
    Emitter<VehicleState> emit,
  ) async {
    try {
      await updateVehiclePhoto(event.photo);
      final photos = await getVehiclePhotos(event.photo.vehicleId);
      emit(
        VehiclePhotosLoaded(vehicleId: event.photo.vehicleId, photos: photos),
      );
    } catch (e) {
      emit(VehiclePhotosError(e.toString()));
    }
  }

  Future<void> _onDeleteVehiclePhoto(
    DeleteVehiclePhotoEvent event,
    Emitter<VehicleState> emit,
  ) async {
    try {
      await deleteVehiclePhoto(event.photoId);
      // Note: We need the vehicleId to reload photos, but it's not in the event
      // This is a limitation of the current design
      emit(VehiclePhotosError('Cannot reload photos without vehicleId'));
    } catch (e) {
      emit(VehiclePhotosError(e.toString()));
    }
  }

  // Vehicle Documents event handlers
  Future<void> _onLoadVehicleDocuments(
    LoadVehicleDocumentsEvent event,
    Emitter<VehicleState> emit,
  ) async {
    emit(VehicleDocumentsLoading(event.vehicleId));
    try {
      final documents = await getVehicleDocuments(event.vehicleId);
      emit(
        VehicleDocumentsLoaded(
          vehicleId: event.vehicleId,
          documents: documents,
        ),
      );
    } catch (e) {
      emit(VehicleDocumentsError(e.toString()));
    }
  }

  Future<void> _onAddVehicleDocument(
    AddVehicleDocumentEvent event,
    Emitter<VehicleState> emit,
  ) async {
    try {
      await addVehicleDocument(event.document);
      final documents = await getVehicleDocuments(event.document.vehicleId);
      emit(
        VehicleDocumentsLoaded(
          vehicleId: event.document.vehicleId,
          documents: documents,
        ),
      );
    } catch (e) {
      emit(VehicleDocumentsError(e.toString()));
    }
  }

  Future<void> _onUpdateVehicleDocument(
    UpdateVehicleDocumentEvent event,
    Emitter<VehicleState> emit,
  ) async {
    try {
      await updateVehicleDocument(event.document);
      final documents = await getVehicleDocuments(event.document.vehicleId);
      emit(
        VehicleDocumentsLoaded(
          vehicleId: event.document.vehicleId,
          documents: documents,
        ),
      );
    } catch (e) {
      emit(VehicleDocumentsError(e.toString()));
    }
  }

  Future<void> _onDeleteVehicleDocument(
    DeleteVehicleDocumentEvent event,
    Emitter<VehicleState> emit,
  ) async {
    try {
      await deleteVehicleDocument(event.documentId);
      // Note: We need the vehicleId to reload documents, but it's not in the event
      // This is a limitation of the current design
      emit(VehicleDocumentsError('Cannot reload documents without vehicleId'));
    } catch (e) {
      emit(VehicleDocumentsError(e.toString()));
    }
  }
}
