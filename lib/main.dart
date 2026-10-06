import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/api_client.dart';
import 'core/auth_storage.dart';
import 'services/appointment_service.dart';
import 'services/auth_service.dart';
import 'services/dashboard_service.dart';
import 'services/patient_service.dart';
import 'services/prescription_service.dart';
import 'state/auth_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = AuthStorage();
  final api = ApiClient(storage: storage);
  final auth = AuthController(
    authService: AuthService(api),
    storage: storage,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) {
          auth.restore();
          return auth;
        }),
        Provider.value(value: api),
        Provider(create: (_) => PatientService(api)),
        Provider(create: (_) => AppointmentService(api)),
        Provider(create: (_) => PrescriptionService(api)),
        Provider(create: (_) => DashboardService(api)),
      ],
      child: const MediDeskApp(),
    ),
  );
}
