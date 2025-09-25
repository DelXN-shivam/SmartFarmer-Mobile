import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/filter/filter_bloc.dart';
import '../../blocs/filter/filter_event.dart';
import '../../blocs/filter/filter_state.dart';
import '../../blocs/farmer/farmer_bloc.dart';
import '../../blocs/farmer/farmer_event.dart';
import '../../constants/strings.dart';
import '../../services/shared_prefs_service.dart';
import '../../blocs/farmer/farmer_state.dart';

class LocationFilterScreen extends StatefulWidget {
  const LocationFilterScreen({super.key});

  @override
  State<LocationFilterScreen> createState() => _LocationFilterScreenState();
}

class _LocationFilterScreenState extends State<LocationFilterScreen> {
  String? _selectedVillage;
  String? _selectedTaluka;
  String? _selectedDistrict;

  @override
  void initState() {
    super.initState();
    context.read<FilterBloc>().add(LoadLocations());
  }

  @override
  Widget build(BuildContext context) {
    final langCode = SharedPrefsService.getLanguage() ?? 'en';

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.getString('location_filter', langCode)),
      ),
      body: Center(
        child: Text(
          'Location filtering is not available. Only the current farmer is stored.',
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      items: [
        const DropdownMenuItem<String>(value: null, child: Text('All')),
        ...items.map((String item) {
          return DropdownMenuItem<String>(value: item, child: Text(item));
        }).toList(),
      ],
      onChanged: onChanged,
    );
  }

  Widget _buildFilteredResults() {
    return BlocBuilder<FarmerBloc, FarmerState>(
      builder: (context, state) {
        if (state is FarmerLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is FarmerLoaded) {
          if (state.farmers.isEmpty) {
            return Center(
              child: Text(
                AppStrings.getString(
                  'no_data_found',
                  SharedPrefsService.getLanguage() ?? 'en',
                ),
              ),
            );
          }
          return ListView.builder(
            itemCount: state.farmers.length,
            itemBuilder: (context, index) {
              final farmer = state.farmers[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(farmer.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(farmer.contactNumber),
                      Text(farmer.fullAddress),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    _showFarmerDetails(farmer);
                  },
                ),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _showFarmerDetails(farmer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Farmer Details',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    _buildDetailRow('Name', farmer.name),
                    _buildDetailRow('Contact', farmer.contactNumber),
                    _buildDetailRow('Aadhaar', farmer.aadhaarNumber),
                    _buildDetailRow('Village', farmer.village),
                    _buildDetailRow('Landmark', farmer.landmark),
                    _buildDetailRow('Taluka', farmer.taluka),
                    _buildDetailRow('District', farmer.district),
                    _buildDetailRow('Pincode', farmer.pincode),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
