import 'package:flutter/material.dart';

/// Shared row layout for amount, volume, and price per unit inputs.
class DriveFuelCostInputs extends StatelessWidget {
  const DriveFuelCostInputs({
    super.key,
    required this.amountController,
    required this.volumeController,
    required this.priceController,
    this.amountLabel = 'Amount',
    this.volumeLabel = 'Volume',
    this.priceLabel = 'Price',
    this.amountHint,
    this.volumeHint,
    this.priceHint,
    this.volumeSuffix,
    this.priceSuffix,
    this.amountTrailing,
    this.onAmountChanged,
    this.onVolumeChanged,
    this.onPriceChanged,
  });

  final TextEditingController amountController;
  final TextEditingController volumeController;
  final TextEditingController priceController;

  final String amountLabel;
  final String volumeLabel;
  final String priceLabel;
  final String? amountHint;
  final String? volumeHint;
  final String? priceHint;
  final String? volumeSuffix;
  final String? priceSuffix;
  final Widget? amountTrailing;

  final ValueChanged<String>? onAmountChanged;
  final ValueChanged<String>? onVolumeChanged;
  final ValueChanged<String>? onPriceChanged;

  static const _numberKeyboard = TextInputType.numberWithOptions(
    decimal: true,
    signed: false,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildAmountRow(),
        const SizedBox(height: 16),
        _buildVolumeRow(),
        const SizedBox(height: 12),
        _buildPriceRow(),
      ],
    );
  }

  Widget _buildAmountRow() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: amountController,
            keyboardType: _numberKeyboard,
            decoration: InputDecoration(
              labelText: amountLabel,
              hintText: amountHint,
            ),
            onChanged: onAmountChanged,
          ),
        ),
        if (amountTrailing != null) ...[
          const SizedBox(width: 12),
          amountTrailing!,
        ],
      ],
    );
  }

  Widget _buildVolumeRow() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: volumeController,
            keyboardType: _numberKeyboard,
            decoration: InputDecoration(
              labelText: volumeLabel,
              hintText: volumeHint,
              suffixText: volumeSuffix,
            ),
            onChanged: onVolumeChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: priceController,
            keyboardType: _numberKeyboard,
            decoration: InputDecoration(
              labelText: priceLabel,
              hintText: priceHint,
              suffixText: priceSuffix,
            ),
            onChanged: onPriceChanged,
          ),
        ),
      ],
    );
  }
}
