part of 'admission_bloc.dart';

abstract class AdmissionState {}

class AdmissionInitial extends AdmissionState {}

class AdmissionStatusUpdated extends AdmissionState {
  final bool isComplete;

  AdmissionStatusUpdated(this.isComplete);
}

class AdmissionFailure extends AdmissionState {
  final String error;

  AdmissionFailure(this.error);
}
