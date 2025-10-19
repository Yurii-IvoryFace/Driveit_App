import 'dart:async';

import 'package:driveit_app/app/widgets/quick_add_menu.dart';
import 'package:driveit_app/features/events/domain/vehicle_event.dart';
import 'package:driveit_app/features/events/domain/vehicle_event_repository.dart';
import 'package:driveit_app/features/events/presentation/event_visuals.dart';
import 'package:driveit_app/features/events/presentation/vehicle_event_details_page.dart';
import 'package:driveit_app/features/events/presentation/vehicle_event_form_page.dart';
import 'package:driveit_app/features/vehicles/domain/vehicle.dart';
import 'package:driveit_app/features/vehicles/domain/vehicle_repository.dart';
import 'package:driveit_app/shared/theme/app_theme.dart';
import 'package:driveit_app/shared/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.onFuelSummary,
    required this.onOpenGarage,
  });

  final ValueChanged<Vehicle?> onFuelSummary;
  final VoidCallback onOpenGarage;

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  late final VehicleRepository _vehicleRepository;
  late final VehicleEventRepository _eventRepository;

  StreamSubscription<List<Vehicle>>? _vehicleSubscription;
  StreamSubscription<List<VehicleEvent>>? _eventSubscription;

  Vehicle? _activeVehicle;
  List<VehicleEvent> _events = const [];

  @override
  void initState() {
    super.initState();
    _vehicleRepository = Provider.of<VehicleRepository>(context, listen: false);
    _eventRepository = Provider.of<VehicleEventRepository>(
      context,
      listen: false,
    );

    _vehicleSubscription = _vehicleRepository.watchVehicles().listen(
      _handleVehiclesUpdate,
      onError: (_) {},
    );

    _vehicleRepository
        .fetchVehicles()
        .then(_handleVehiclesUpdate)
        .catchError((_) {});
  }

  @override
  void dispose() {
    _vehicleSubscription?.cancel();
    _eventSubscription?.cancel();
    super.dispose();
  }

  Future<bool> handleQuickAdd(QuickAddAction action) async {
    final vehicle = _activeVehicle;
    if (vehicle == null) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.fixed,
          content: Text('Add a vehicle to start logging activity.'),
        ),
      );
      return false;
    }

    final result = await Navigator.of(context).push<VehicleEvent>(
      MaterialPageRoute(
        builder: (_) => VehicleEventFormPage(
          vehicle: vehicle,
          type: action.type,
          actionLabel: action.label,
        ),
        fullscreenDialog: true,
      ),
    );
    if (result == null) {
      return true;
    }
    await _eventRepository.saveEvent(result);
    if (!mounted) return true;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.fixed,
        content: Text('${action.label} saved for ${vehicle.displayName}'),
      ),
    );
    return true;
  }

  Future<bool> showQuickAddSheet() async {
    final actions = QuickAddMenu.actions;
    if (actions.isEmpty) return true;

    final theme = Theme.of(context);
    final action = await showModalBottomSheet<QuickAddAction>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Quick actions',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Log refuels, notes, services, and more for the active vehicle.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: actions
                      .map(
                        (item) => _QuickAddSheetButton(
                          action: item,
                          onTap: () => Navigator.of(context).pop(item),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );

    if (action == null) {
      return true;
    }
    return handleQuickAdd(action);
  }

  Future<void> _openEventDetails(VehicleEvent event) async {
    final vehicle = _activeVehicle;
    if (vehicle == null) return;
    final removed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => VehicleEventDetailsPage(vehicle: vehicle, event: event),
      ),
    );
    if (removed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.fixed,
          content: Text('Event deleted'),
        ),
      );
    }
  }

  void _handleVehiclesUpdate(List<Vehicle> vehicles) {
    final active = _pickActiveVehicle(vehicles);
    final activeChanged = active?.id != _activeVehicle?.id;
    if (!mounted) return;
    setState(() {
      _activeVehicle = active;
    });

    if (activeChanged || active == null) {
      _subscribeToEvents(active?.id);
    }
  }

  Vehicle? _pickActiveVehicle(List<Vehicle> vehicles) {
    if (vehicles.isEmpty) return null;
    final primary = vehicles.firstWhere(
      (vehicle) => vehicle.isPrimary,
      orElse: () => vehicles.first,
    );
    return primary;
  }

  void _subscribeToEvents(String? vehicleId) {
    _eventSubscription?.cancel();
    if (vehicleId == null) {
      if (!mounted) return;
      setState(() => _events = const []);
      return;
    }
    if (mounted) {
      setState(() => _events = const []);
    }
    _eventSubscription = _eventRepository
        .watchEvents(vehicleId: vehicleId)
        .listen((events) {
          if (!mounted) return;
          setState(() => _events = events);
        });
  }

  @override
  Widget build(BuildContext context) {
    final vehicle = _activeVehicle;
    final events = _events;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          sliver: SliverToBoxAdapter(
            child: _VehicleHeroCard(
              vehicle: vehicle,
              onFuelStatsTap: () => widget.onFuelSummary(vehicle),
              onOpenGarage: widget.onOpenGarage,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          sliver: SliverToBoxAdapter(
            child: _VehicleStatsStrip(vehicle: vehicle),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
          sliver: const SliverToBoxAdapter(
            child: DriveSectionHeader(title: 'Vehicle timeline'),
          ),
        ),
        if (vehicle == null)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
            sliver: SliverToBoxAdapter(
              child: _TimelineEmptyState(
                hasVehicle: false,
                onOpenGarage: widget.onOpenGarage,
              ),
            ),
          )
        else if (events.isEmpty)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
            sliver: SliverToBoxAdapter(
              child: _TimelineEmptyState(
                hasVehicle: true,
                onOpenGarage: widget.onOpenGarage,
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
            sliver: SliverList.separated(
              itemCount: events.length,
              separatorBuilder: (context, _) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final event = events[index];
                return _EventCard(
                  event: event,
                  onTap: () => _openEventDetails(event),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _VehicleHeroCard extends StatelessWidget {
  const _VehicleHeroCard({
    required this.vehicle,
    required this.onFuelStatsTap,
    required this.onOpenGarage,
  });

  final Vehicle? vehicle;
  final VoidCallback onFuelStatsTap;
  final VoidCallback onOpenGarage;

  @override
  Widget build(BuildContext context) {
    final image = vehicle?.photoUrl;
    final currentVehicle = vehicle;
    final subtitle = currentVehicle == null
        ? 'Add your first vehicle to unlock stats & tracking'
        : '${currentVehicle.make} ${currentVehicle.model} \u2022 ${currentVehicle.year}';

    return DriveHeroBanner(
      image: image != null ? NetworkImage(image) : null,
      fallbackIcon: Icons.directions_car_outlined,
      title: vehicle?.displayName ?? 'No vehicles yet',
      subtitle: subtitle,
      primaryAction: FilledButton.icon(
        onPressed: onOpenGarage,
        icon: const Icon(Icons.directions_car_outlined),
        label: Text(vehicle == null ? 'Add vehicle' : 'Open garage'),
      ),
      secondaryAction: OutlinedButton(
        onPressed: vehicle == null ? null : onFuelStatsTap,
        child: const Text('Fuel summary'),
      ),
    );
  }
}

class _VehicleStatsStrip extends StatelessWidget {
  const _VehicleStatsStrip({required this.vehicle});

  final Vehicle? vehicle;

  @override
  Widget build(BuildContext context) {
    final stats = <_VehicleStat>[
      if (vehicle?.odometerKm != null)
        _VehicleStat(
          icon: Icons.speed_outlined,
          label: 'Odometer',
          value:
              '${NumberFormat.decimalPattern().format(vehicle!.odometerKm!)} km',
        ),
      if (vehicle?.nextService != null)
        _VehicleStat(
          icon: Icons.build_circle_outlined,
          label: 'Next service',
          value: _formatDate(context, vehicle!.nextService!),
        ),
      if (vehicle?.insuranceExpiry != null)
        _VehicleStat(
          icon: Icons.shield_outlined,
          label: 'Insurance',
          value: _formatDate(context, vehicle!.insuranceExpiry!),
        ),
      if (vehicle?.registrationExpiry != null)
        _VehicleStat(
          icon: Icons.assignment_turned_in_outlined,
          label: 'Registration',
          value: _formatDate(context, vehicle!.registrationExpiry!),
        ),
    ];

    if (stats.isEmpty) {
      return SizedBox(
        height: 110,
        child: Center(
          child: Text(
            vehicle == null
                ? 'Service reminders will appear here once you add a vehicle.'
                : 'Service reminders will appear here once available.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(right: 20),
        itemBuilder: (context, index) => SizedBox(
          width: 180,
          child: DriveStatTile(
            icon: stats[index].icon,
            label: stats[index].label,
            value: stats[index].value,
            backgroundColor: AppColors.surface,
          ),
        ),
        separatorBuilder: (context, _) => const SizedBox(width: 16),
        itemCount: stats.length,
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime date) {
    return MaterialLocalizations.of(context).formatShortMonthDay(date);
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event, this.onTap});

  final VehicleEvent event;
  final VoidCallback? onTap;

  static final NumberFormat _litersFormat = NumberFormat('0.0');

  @override
  Widget build(BuildContext context) {
    final visuals = resolveEventVisual(event.type);
    final dateText = DateFormat('MMM d, yyyy').format(event.occurredAt);
    final odometer = event.odometerKm == null
        ? null
        : '${NumberFormat.decimalPattern().format(event.odometerKm)} km';
    final amountText = _formatAmount(event);
    final locationText = event.location?.trim().isNotEmpty == true
        ? event.location!.trim()
        : 'Location not specified';

    final chips = <Widget>[];
    if (odometer != null) {
      chips.add(_EventMetaChip(icon: Icons.speed_outlined, label: odometer));
    }
    if (event.serviceType != null && event.serviceType!.trim().isNotEmpty) {
      chips.add(
        _EventMetaChip(icon: Icons.build_outlined, label: event.serviceType!),
      );
    }
    if (event.type == VehicleEventType.refuel) {
      final fuelType = event.fuelType?.trim();
      final volume = event.volumeLiters;
      final pricePerLiter = event.pricePerLiter;
      final isFullTank = event.isFullTank;
      if (fuelType != null && fuelType.isNotEmpty) {
        chips.add(
          _EventMetaChip(
            icon: Icons.local_gas_station,
            label: fuelType,
          ),
        );
      }
      if (volume != null) {
        chips.add(
          _EventMetaChip(
            icon: Icons.local_gas_station_outlined,
            label: '${_litersFormat.format(volume)} L',
          ),
        );
      }
      if (pricePerLiter != null) {
        final currency = event.currency ?? '';
        final prefix = currency.isEmpty ? '' : '$currency ';
        chips.add(
          _EventMetaChip(
            icon: Icons.price_change_outlined,
            label: '$prefix${pricePerLiter.toStringAsFixed(2)} /L',
          ),
        );
      }
      if (isFullTank != null) {
        chips.add(
          _EventMetaChip(
            icon: isFullTank
                ? Icons.check_circle_outline
                : Icons.inventory_outlined,
            label: isFullTank ? 'Full tank' : 'Partial fill',
          ),
        );
      }
    }

    final trailingChildren = <Widget>[];
    if (event.hasAttachments) {
      trailingChildren.add(
        const Icon(Icons.attach_file, size: 18, color: AppColors.textSecondary),
      );
    }
    if (amountText != null) {
      if (trailingChildren.isNotEmpty) {
        trailingChildren.add(const SizedBox(width: 8));
      }
      trailingChildren.add(
        Text(
          amountText,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
      );
    }
    final Widget? locationTrailing = trailingChildren.isEmpty
        ? null
        : Row(mainAxisSize: MainAxisSize.min, children: trailingChildren);

    return DriveTimelineCard(
      icon: visuals.icon,
      iconColor: visuals.color,
      iconBackgroundColor: visuals.color.withValues(alpha: 0.18),
      title: event.title,
      dateLabel: dateText,
      location: locationText,
      locationTrailing: locationTrailing,
      metaChips: chips,
      notes: event.notes,
      hasAttachments: locationTrailing == null && event.hasAttachments,
      onTap: onTap,
    );
  }

  String? _formatAmount(VehicleEvent event) {
    final amount = event.amount;
    if (amount == null) return null;
    final currency = event.currency ?? '';
    final formatter = NumberFormat.currency(
      symbol: currency.isEmpty ? '' : '$currency ',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }
}

class _EventMetaChip extends StatelessWidget {
  const _EventMetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return InfoChip(
      icon: icon,
      label: label,
      iconColor: AppColors.textSecondary,
      textColor: AppColors.textSecondary,
      backgroundColor: AppColors.surfaceSecondary,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    );
  }
}

class _TimelineEmptyState extends StatelessWidget {
  const _TimelineEmptyState({
    required this.hasVehicle,
    required this.onOpenGarage,
  });

  final bool hasVehicle;
  final VoidCallback onOpenGarage;

  @override
  Widget build(BuildContext context) {
    final title = hasVehicle
        ? 'No activity logged yet'
        : 'Add a vehicle to get started';
    final subtitle = hasVehicle
        ? 'Use Quick Actions or the Manage menu to log your first entry. '
              'Every refuel, expense, and note will appear here.'
        : 'Once you add a vehicle, you’ll be able to track every refuel, '
              'expense, or note in a single timeline.';

    return DriveEmptyState(
      icon: hasVehicle ? Icons.timeline : Icons.directions_car_outlined,
      title: title,
      message: subtitle,
      alignment: CrossAxisAlignment.start,
      textAlign: TextAlign.start,
      primaryActionLabel: hasVehicle ? 'Open garage' : 'Add vehicle',
      onPrimaryAction: onOpenGarage,
    );
  }
}

class _VehicleStat {
  const _VehicleStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

class _QuickAddSheetButton extends StatelessWidget {
  const _QuickAddSheetButton({required this.action, required this.onTap});

  final QuickAddAction action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: DriveActionChip(
        icon: action.icon,
        label: action.label,
        color: action.color,
        onTap: onTap,
      ),
    );
  }
}
