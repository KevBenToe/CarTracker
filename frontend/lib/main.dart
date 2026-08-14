import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vehicle_service_manager_frontend/app.dart';
import 'package:vehicle_service_manager_frontend/core/constants.dart';
import 'package:vehicle_service_manager_frontend/providers/app_state_provider.dart';
import 'package:vehicle_service_manager_frontend/providers/maintenance_provider.dart';
import 'package:vehicle_service_manager_frontend/providers/theme_provider.dart';
import 'package:vehicle_service_manager_frontend/providers/vehicle_provider.dart';
import 'package:vehicle_service_manager_frontend/repositories/document_repository.dart';
import 'package:vehicle_service_manager_frontend/repositories/maintenance_repository.dart';
import 'package:vehicle_service_manager_frontend/repositories/reminder_repository.dart';
import 'package:vehicle_service_manager_frontend/repositories/vehicle_repository.dart';
import 'package:vehicle_service_manager_frontend/services/api_service.dart';
import 'package:vehicle_service_manager_frontend/services/demo_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final SharedPreferences sharedPreferences =
      await SharedPreferences.getInstance();
  final ApiService apiService = ApiService(baseUrl: kApiBaseUrl);
  final DemoService demoService = await DemoService.create();

  final AppStateProvider appStateProvider = AppStateProvider(
    apiService: apiService,
    sharedPreferences: sharedPreferences,
  );
  await appStateProvider.initialize();

  final ThemeProvider themeProvider =
      ThemeProvider(sharedPreferences: sharedPreferences);

  final ApiVehicleRepository apiVehicleRepository =
      ApiVehicleRepository(apiService: apiService);
  final DemoVehicleRepository demoVehicleRepository =
      DemoVehicleRepository(demoService: demoService);

  final ApiMaintenanceRepository apiMaintenanceRepository =
      ApiMaintenanceRepository(apiService: apiService);
  final DemoMaintenanceRepository demoMaintenanceRepository =
      DemoMaintenanceRepository(demoService: demoService);

  final ApiDocumentRepository apiDocumentRepository =
      ApiDocumentRepository(apiService: apiService);
  final DemoDocumentRepository demoDocumentRepository =
      DemoDocumentRepository(demoService: demoService);

  final ApiReminderRepository apiReminderRepository =
      ApiReminderRepository(apiService: apiService);
  final DemoReminderRepository demoReminderRepository =
      DemoReminderRepository(demoService: demoService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppStateProvider>.value(value: appStateProvider),
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
        Provider<ApiService>.value(value: apiService),
        Provider<DemoService>.value(value: demoService),
        Provider<ApiVehicleRepository>.value(value: apiVehicleRepository),
        Provider<DemoVehicleRepository>.value(value: demoVehicleRepository),
        Provider<ApiMaintenanceRepository>.value(value: apiMaintenanceRepository),
        Provider<DemoMaintenanceRepository>.value(value: demoMaintenanceRepository),
        Provider<ApiDocumentRepository>.value(value: apiDocumentRepository),
        Provider<DemoDocumentRepository>.value(value: demoDocumentRepository),
        Provider<ApiReminderRepository>.value(value: apiReminderRepository),
        Provider<DemoReminderRepository>.value(value: demoReminderRepository),
        ProxyProvider3<AppStateProvider, ApiDocumentRepository,
            DemoDocumentRepository, DocumentRepository>(
          update: (
            BuildContext context,
            AppStateProvider appState,
            ApiDocumentRepository apiRepository,
            DemoDocumentRepository demoRepository,
            DocumentRepository? previous,
          ) {
            return appState.isDemoMode ? demoRepository : apiRepository;
          },
        ),
        ProxyProvider3<AppStateProvider, ApiReminderRepository,
            DemoReminderRepository, ReminderRepository>(
          update: (
            BuildContext context,
            AppStateProvider appState,
            ApiReminderRepository apiRepository,
            DemoReminderRepository demoRepository,
            ReminderRepository? previous,
          ) {
            return appState.isDemoMode ? demoRepository : apiRepository;
          },
        ),
        ChangeNotifierProxyProvider3<AppStateProvider, ApiVehicleRepository,
            DemoVehicleRepository, VehicleProvider>(
          create: (BuildContext context) {
            final AppStateProvider appState = context.read<AppStateProvider>();
            return VehicleProvider(
              repository: appState.isDemoMode
                  ? context.read<DemoVehicleRepository>()
                  : context.read<ApiVehicleRepository>(),
            );
          },
          update: (
            BuildContext context,
            AppStateProvider appState,
            ApiVehicleRepository apiRepository,
            DemoVehicleRepository demoRepository,
            VehicleProvider? previous,
          ) {
            final VehicleProvider provider = previous ??
                VehicleProvider(
                  repository:
                      appState.isDemoMode ? demoRepository : apiRepository,
                );
            provider.updateRepository(
              appState.isDemoMode ? demoRepository : apiRepository,
            );
            return provider;
          },
        ),
        ChangeNotifierProxyProvider3<AppStateProvider, ApiMaintenanceRepository,
            DemoMaintenanceRepository, MaintenanceProvider>(
          create: (BuildContext context) {
            final AppStateProvider appState = context.read<AppStateProvider>();
            return MaintenanceProvider(
              repository: appState.isDemoMode
                  ? context.read<DemoMaintenanceRepository>()
                  : context.read<ApiMaintenanceRepository>(),
            );
          },
          update: (
            BuildContext context,
            AppStateProvider appState,
            ApiMaintenanceRepository apiRepository,
            DemoMaintenanceRepository demoRepository,
            MaintenanceProvider? previous,
          ) {
            final MaintenanceProvider provider = previous ??
                MaintenanceProvider(
                  repository:
                      appState.isDemoMode ? demoRepository : apiRepository,
                );
            provider.updateRepository(
              appState.isDemoMode ? demoRepository : apiRepository,
            );
            return provider;
          },
        ),
      ],
      child: VehicleServiceManagerApp(),
    ),
  );
}
