import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:medidesk/core/api_client.dart';
import 'package:medidesk/core/auth_storage.dart';
import 'package:medidesk/services/appointment_service.dart';
import 'package:medidesk/services/auth_service.dart';
import 'package:medidesk/services/dashboard_service.dart';
import 'package:medidesk/services/patient_service.dart';
import 'package:medidesk/services/prescription_service.dart';
import 'package:medidesk/state/auth_controller.dart';
import 'package:medidesk/app.dart';

void main() {
  testWidgets('Login screen is shown when logged out', (tester) async {
    final storage = AuthStorage();
    final api = ApiClient(storage: storage);
    final auth = AuthController(authService: AuthService(api), storage: storage);
    auth.restoring = false;

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: auth),
          Provider.value(value: api),
          Provider(create: (_) => PatientService(api)),
          Provider(create: (_) => AppointmentService(api)),
          Provider(create: (_) => PrescriptionService(api)),
          Provider(create: (_) => DashboardService(api)),
        ],
        child: const MediDeskApp(),
      ),
    );

    expect(find.text('MediDesk'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
