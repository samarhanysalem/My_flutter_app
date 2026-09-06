import 'dart:async';

import 'package:doctor_appointment_app/features/home/models/doctor.dart';
import 'package:doctor_appointment_app/features/home/services/appointment_service.dart';

/// Hand-written test double so Home tests never touch real Firestore.
class FakeAppointmentService implements AppointmentService {
  final _controller = StreamController<List<Doctor>>.broadcast();

  @override
  Stream<List<Doctor>> watchDoctors() => _controller.stream;

  void emitDoctors(List<Doctor> doctors) => _controller.add(doctors);

  void emitError(Object error) => _controller.addError(error);

  void dispose() => _controller.close();
}
