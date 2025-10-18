import 'dart:async';
import 'dart:convert';

import 'package:driveit_app/features/vehicles/data/dto/vehicle_dto.dart';
import 'package:driveit_app/features/vehicles/data/vehicle_local_data_source.dart';
import 'package:http/http.dart' as http;

/// HTTP-backed implementation targeting your local server API.
///
/// This class is intentionally minimal: replace `_baseUrl` and endpoint paths
/// once the backend contract is final. Error handling should be expanded to
/// include retries, auth headers, and richer failures.
class HttpVehicleDataSource implements VehicleLocalDataSource {
  HttpVehicleDataSource({required http.Client client, required String baseUrl})
    : _client = client,
      _baseUrl = baseUrl.replaceAll(RegExp(r'/$'), '');

  final http.Client _client;
  final String _baseUrl;
  final StreamController<List<VehicleDto>> _controller =
      StreamController<List<VehicleDto>>.broadcast();
  List<VehicleDto> _cache = const [];

  @override
  Stream<List<VehicleDto>> watchAll() {
    // Emit cached data immediately when listeners attach.
    _controller.onListen ??= () => _controller.add(_cache);
    return _controller.stream;
  }

  @override
  Future<List<VehicleDto>> getAll() async {
    final response = await _client.get(Uri.parse('$_baseUrl/api/vehicles'));
    if (response.statusCode != 200) {
      throw HttpException('Failed to fetch vehicles', response);
    }
    final payload = jsonDecode(response.body) as List<dynamic>;
    _cache = payload
        .map((item) => VehicleDto.fromJson(item as Map<String, dynamic>))
        .toList();
    _controller.add(_cache);
    return _cache;
  }

  @override
  Future<void> upsert(VehicleDto dto) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/api/vehicles'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(dto.toJson()),
    );
    if (response.statusCode >= 400) {
      throw HttpException('Failed to save vehicle', response);
    }
    await getAll();
  }

  @override
  Future<void> remove(String id) async {
    final response = await _client.delete(
      Uri.parse('$_baseUrl/api/vehicles/$id'),
    );
    if (response.statusCode >= 400 && response.statusCode != 404) {
      throw HttpException('Failed to delete vehicle', response);
    }
    await getAll();
  }

  @override
  Future<void> markPrimary(String id) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/api/vehicles/$id/primary'),
    );
    if (response.statusCode >= 400) {
      throw HttpException('Failed to mark vehicle as primary', response);
    }
    await getAll();
  }

  void dispose() {
    _controller.close();
    _client.close();
  }
}

class HttpException implements Exception {
  HttpException(this.message, this.response);

  final String message;
  final http.Response response;

  @override
  String toString() =>
      'HttpException($message, status: ${response.statusCode}, body: ${response.body})';
}
