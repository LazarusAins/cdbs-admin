part of 'admission_bloc.dart';

abstract class AdmissionEvent {}

class MarkAsCompleteClicked extends AdmissionEvent {
  final bool isComplete;

  // Constructor takes a bool to specify the desired status (true or false)
  MarkAsCompleteClicked(this.isComplete);
}
