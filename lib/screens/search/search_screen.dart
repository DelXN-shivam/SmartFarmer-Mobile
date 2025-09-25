import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/farmer/farmer_bloc.dart';
import '../../blocs/farmer/farmer_event.dart';
import '../../blocs/farmer/farmer_state.dart';
import '../../blocs/crop/crop_bloc.dart';
import '../../blocs/crop/crop_event.dart';
import '../../constants/strings.dart';
import '../../services/shared_prefs_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final langCode = SharedPrefsService.getLanguage() ?? 'en';

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.getString('search_farmers', langCode)),
      ),
      body: Center(
        child: Text(
          'Search is not available. Only the current farmer is stored.',
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
