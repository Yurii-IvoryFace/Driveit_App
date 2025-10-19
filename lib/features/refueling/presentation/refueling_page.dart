import 'package:driveit_app/features/refueling/domain/fuel_type.dart';
import 'package:driveit_app/features/refueling/domain/refueling_entry.dart';
import 'package:driveit_app/features/refueling/domain/refueling_repository.dart';
import 'package:driveit_app/features/refueling/domain/refueling_summary.dart';
import 'package:driveit_app/features/vehicles/domain/vehicle.dart';
import 'package:driveit_app/features/vehicles/domain/vehicle_repository.dart';
import 'package:driveit_app/shared/theme/app_theme.dart';
import 'package:driveit_app/shared/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class RefuelingPage extends StatelessWidget {
  RefuelingPage({super.key, this.initialVehicleId})
    : _viewKey = GlobalKey<RefuelingViewState>();

  final String? initialVehicleId;
  final GlobalKey<RefuelingViewState> _viewKey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Refueling'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _viewKey.currentState?.openAddSheet(),
        child: const Icon(Icons.local_gas_station_outlined),
      ),
      body: RefuelingView(
        key: _viewKey,
        initialVehicleId: initialVehicleId,
        embedded: false,
      ),
    );
  }
}

class RefuelingView extends StatefulWidget {
  const RefuelingView({
    super.key,
    this.initialVehicleId,
    required this.embedded,
  });

  final String? initialVehicleId;
  final bool embedded;

  @override
  RefuelingViewState createState() => RefuelingViewState();
}

class RefuelingViewState extends State<RefuelingView> {
  String? _selectedVehicleId;
  Vehicle? _selectedVehicle;
  String? _pendingVehicleId;

  @override
  void initState() {
    super.initState();
    _pendingVehicleId = widget.initialVehicleId;
  }

  @override
  void didUpdateWidget(covariant RefuelingView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialVehicleId != null &&
        widget.initialVehicleId != oldWidget.initialVehicleId) {
      focusVehicle(widget.initialVehicleId!);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<VehicleRepository>().fetchVehicles();
  }

  void openAddSheet() => _showRefuelingSheet();

  void focusVehicle(String vehicleId) {
    _pendingVehicleId = vehicleId;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final vehicleRepo = context.watch<VehicleRepository>();
    return StreamBuilder<List<Vehicle>>(
      stream: vehicleRepo.watchVehicles(),
      builder: (context, snapshot) {
        final vehicles = snapshot.data ?? const <Vehicle>[];
        if (vehicles.isEmpty) {
          return _buildEmptyGarage(context);
        }

        final resolved = _resolveSelection(vehicles);
        if (resolved == null) {
          return _buildEmptyGarage(context);
        }

        final selector = vehicles.length < 2
            ? null
            : DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: resolved.id,
                  dropdownColor: AppColors.surface,
                  items: vehicles
                      .map(
                        (vehicle) => DropdownMenuItem(
                          value: vehicle.id,
                          child: Text(vehicle.displayName),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _selectedVehicleId = value;
                      _selectedVehicle = vehicles.firstWhere(
                        (vehicle) => vehicle.id == value,
                      );
                    });
                  },
                ),
              );

        final body = _RefuelingBody(
          vehicle: resolved,
          vehicleId: resolved.id,
          embedded: widget.embedded,
          onAdd: openAddSheet,
          onEdit: (entry) => _showRefuelingSheet(existing: entry),
          onDelete: _confirmDeleteEntry,
        );

