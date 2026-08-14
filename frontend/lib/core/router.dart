import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vehicle_service_manager_frontend/screens/documents/documents_screen.dart';
import 'package:vehicle_service_manager_frontend/screens/home_screen.dart';
import 'package:vehicle_service_manager_frontend/screens/maintenance/maintenance_form_screen.dart';
import 'package:vehicle_service_manager_frontend/screens/maintenance/maintenance_screen.dart';
import 'package:vehicle_service_manager_frontend/screens/reminders/reminders_screen.dart';
import 'package:vehicle_service_manager_frontend/screens/vehicles/vehicle_detail_screen.dart';
import 'package:vehicle_service_manager_frontend/screens/vehicles/vehicle_form_screen.dart';
import 'package:vehicle_service_manager_frontend/screens/vehicles/vehicles_screen.dart';

typedef AppShellBuilder = Widget Function(
  BuildContext context,
  GoRouterState state,
  Widget child,
);

GoRouter createRouter({required AppShellBuilder shellBuilder}) {
  return GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      ShellRoute(
        builder: (BuildContext context, GoRouterState state, Widget child) {
          return shellBuilder(context, state, child);
        },
        routes: <RouteBase>[
          GoRoute(
            path: '/',
            name: 'home',
            builder: (BuildContext context, GoRouterState state) {
              return const HomeScreen();
            },
          ),
          GoRoute(
            path: '/vehicles',
            name: 'vehicles',
            builder: (BuildContext context, GoRouterState state) {
              return const VehiclesScreen();
            },
            routes: <RouteBase>[
              GoRoute(
                path: 'new',
                name: 'vehicle-new',
                builder: (BuildContext context, GoRouterState state) {
                  return const VehicleFormScreen();
                },
              ),
              GoRoute(
                path: ':id',
                name: 'vehicle-detail',
                builder: (BuildContext context, GoRouterState state) {
                  return VehicleDetailScreen(
                    vehicleId: state.pathParameters['id'] ?? '',
                  );
                },
                routes: <RouteBase>[
                  GoRoute(
                    path: 'edit',
                    name: 'vehicle-edit',
                    builder: (BuildContext context, GoRouterState state) {
                      return VehicleFormScreen(
                        vehicleId: state.pathParameters['id'],
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/maintenance',
            name: 'maintenance',
            builder: (BuildContext context, GoRouterState state) {
              return const MaintenanceScreen();
            },
            routes: <RouteBase>[
              GoRoute(
                path: 'new',
                name: 'maintenance-new',
                builder: (BuildContext context, GoRouterState state) {
                  return const MaintenanceFormScreen();
                },
              ),
              GoRoute(
                path: ':id/edit',
                name: 'maintenance-edit',
                builder: (BuildContext context, GoRouterState state) {
                  return MaintenanceFormScreen(
                    recordId: state.pathParameters['id'],
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: '/documents',
            name: 'documents',
            builder: (BuildContext context, GoRouterState state) {
              return const DocumentsScreen();
            },
          ),
          GoRoute(
            path: '/reminders',
            name: 'reminders',
            builder: (BuildContext context, GoRouterState state) {
              return const RemindersScreen();
            },
          ),
        ],
      ),
    ],
  );
}

