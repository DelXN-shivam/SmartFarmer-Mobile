import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:smart_farmer/screens/auth/otp_verification_screen.dart';

import 'constants/app_constants.dart';
import 'constants/strings.dart';
import 'constants/app_theme.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/farmer/farmer_bloc.dart';
import 'blocs/crop/crop_bloc.dart';
import 'blocs/verification/verification_bloc.dart';
import 'blocs/filter/filter_bloc.dart';
import 'screens/farmer/farmer_dashboard_screen.dart';
import 'screens/verifier/verifier_dashboard_screen.dart';
import 'services/shared_prefs_service.dart';
import 'services/database_init_service.dart';
import 'blocs/auth/auth_event.dart';
import 'blocs/auth/auth_state.dart';
import 'screens/common/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize SharedPreferences
  // try {
  //   await SharedPrefsService.init();
  //   if (kReleaseMode) {
  //     await ReleaseDebugHelper.testSharedPrefs();
  //   }
  // } catch (e) {
  //   print('SharedPrefs init failed: $e');
  // }
  
  runApp(const SmartFarmerApp());
}

class SmartFarmerApp extends StatelessWidget {
  const SmartFarmerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => AuthBloc()..add(AppStarted())),
        BlocProvider<FarmerBloc>(create: (_) => FarmerBloc()),
        BlocProvider<CropBloc>(create: (_) => CropBloc()),
        BlocProvider<VerificationBloc>(create: (_) => VerificationBloc()),
        BlocProvider<FilterBloc>(create: (_) => FilterBloc()),
      ],
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final String langCode = SharedPrefsService.getLanguage() ?? 'en';
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            locale: Locale(langCode),
            supportedLocales: AppStrings.supportedLocales,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: SplashScreenWrapper(authState: state),
          );
        },
      ),
    );
  }
}

class SplashScreenWrapper extends StatefulWidget {
  final AuthState authState;
  const SplashScreenWrapper({Key? key, required this.authState})
    : super(key: key);

  @override
  State<SplashScreenWrapper> createState() => _SplashScreenWrapperState();
}

class _SplashScreenWrapperState extends State<SplashScreenWrapper> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 6), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) {
            if (widget.authState is Authenticated) {
              final authState = widget.authState as Authenticated;
              switch (authState.role.toLowerCase()) {
                case 'farmer':
                  return const FarmerDashboardScreen();
                case 'verifier':
                  return const VerifierDashboardScreen();
                case 'admin':
                  return const FarmerDashboardScreen(); // TODO: Add AdminDashboardScreen
                default:
                  return const FarmerDashboardScreen();
              }
            }
            return const MobileOTPScreen();
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
    // return const CropDetailsForm(crop: null, farmerId: "");
  }
}
