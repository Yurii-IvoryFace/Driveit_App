import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';

class FuelCostInputs extends StatefulWidget {
  final double? initialVolume;
  final double? initialPrice;
  final double? initialTotalCost;
  final ValueChanged<double?>? onVolumeChanged;
  final ValueChanged<double?>? onPriceChanged;
  final ValueChanged<double?>? onTotalCostChanged;
  final String? volumeLabel;
  final String? priceLabel;
  final String? totalCostLabel;
  final String? volumeUnit;
  final String? priceUnit;
  final String? totalCostUnit;
  final bool enabled;

  const FuelCostInputs({
    super.key,
    this.initialVolume,
    this.initialPrice,
    this.initialTotalCost,
    this.onVolumeChanged,
    this.onPriceChanged,
    this.onTotalCostChanged,
    this.volumeLabel,
    this.priceLabel,
    this.totalCostLabel,
    this.volumeUnit,
    this.priceUnit,
    this.totalCostUnit,
    this.enabled = true,
  });

  @override
  State<FuelCostInputs> createState() => _FuelCostInputsState();
}

class _FuelCostInputsState extends State<FuelCostInputs> {
  late TextEditingController _volumeController;
  late TextEditingController _priceController;
  late TextEditingController _totalCostController;

  @override
  void initState() {
    super.initState();
    _volumeController = TextEditingController(
      text: widget.initialVolume?.toString() ?? '',
    );
    _priceController = TextEditingController(
      text: widget.initialPrice?.toString() ?? '',
    );
    _totalCostController = TextEditingController(
      text: widget.initialTotalCost?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _volumeController.dispose();
    _priceController.dispose();
    _totalCostController.dispose();
    super.dispose();
  }

  void _calculateTotalCost() {
    final volume = double.tryParse(_volumeController.text);
    final price = double.tryParse(_priceController.text);

    if (volume != null && price != null) {
      final totalCost = volume * price;
      _totalCostController.text = totalCost.toStringAsFixed(2);
      widget.onTotalCostChanged?.call(totalCost);
    } else {
      _totalCostController.clear();
      widget.onTotalCostChanged?.call(null);
    }
  }

  void _calculatePrice() {
    final volume = double.tryParse(_volumeController.text);
    final totalCost = double.tryParse(_totalCostController.text);

    if (volume != null && totalCost != null && volume > 0) {
      final price = totalCost / volume;
      _priceController.text = price.toStringAsFixed(2);
      widget.onPriceChanged?.call(price);
    } else {
      _priceController.clear();
      widget.onPriceChanged?.call(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Volume Input
        TextFormField(
          controller: _volumeController,
          enabled: widget.enabled,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          decoration: InputDecoration(
            labelText: widget.volumeLabel ?? 'Volume',
            suffixText: widget.volumeUnit ?? 'L',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.primary),
            ),
          ),
          onChanged: (value) {
            final volume = double.tryParse(value);
            widget.onVolumeChanged?.call(volume);
            _calculateTotalCost();
          },
        ),
        const SizedBox(height: 16),

        // Price Input
        TextFormField(
          controller: _priceController,
          enabled: widget.enabled,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          decoration: InputDecoration(
            labelText: widget.priceLabel ?? 'Price per Liter',
            suffixText: widget.priceUnit ?? '₴/L',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.primary),
            ),
          ),
          onChanged: (value) {
            final price = double.tryParse(value);
            widget.onPriceChanged?.call(price);
            _calculateTotalCost();
          },
        ),
        const SizedBox(height: 16),

        // Total Cost Input
        TextFormField(
          controller: _totalCostController,
          enabled: widget.enabled,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          decoration: InputDecoration(
            labelText: widget.totalCostLabel ?? 'Total Cost',
            suffixText: widget.totalCostUnit ?? '₴',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.primary),
            ),
          ),
          onChanged: (value) {
            final totalCost = double.tryParse(value);
            widget.onTotalCostChanged?.call(totalCost);
            _calculatePrice();
          },
        ),
      ],
    );
  }
}

class FuelEfficiencyDisplay extends StatelessWidget {
  final double? volume;
  final double? distance;
  final String? unit;
  final EdgeInsetsGeometry? padding;

  const FuelEfficiencyDisplay({
    super.key,
    this.volume,
    this.distance,
    this.unit,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    if (volume == null || distance == null || distance == 0) {
      return const SizedBox.shrink();
    }

    final efficiency = (volume! / distance!) * 100; // L/100km
    final unitText = unit ?? 'L/100km';

    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Fuel Efficiency',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '${efficiency.toStringAsFixed(2)} $unitText',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Icon(Icons.local_gas_station, color: AppColors.primary, size: 32),
        ],
      ),
    );
  }
}

class FuelCostSummary extends StatelessWidget {
  final double? volume;
  final double? price;
  final double? totalCost;
  final String? volumeUnit;
  final String? priceUnit;
  final String? totalCostUnit;
  final EdgeInsetsGeometry? padding;

  const FuelCostSummary({
    super.key,
    this.volume,
    this.price,
    this.totalCost,
    this.volumeUnit,
    this.priceUnit,
    this.totalCostUnit,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Volume:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '${volume?.toStringAsFixed(2) ?? '0.00'} ${volumeUnit ?? 'L'}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Price per Liter:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '${price?.toStringAsFixed(2) ?? '0.00'} ${priceUnit ?? '₴/L'}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(color: AppColors.border),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Cost:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${totalCost?.toStringAsFixed(2) ?? '0.00'} ${totalCostUnit ?? '₴'}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
