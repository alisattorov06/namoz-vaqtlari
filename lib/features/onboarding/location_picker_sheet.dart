import 'package:flutter/material.dart';
import 'package:namoz_vaqtlari/core/constants/app_colors.dart';
import 'package:namoz_vaqtlari/core/constants/app_strings.dart';
import 'package:namoz_vaqtlari/core/constants/uzbekistan_regions.dart';
import 'package:namoz_vaqtlari/core/models/location_model.dart';

/// Joylashuv tanlash sahifasi - Bottom Sheet
class LocationPickerSheet extends StatefulWidget {
  final Function(LocationModel) onSelected;
  const LocationPickerSheet({super.key, required this.onSelected});

  @override
  State<LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<LocationPickerSheet> {
  Region? _selectedRegion;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      expand: false,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _selectedRegion == null
                    ? AppStrings.selectRegion
                    : AppStrings.selectDistrict,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _selectedRegion == null
                    ? _buildRegionList(scrollController)
                    : _buildDistrictList(scrollController),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRegionList(ScrollController controller) {
    return ListView.builder(
      controller: controller,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: UzbekistanRegions.regions.length,
      itemBuilder: (_, i) {
        final r = UzbekistanRegions.regions[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.location_city, color: AppColors.primary),
            title: Text(r.name),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => setState(() => _selectedRegion = r),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      },
    );
  }

  Widget _buildDistrictList(ScrollController controller) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              IconButton(
                onPressed: () => setState(() => _selectedRegion = null),
                icon: const Icon(Icons.arrow_back),
              ),
              Expanded(
                child: Text(
                  _selectedRegion!.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: controller,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _selectedRegion!.districts.length,
            itemBuilder: (_, i) {
              final d = _selectedRegion!.districts[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.place, color: AppColors.primary),
                  title: Text(d.name),
                  trailing: const Icon(Icons.chevron_right),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  onTap: () {
                    final loc = LocationModel(
                      latitude: d.latitude,
                      longitude: d.longitude,
                      regionId: _selectedRegion!.id,
                      districtId: d.id,
                      cityName: d.name,
                      regionName: _selectedRegion!.name,
                      isGps: false,
                    );
                    widget.onSelected(loc);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
