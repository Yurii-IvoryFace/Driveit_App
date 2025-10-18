import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

/// Lightweight description of a vehicle brand used for selection UIs.
class VehicleBrand {
  VehicleBrand({
    required this.name,
    required this.slug,
    this.logoUrl,
    this.thumbLogoUrl,
    this.isCustom = false,
  });

  VehicleBrand.custom({
    required String name,
    String? logoUrl,
    String? thumbLogoUrl,
  }) : this(
         name: name,
         slug: _slugify(name),
         logoUrl: logoUrl,
         thumbLogoUrl: thumbLogoUrl ?? logoUrl,
         isCustom: true,
       );

  factory VehicleBrand.fromJson(Map<String, dynamic> json) {
    final image = json['image'] as Map<String, dynamic>? ?? const {};
    return VehicleBrand(
      name: json['name'] as String? ?? 'Unknown',
      slug: json['slug'] as String? ?? _slugify(json['name'] as String? ?? ''),
      logoUrl:
          image['optimized'] as String? ??
          image['source'] as String? ??
          image['original'] as String?,
      thumbLogoUrl:
          image['thumb'] as String? ??
          image['optimized'] as String? ??
          image['source'] as String?,
    );
  }

  final String name;
  final String slug;
  final String? logoUrl;
  final String? thumbLogoUrl;
  final bool isCustom;

  String get initials {
    final tokens = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((token) => token.isNotEmpty)
        .toList();
    if (tokens.isEmpty) {
      return '?';
    }
    final firstWord = tokens.first;
    final firstChar = firstWord.isNotEmpty ? firstWord[0] : '?';
    String secondChar = '';
    if (tokens.length > 1 && tokens[1].isNotEmpty) {
      secondChar = tokens[1][0];
    } else if (firstWord.length > 1) {
      secondChar = firstWord[1];
    }
    final result = (firstChar + secondChar).trim();
    return result.isEmpty ? '?' : result.toUpperCase();
  }

  bool matches(String query) {
    if (query.isEmpty) return true;
    final normalized = query.toLowerCase();
    return name.toLowerCase().contains(normalized) ||
        slug.toLowerCase().contains(normalized);
  }

  VehicleBrand copyWith({String? logoUrl, String? thumbLogoUrl}) {
    return VehicleBrand(
      name: name,
      slug: slug,
      logoUrl: logoUrl ?? this.logoUrl,
      thumbLogoUrl: thumbLogoUrl ?? this.thumbLogoUrl,
      isCustom: isCustom,
    );
  }
}

class VehicleBrandCatalog {
  VehicleBrandCatalog({required this.assetPath});

  final String assetPath;
  List<VehicleBrand>? _cache;

  Future<List<VehicleBrand>> load() async {
    final cached = _cache;
    if (cached != null) return cached;
    final raw = await rootBundle.loadString(assetPath);
    final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
    final brands = decoded
        .map((entry) => entry as Map<String, dynamic>)
        .map(VehicleBrand.fromJson)
        .toList(growable: false);
    _cache = brands;
    return brands;
  }
}

final VehicleBrandCatalog defaultVehicleBrandCatalog = VehicleBrandCatalog(
  assetPath: 'assets/data/vehicle_brands.json',
);

List<VehicleBrand> filterVehicleBrands(
  String query,
  List<VehicleBrand> brands,
) {
  if (query.isEmpty) return brands;
  return brands.where((brand) => brand.matches(query)).toList(growable: false);
}

String _slugify(String value) {
  return value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'-{2,}'), '-')
      .replaceAll(RegExp(r'(^-)|(-\$)'), '');
}
