import 'package:driveit_app/features/vehicles/domain/vehicle_brand.dart';
import 'package:flutter/material.dart';

class BrandSelectorField extends StatefulWidget {
  const BrandSelectorField({
    super.key,
    required this.value,
    required this.onChanged,
    this.labelText = 'Brand',
    this.enabled = true,
    this.errorText,
  });

  final VehicleBrand? value;
  final ValueChanged<VehicleBrand> onChanged;
  final String labelText;
  final bool enabled;
  final String? errorText;

  @override
  State<BrandSelectorField> createState() => _BrandSelectorFieldState();
}

class _BrandSelectorFieldState extends State<BrandSelectorField> {
  final List<VehicleBrand> _customBrands = [];
  final VehicleBrandCatalog _catalog = defaultVehicleBrandCatalog;
  List<VehicleBrand> _catalogBrands = const [];
  bool _isLoadingCatalog = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    // Defer catalog loading until user actually opens the picker
    // This prevents blocking the form initialization
  }

  @override
  Widget build(BuildContext context) {
    final brand = widget.value;
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: widget.enabled ? _openPicker : null,
      behavior: HitTestBehavior.opaque,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: widget.labelText,
          errorText: widget.errorText,
          enabled: widget.enabled,
          suffixIcon: Icon(
            Icons.directions_car_filled_outlined,
            color: widget.enabled ? null : theme.disabledColor,
          ),
        ),
        isFocused: false,
        isEmpty: brand == null,
        child: brand == null
            ? Text(
                _isLoadingCatalog ? 'Loading brands...' : 'Select brand',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.hintColor,
                ),
              )
            : Row(
                children: [
                  _BrandAvatar(brand: brand),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(brand.name, style: theme.textTheme.bodyLarge),
                  ),
                  if (brand.isCustom)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Future<void> _openPicker() async {
    FocusScope.of(context).unfocus();
    
    // Load catalog only when user opens the picker
    if (_isLoadingCatalog && _loadError == null) {
      await _loadCatalog();
      if (!mounted) return;
    }
    
    if (_catalogBrands.isEmpty && _loadError != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load brand catalog')),
      );
      return;
    }
    final base = [..._catalogBrands];
    final current = widget.value;
    if (current != null && !base.any((brand) => brand.slug == current.slug)) {
      base.add(current);
    }
    base.addAll(
      _customBrands.where(
        (brand) => !base.any((existing) => existing.slug == brand.slug),
      ),
    );
    base.sort((a, b) => a.name.compareTo(b.name));
    final selected = await showModalBottomSheet<VehicleBrand>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _BrandPickerSheet(
          brands: base,
          selected: widget.value,
          onCreateCustom: _handleCreateCustomBrand,
        );
      },
    );
    if (selected != null) {
      widget.onChanged(selected);
    }
  }

  Future<void> _loadCatalog() async {
    try {
      final brands = await _catalog.load();
      if (!mounted) return;
      setState(() {
        _catalogBrands = brands;
        _isLoadingCatalog = false;
        _loadError = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoadingCatalog = false;
        _loadError = error.toString();
      });
    }
  }

  Future<VehicleBrand?> _handleCreateCustomBrand() async {
    final controller = TextEditingController();
    final urlController = TextEditingController();
    final brand = await showDialog<VehicleBrand>(
      context: context,
      builder: (dialogContext) {
        String? errorText;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add custom brand'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: 'Brand name',
                      errorText: errorText,
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: urlController,
                    decoration: const InputDecoration(
                      labelText: 'Logo URL (optional)',
                      helperText: 'Paste a direct image link if available.',
                    ),
                    keyboardType: TextInputType.url,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final name = controller.text.trim();
                    if (name.isEmpty) {
                      setState(() {
                        errorText = 'Please provide a brand name';
                      });
                      return;
                    }
                    final logoInput = urlController.text.trim();
                    final logo = logoInput.isEmpty ? null : logoInput;
                    Navigator.of(dialogContext).pop(
                      VehicleBrand.custom(
                        name: name,
                        logoUrl: logo,
                        thumbLogoUrl: logo,
                      ),
                    );
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
    controller.dispose();
    urlController.dispose();
    if (brand != null) {
      setState(() {
        _customBrands.add(brand);
      });
    }
    return brand;
  }
}

class _BrandPickerSheet extends StatefulWidget {
  const _BrandPickerSheet({
    required this.brands,
    required this.selected,
    required this.onCreateCustom,
  });

  final List<VehicleBrand> brands;
  final VehicleBrand? selected;
  final Future<VehicleBrand?> Function() onCreateCustom;

  @override
  State<_BrandPickerSheet> createState() => _BrandPickerSheetState();
}

class _BrandPickerSheetState extends State<_BrandPickerSheet> {
  late final TextEditingController _searchController;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = filterVehicleBrands(_query, widget.brands);
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF141A1E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() {
                    _query = value.trim();
                  }),
                  decoration: const InputDecoration(
                    labelText: 'Search brand',
                    prefixIcon: Icon(Icons.search),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? _BrandListEmptyState(
                        query: _query,
                        onCreateCustom: () async {
                          final navigator = Navigator.of(context);
                          final created = await widget.onCreateCustom();
                          if (!mounted) return;
                          if (created != null) {
                            navigator.pop(created);
                          }
                        },
                      )
                    : ListView.separated(
                        controller: controller,
                        padding: const EdgeInsets.only(
                          left: 12,
                          right: 12,
                          bottom: 12,
                        ),
                        itemCount: filtered.length,
                        separatorBuilder: (context, _) =>
                            const SizedBox(height: 4),
                        itemBuilder: (context, index) {
                          final brand = filtered[index];
                          final isSelected =
                              widget.selected != null &&
                              widget.selected!.slug == brand.slug;
                          return Card(
                            color: const Color(0xFF1A2024),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListTile(
                              onTap: () => Navigator.of(context).pop(brand),
                              leading: _BrandAvatar(brand: brand),
                              title: Text(brand.name),
                              trailing: isSelected
                                  ? const Icon(Icons.check, color: Colors.teal)
                                  : null,
                            ),
                          );
                        },
                      ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: FilledButton.icon(
                    onPressed: () async {
                      final navigator = Navigator.of(context);
                      final created = await widget.onCreateCustom();
                      if (!mounted) return;
                      if (created != null) {
                        navigator.pop(created);
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add custom brand'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BrandAvatar extends StatelessWidget {
  const _BrandAvatar({required this.brand});

  final VehicleBrand brand;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = brand.isCustom
        ? theme.colorScheme.secondaryContainer
        : const Color(0xFF1F2529);
    final imageUrl = brand.thumbLogoUrl ?? brand.logoUrl;
    if (imageUrl == null || imageUrl.isEmpty) {
      return CircleAvatar(
        radius: 22,
        backgroundColor: background,
        child: Text(
          brand.initials,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSecondaryContainer,
          ),
        ),
      );
    }
    return CircleAvatar(
      radius: 22,
      backgroundColor: background,
      child: ClipOval(
        child: Image.network(
          imageUrl,
          width: 36,
          height: 36,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) =>
              Text(brand.initials, style: theme.textTheme.labelLarge),
        ),
      ),
    );
  }
}

class _BrandListEmptyState extends StatelessWidget {
  const _BrandListEmptyState({
    required this.query,
    required this.onCreateCustom,
  });

  final String query;
  final VoidCallback onCreateCustom;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 48, color: theme.disabledColor),
            const SizedBox(height: 12),
            Text(
              'No brands match "$query".',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Add a custom brand so it is available for this vehicle.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withValues(
                  alpha: 0.8,
                ),
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: onCreateCustom,
              icon: const Icon(Icons.add),
              label: const Text('Create custom brand'),
            ),
          ],
        ),
      ),
    );
  }
}
