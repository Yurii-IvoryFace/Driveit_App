import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class BrandSelectorField extends StatefulWidget {
  final String? selectedBrand;
  final ValueChanged<String?> onChanged;
  final String label;
  final String? hint;

  const BrandSelectorField({
    super.key,
    this.selectedBrand,
    required this.onChanged,
    required this.label,
    this.hint,
  });

  @override
  State<BrandSelectorField> createState() => _BrandSelectorFieldState();
}

class _BrandSelectorFieldState extends State<BrandSelectorField> {
  static const List<String> _brands = [
    'Acura',
    'Audi',
    'BMW',
    'Buick',
    'Cadillac',
    'Chevrolet',
    'Chrysler',
    'Dodge',
    'Ford',
    'Genesis',
    'GMC',
    'Honda',
    'Hyundai',
    'Infiniti',
    'Jaguar',
    'Jeep',
    'Kia',
    'Land Rover',
    'Lexus',
    'Lincoln',
    'Mazda',
    'Mercedes-Benz',
    'MINI',
    'Mitsubishi',
    'Nissan',
    'Porsche',
    'Ram',
    'Subaru',
    'Tesla',
    'Toyota',
    'Volkswagen',
    'Volvo',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8.0),
        DropdownButtonFormField<String>(
          initialValue: widget.selectedBrand,
          onChanged: widget.onChanged,
          decoration: InputDecoration(
            hintText: widget.hint ?? 'Select brand',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: AppColors.primary, width: 2.0),
            ),
            filled: true,
            fillColor: AppColors.surface,
          ),
          items: _brands.map((brand) {
            return DropdownMenuItem<String>(value: brand, child: Text(brand));
          }).toList(),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a brand';
            }
            return null;
          },
        ),
      ],
    );
  }
}
