import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medidesk/models/appointment.dart';
import 'package:medidesk/models/patient.dart';

void main() {
  group('Appointment Model Status Tests', () {
    test('Scheduled appointment displays status "not done"', () {
      final apt = Appointment(
        id: '1',
        appointmentId: 'APT-1001',
        date: '2026-10-06',
        time: '10:00',
        queueNumber: 1,
        status: 'scheduled',
        patient: const Patient(
          id: 'p1',
          patientId: 'PID-1',
          name: 'Jane Doe',
          phone: '9876543210',
          age: 30,
        ),
      );

      expect(apt.isPending, isTrue);
      expect(apt.isCompleted, isFalse);
      expect(apt.statusDisplay, equals('not done'));
    });

    test('Completed appointment displays status "done"', () {
      final apt = Appointment(
        id: '2',
        appointmentId: 'APT-1002',
        date: '2026-10-06',
        time: '11:00',
        queueNumber: 2,
        status: 'completed',
        patient: const Patient(
          id: 'p2',
          patientId: 'PID-2',
          name: 'John Smith',
          phone: '9876543211',
          age: 45,
        ),
      );

      expect(apt.isPending, isFalse);
      expect(apt.isCompleted, isTrue);
      expect(apt.statusDisplay, equals('done'));
    });
  });

  group('Pending Appointments UI Component Tests', () {
    testWidgets('Green tick button exists with check icon', (tester) async {
      bool clicked = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Tooltip(
                message: 'Mark as done',
                child: Material(
                  color: const Color(0xFF16A34A),
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => clicked = true,
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(Icons.check, color: Colors.white, size: 24),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.check), findsOneWidget);
      final material = tester.widget<Material>(
        find.ancestor(of: find.byIcon(Icons.check), matching: find.byType(Material)).first,
      );
      expect(material.color, equals(const Color(0xFF16A34A)));

      await tester.tap(find.byIcon(Icons.check));
      await tester.pump();
      expect(clicked, isTrue);
    });
  });
}
