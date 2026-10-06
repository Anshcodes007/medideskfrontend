class Patient {
  const Patient({
    required this.id,
    required this.patientId,
    required this.name,
    required this.age,
    required this.phone,
    this.medicalInfo = '',
  });

  final String id;
  final String patientId;
  final String name;
  final int age;
  final String phone;
  final String medicalInfo;

  factory Patient.fromJson(Map<String, dynamic> json) {
    final rawId = (json['_id'] ?? json['id'] ?? json['patientId'] ?? '').toString();
    return Patient(
      id: rawId,
      patientId: json['patientId'] as String? ?? (rawId.startsWith('PT-') ? rawId : ''),
      name: json['name'] as String? ?? '',
      age: (json['age'] as num?)?.toInt() ?? 0,
      phone: json['phone'] as String? ?? '',
      medicalInfo: json['medicalInfo'] as String? ?? '',
    );
  }

  String get subtitle => '$phone · Age $age';
}