        if (widget.embedded) {
          return Column(
            children: [
              if (selector != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: selector,
                  ),
                ),
              Expanded(child: body),
            ],
          );
        }

        return Column(
          children: [
            if (selector != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Align(alignment: Alignment.centerRight, child: selector),
              ),
            Expanded(child: body),
          ],
        );
      },
    );
  }

  Vehicle? _resolveSelection(List<Vehicle> vehicles) {
    if (vehicles.isEmpty) return null;
    Vehicle? selected;
    if (_pendingVehicleId != null) {
      selected = vehicles.firstWhere(
        (vehicle) => vehicle.id == _pendingVehicleId,
        orElse: () => vehicles.first,
      );
      _pendingVehicleId = null;
    } else if (_selectedVehicleId != null) {
      selected = vehicles.firstWhere(
        (vehicle) => vehicle.id == _selectedVehicleId,
        orElse: () => vehicles.first,
      );
    } else {
      selected = vehicles.first;
    }
    _selectedVehicleId = selected.id;
    _selectedVehicle = selected;
    return selected;
  }

  Widget _buildEmptyGarage(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: DriveEmptyState(
          icon: Icons.local_gas_station_outlined,
          title: 'Add your first vehicle',
          message:
              'Once a vehicle is in the garage, you can start tracking fuel history and consumption insights here.',
          primaryActionLabel: 'Add vehicle',
          onPrimaryAction: () => Navigator.of(context).maybePop(),
        ),
      ),
    );
  }

  Future<void> _showRefuelingSheet({RefuelingEntry? existing}) async {
    final vehicleId = _selectedVehicleId;
    final vehicle = _selectedVehicle;
    if (vehicleId == null || vehicle == null) return;

    final repo = context.read<RefuelingRepository>();
    final uuid = const Uuid();

    final date = ValueNotifier<DateTime>(existing?.date ?? DateTime.now());
    final odometerController = TextEditingController(
      text: existing != null
          ? existing.odometerKm.toStringAsFixed(1)
          : (vehicle.odometerKm?.toStringAsFixed(1) ?? ''),
    );
    final volumeController = TextEditingController(
      text: existing?.volumeLiters.toStringAsFixed(1) ?? '',
    );
    final costController = TextEditingController(
      text: existing?.totalCost.toStringAsFixed(2) ?? '',
    );
    final priceController = TextEditingController(
      text: existing?.pricePerLiter?.toStringAsFixed(2) ?? '',
    );
    final stationController = TextEditingController(
      text: existing?.station ?? '',
    );
    final notesController = TextEditingController(text: existing?.notes ?? '');

    var fuelType = existing?.fuelType ?? FuelType.petrol;
    var isFullFill = existing?.isFullFill ?? true;

    RefuelingEntry? result;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF141A1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: StatefulBuilder(
              builder: (context, setModalState) {
                void recomputePrice() {
                  final volume = double.tryParse(volumeController.text) ?? 0;
                  final total = double.tryParse(costController.text) ?? 0;
                  if (volume <= 0 || total <= 0) {
                    priceController.clear();
                    return;
                  }
                  priceController.text = (total / volume).toStringAsFixed(2);
                }

                Future<void> submit() async {
                  final odometer = double.tryParse(
                    odometerController.text.trim(),
                  );
                  final volume = double.tryParse(volumeController.text.trim());
                  final total = double.tryParse(costController.text.trim());
                  final price = priceController.text.trim().isEmpty
                      ? null
                      : double.tryParse(priceController.text.trim());

                  if (odometer == null ||
                      volume == null ||
                      total == null ||
                      odometer <= 0 ||
                      volume <= 0 ||
                      total <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Please enter valid odometer, volume, and cost values.',
                        ),
                      ),
                    );
                    return;
                  }

                  final entry = RefuelingEntry(
                    id: existing?.id ?? uuid.v4(),
                    vehicleId: vehicleId,
                    date: date.value,
                    odometerKm: odometer,
                    volumeLiters: volume,
                    totalCost: total,
                    pricePerLiter: price ?? (total / volume),
                    fuelType: fuelType,
                    isFullFill: isFullFill,
                    station: stationController.text.trim().isEmpty
                        ? null
                        : stationController.text.trim(),
                    notes: notesController.text.trim().isEmpty
                        ? null
                        : notesController.text.trim(),
                  );

                  result = entry;
                  Navigator.of(context).pop();
                }

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DriveSectionHeader(
                        title: existing == null
                            ? 'Add refueling'
                            : 'Edit refueling',
                        trailing: IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ValueListenableBuilder<DateTime>(
                        valueListenable: date,
                        builder: (context, value, _) {
                          return DriveDatePickerChip(
                            icon: Icons.event_outlined,
                            color: AppColors.accent,
                            date: value,
                            firstDate: DateTime.now().subtract(
                              const Duration(days: 730),
                            ),
                            lastDate: DateTime.now().add(
                              const Duration(days: 1),
                            ),
                            labelBuilder: (date) =>
                                DateFormat('MMM d, yyyy').format(date),
                            onDateChanged: (picked) {
                              date.value = picked;
                              setModalState(() {});
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      const DriveSectionHeader(title: 'Readings'),
                      const SizedBox(height: 20),
                      const DriveSectionHeader(title: 'Fuel & cost'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: odometerController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: const InputDecoration(
                                labelText: 'Odometer',
                                suffixText: 'km',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<FuelType>(
                              initialValue: fuelType,
                              decoration: const InputDecoration(
                                labelText: 'Fuel type',
                              ),
                              items: FuelType.values
                                  .map(
                                    (type) => DropdownMenuItem(
                                      value: type,
                                      child: Text(type.label),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                if (value == null) return;
                                setModalState(() => fuelType = value);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DriveFuelCostInputs(
                        amountController: costController,
                        volumeController: volumeController,
                        priceController: priceController,
                        amountLabel: 'Total cost',
                        volumeLabel: 'Volume',
                        priceLabel: 'Price per liter',
                        volumeSuffix: 'L',
                        priceSuffix: '/L',
                        onAmountChanged: (_) => setModalState(recomputePrice),
                        onVolumeChanged: (_) => setModalState(recomputePrice),
                        onPriceChanged: (_) => setModalState(() {}),
                      ),
                      const SizedBox(height: 12),
                      const DriveSectionHeader(title: 'Additional details'),
                      const SizedBox(height: 12),
                      DriveFullTankSwitch(
                        value: isFullFill,
                        onChanged: (value) =>
                            setModalState(() => isFullFill = value),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: stationController,
                        decoration: const InputDecoration(
                          labelText: 'Station (optional)',
                        ),
                      ),
                      const SizedBox(height: 12),
                      DriveNotesField(
                        controller: notesController,
                        label: 'Notes (optional)',
                        minLines: 2,
                        maxLines: 4,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: submit,
                          child: Text(
                            existing == null
                                ? 'Save fill-up'
                                : 'Update fill-up',
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );

    date.dispose();
    odometerController.dispose();
    volumeController.dispose();
    costController.dispose();
    priceController.dispose();
    stationController.dispose();
    notesController.dispose();

    if (result != null) {
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      await repo.saveEntry(result!);
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            existing == null
                ? 'Refueling saved for ${_selectedVehicle?.displayName ?? 'vehicle'}.'
                : 'Refueling updated.',
          ),
        ),
      );
    }
  }

  Future<void> _confirmDeleteEntry(RefuelingEntry entry) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Delete refueling?'),
              content: const Text(
                'This will remove the selected fill-up from history. This action cannot be undone.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        ) ??
        false;
    if (!mounted) return;
    if (!confirmed) return;

    final messenger = ScaffoldMessenger.of(context);
    final repo = context.read<RefuelingRepository>();
    await repo.deleteEntry(entry.id);
    if (!mounted) return;
    messenger.showSnackBar(
      const SnackBar(content: Text('Refueling entry deleted.')),
    );
  }
}

class _RefuelingBody extends StatelessWidget {
  const _RefuelingBody({
    required this.vehicle,
    required this.vehicleId,
    required this.embedded,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  final Vehicle vehicle;
  final String vehicleId;
  final bool embedded;
  final VoidCallback onAdd;
  final ValueChanged<RefuelingEntry> onEdit;
  final ValueChanged<RefuelingEntry> onDelete;

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<RefuelingRepository>();
    return StreamBuilder<RefuelingSummary>(
      stream: repo.watchSummary(vehicleId),
      builder: (context, summarySnapshot) {
        final summary = summarySnapshot.data ?? RefuelingSummary.empty;
        return StreamBuilder<List<RefuelingEntry>>(
          stream: repo.watchByVehicle(vehicleId),
          builder: (context, entriesSnapshot) {
            final entries = entriesSnapshot.data ?? const <RefuelingEntry>[];
            final sortedEntries = [...entries]
              ..sort((a, b) => b.date.compareTo(a.date));
            final hasEntries = sortedEntries.isNotEmpty;
            final lastEntry = hasEntries ? sortedEntries.first : null;

            return RefreshIndicator(
              onRefresh: () => repo.fetchByVehicle(vehicleId),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(20, embedded ? 12 : 24, 20, 0),
                    sliver: SliverToBoxAdapter(
                      child: _SummaryHeader(
                        vehicle: vehicle,
                        lastEntry: lastEntry,
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const DriveSectionHeader(title: 'Refueling summary'),
                          const SizedBox(height: 12),
                          _SummaryMetrics(summary: summary),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                    sliver: SliverToBoxAdapter(
                      child: DriveSectionHeader(
                        title: 'Fill-up history',
                        trailing: TextButton.icon(
                          onPressed: onAdd,
                          icon: const Icon(Icons.add),
                          label: const Text('Log fill-up'),
                        ),
                      ),
                    ),
                  ),
                  if (hasEntries)
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                      sliver: SliverList.separated(
                        itemCount: sortedEntries.length,
                        separatorBuilder: (context, _) =>
                            const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final entry = sortedEntries[index];
                          return _RefuelingHistoryCard(
                            entry: entry,
                            onEdit: () => onEdit(entry),
                            onDelete: () => onDelete(entry),
                          );
                        },
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 160),
                      sliver: const SliverToBoxAdapter(
                        child: _EmptyHistoryIllustration(),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader({required this.vehicle, this.lastEntry});

  final Vehicle vehicle;
  final RefuelingEntry? lastEntry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = lastEntry != null
        ? 'Last fill-up on ${DateFormat('MMM d').format(lastEntry!.date)} • ${NumberFormat('0.0').format(lastEntry!.volumeLiters)} L'
        : 'No refueling entries yet';
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.directions_car_outlined,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vehicle.displayName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${vehicle.make} ${vehicle.model} • ${vehicle.year}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryMetrics extends StatelessWidget {
  const _SummaryMetrics({required this.summary});

  final RefuelingSummary summary;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.simpleCurrency();
    final decimal = NumberFormat('0.0');
    final distance = NumberFormat.decimalPattern();

    final metrics = [
      _Metric(
        icon: Icons.payments_outlined,
        title: 'Total spent',
        value: currency.format(summary.totalCost),
        caption: summary.fillUps > 0
            ? '${summary.fillUps} fill-ups over ${_formatDays(summary.timeframeDays)}'
            : 'No fuel spend recorded',
      ),
      _Metric(
        icon: Icons.local_gas_station_outlined,
        title: 'Avg consumption',
        value: '${decimal.format(summary.averageConsumptionPer100km)} L/100 km',
        caption: 'Calculated on full-tank fill-ups',
      ),
      _Metric(
        icon: Icons.attach_money_outlined,
        title: 'Avg price per L',
        value: '${currency.format(summary.averagePricePerLiter)} /L',
        caption: 'Across recorded fill-ups',
      ),
      _Metric(
        icon: Icons.alt_route,
        title: 'Distance tracked',
        value: '${distance.format(summary.totalDistanceKm.round())} km',
        caption: 'Between full fill-ups',
      ),
      _Metric(
        icon: Icons.trending_down_outlined,
        title: 'Cost per km',
        value: '${currency.format(summary.costPerKilometer)} /km',
        caption: 'Based on spend and mileage',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 520;
        final itemWidth = isWide
            ? (constraints.maxWidth - 12) / 2
            : constraints.maxWidth;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: metrics
              .map(
                (metric) => SizedBox(
                  width: itemWidth,
                  child: _MetricCard(metric: metric),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _Metric {
  const _Metric({
    required this.icon,
    required this.title,
    required this.value,
    required this.caption,
  });

  final IconData icon;
  final String title;
  final String value;
  final String caption;
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.metric});

  final _Metric metric;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DriveCard(
      color: AppColors.surfaceSecondary,
      borderRadius: 20,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(metric.icon, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            metric.title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            metric.value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            metric.caption,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _RefuelingHistoryCard extends StatelessWidget {
  const _RefuelingHistoryCard({
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  final RefuelingEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = NumberFormat.simpleCurrency();
    final liters = NumberFormat('0.0');
    final price = NumberFormat('0.00');
    final dateLabel = DateFormat('MMM d').format(entry.date);

    return DriveCard(
      color: AppColors.surface,
      borderRadius: 22,
      padding: const EdgeInsets.all(20),
      clipBehavior: Clip.antiAlias,
      onTap: onEdit,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    dateLabel,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          currency.format(entry.totalCost),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceSecondary,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            entry.fuelType.label,
                            style: theme.textTheme.labelMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${liters.format(entry.volumeLiters)} L \u2022 ${price.format(entry.effectivePricePerLiter)} /L \u2022 ${NumberFormat('0').format(entry.odometerKm)} km',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (entry.station != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        entry.station!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    if (entry.notes != null) ...[
                      const SizedBox(height: 6),
                      Text(entry.notes!, style: theme.textTheme.bodySmall),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<_EntryAction>(
                onSelected: (action) {
                  switch (action) {
                    case _EntryAction.edit:
                      onEdit();
                      break;
                    case _EntryAction.delete:
                      onDelete();
                      break;
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: _EntryAction.edit, child: Text('Edit')),
                  PopupMenuItem(
                    value: _EntryAction.delete,
                    child: Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                entry.isFullFill
                    ? Icons.check_circle_outline
                    : Icons.radio_button_unchecked,
                size: 18,
                color: entry.isFullFill
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                entry.isFullFill ? 'Full tank' : 'Partial fill',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyHistoryIllustration extends StatelessWidget {
  const _EmptyHistoryIllustration();

  @override
  Widget build(BuildContext context) {
    return DriveEmptyState(
      icon: Icons.local_gas_station_outlined,
      title: 'No refueling entries yet',
      message:
          'Log your first fill-up to start tracking costs, consumption, and mileage insights for this vehicle.',
      onPrimaryAction: () => Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 200),
      ),
      primaryActionLabel: 'Log fill-up',
    );
  }
}

enum _EntryAction { edit, delete }

String _formatDays(int days) {
  if (days <= 1) return '1 day';
  return '$days days';
}
